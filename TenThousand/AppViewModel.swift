//
//  AppViewModel.swift
//  TenThousand
//
//  Main view model coordinating app state
//

import Foundation
import SwiftUI
import CoreData
import Combine
import os.log

class AppViewModel: ObservableObject {
    @Published var skills: [Skill] = []
    @Published var activeSkill: Skill?
    @Published var currentSession: Session?
    @Published var isAddingSkill = false
    @Published var justUpdatedSkillId: UUID? = nil
    @Published var selectedSkillForDetail: Skill? = nil

    let timerManager = TimerManager()
    let persistenceController: PersistenceController

    private let logger = Logger(subsystem: "com.tenthousand.app", category: "AppViewModel")

    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
        fetchSkills()
    }

    // MARK: - Skill Management

    func fetchSkills() {
        let request: NSFetchRequest<Skill> = Skill.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Skill.createdAt, ascending: true)]

        do {
            skills = try persistenceController.container.viewContext.fetch(request)
        } catch {
            logger.error("Failed to fetch skills: \(error.localizedDescription)")
        }
    }

    func createSkill(name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, trimmedName.count <= ValidationLimits.maxSkillNameLength else { return }

        // Check for duplicates
        if skills.contains(where: { $0.name == trimmedName }) {
            return
        }

        let colorIndex = Int16(skills.count % ValidationLimits.colorPaletteSize)
        _ = Skill(
            context: persistenceController.container.viewContext,
            name: trimmedName,
            colorIndex: colorIndex
        )

        persistenceController.save()
        fetchSkills()
        isAddingSkill = false
    }

    func deleteSkill(_ skill: Skill) {
        persistenceController.container.viewContext.delete(skill)
        persistenceController.save()
        fetchSkills()
    }

    // MARK: - Session Management

    func startTracking(skill: Skill) {
        // Stop any active session first
        if timerManager.isRunning {
            stopTracking()
        }

        activeSkill = skill

        // Create new session
        let session = Session(
            context: persistenceController.container.viewContext,
            skill: skill
        )
        currentSession = session

        timerManager.start()
    }

    func pauseTracking() {
        timerManager.pause()
    }

    func resumeTracking() {
        timerManager.resume()
    }

    func stopTracking() {
        guard let session = currentSession, let skill = session.skill else { return }

        _ = timerManager.stop()
        let pausedDuration = timerManager.getPausedDuration()

        session.endTime = Date()
        session.pausedDuration = pausedDuration

        persistenceController.save()

        // Store the skill ID that was just updated for animation
        justUpdatedSkillId = skill.id

        currentSession = nil
        activeSkill = nil

        // Refresh to update total times
        fetchSkills()

        // Clear the highlight after animation duration
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationDurations.updateHighlight) { [weak self] in
            self?.justUpdatedSkillId = nil
        }
    }

    // MARK: - Statistics

    func todaysTotalSeconds() -> Int64 {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())

        let request: NSFetchRequest<Session> = Session.fetchRequest()
        request.predicate = NSPredicate(format: "startTime >= %@", startOfDay as NSDate)

        do {
            let sessions = try persistenceController.container.viewContext.fetch(request)
            return sessions.reduce(0) { total, session in
                total + session.durationSeconds
            }
        } catch {
            logger.error("Failed to fetch today's sessions: \(error.localizedDescription)")
            return 0
        }
    }

    func todaysSkillCount() -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())

        let request: NSFetchRequest<Session> = Session.fetchRequest()
        request.predicate = NSPredicate(format: "startTime >= %@", startOfDay as NSDate)

        do {
            let sessions = try persistenceController.container.viewContext.fetch(request)
            let uniqueSkills = Set(sessions.compactMap { $0.skill })
            return uniqueSkills.count
        } catch {
            logger.error("Failed to fetch today's sessions: \(error.localizedDescription)")
            return 0
        }
    }

    // MARK: - Heatmap Data

    func heatmapData(weeksBack: Int = CalendarConstants.defaultWeeksBack) -> [[Int64]] {
        let calendar = Calendar.current
        let today = Date()

        var data: [[Int64]] = Array(repeating: Array(repeating: 0, count: CalendarConstants.daysPerWeek), count: weeksBack)

        let request: NSFetchRequest<Session> = Session.fetchRequest()
        guard let startDate = calendar.date(byAdding: .day, value: -(weeksBack * CalendarConstants.daysPerWeek), to: today) else {
            return data
        }
        request.predicate = NSPredicate(format: "startTime >= %@", startDate as NSDate)

        do {
            let sessions = try persistenceController.container.viewContext.fetch(request)

            for session in sessions {
                guard let startTime = session.startTime else { continue }

                let daysSinceStart = calendar.dateComponents([.day], from: startDate, to: startTime).day ?? 0
                let weekIndex = daysSinceStart / CalendarConstants.daysPerWeek
                let dayIndex = daysSinceStart % CalendarConstants.daysPerWeek

                if weekIndex >= 0 && weekIndex < weeksBack && dayIndex >= 0 && dayIndex < CalendarConstants.daysPerWeek {
                    data[weekIndex][dayIndex] += session.durationSeconds
                }
            }
        } catch {
            logger.error("Failed to fetch heatmap data: \(error.localizedDescription)")
        }

        return data
    }

    func heatmapLevel(for seconds: Int64) -> Int {
        // Convert to minutes for level calculation
        let minutes = seconds / TimeConstants.secondsPerMinute

        if minutes == 0 { return 0 }
        if minutes < HeatmapThresholds.level1 { return 1 }
        if minutes < HeatmapThresholds.level2 { return 2 }
        if minutes < HeatmapThresholds.level3 { return 3 }
        if minutes < HeatmapThresholds.level4 { return 4 }
        if minutes < HeatmapThresholds.level5 { return 5 }
        return 6
    }

    // MARK: - Skill-Specific Heatmap Data

    func heatmapDataForSkill(_ skill: Skill, daysBack: Int = 365) -> [Date: Int64] {
        let calendar = Calendar.current
        let today = Date()

        var data: [Date: Int64] = [:]

        let request: NSFetchRequest<Session> = Session.fetchRequest()
        guard let startDate = calendar.date(byAdding: .day, value: -daysBack, to: today) else {
            return data
        }

        // Filter sessions by skill and date range
        request.predicate = NSPredicate(format: "skill == %@ AND startTime >= %@", skill, startDate as NSDate)

        do {
            let sessions = try persistenceController.container.viewContext.fetch(request)

            for session in sessions {
                guard let startTime = session.startTime else { continue }

                // Get the start of day for this session
                let dayStart = calendar.startOfDay(for: startTime)

                // Add session duration to that day's total
                data[dayStart, default: 0] += session.durationSeconds
            }
        } catch {
            logger.error("Failed to fetch skill heatmap data: \(error.localizedDescription)")
        }

        return data
    }

    // MARK: - Combined Heatmap Data (All Skills)

    func combinedHeatmapData(daysBack: Int = 365) -> [Date: Int64] {
        let calendar = Calendar.current
        let today = Date()

        var data: [Date: Int64] = [:]

        let request: NSFetchRequest<Session> = Session.fetchRequest()
        guard let startDate = calendar.date(byAdding: .day, value: -daysBack, to: today) else {
            return data
        }

        request.predicate = NSPredicate(format: "startTime >= %@", startDate as NSDate)

        do {
            let sessions = try persistenceController.container.viewContext.fetch(request)

            for session in sessions {
                guard let startTime = session.startTime else { continue }

                // Get the start of day for this session
                let dayStart = calendar.startOfDay(for: startTime)

                // Add session duration to that day's total
                data[dayStart, default: 0] += session.durationSeconds
            }
        } catch {
            logger.error("Failed to fetch combined heatmap data: \(error.localizedDescription)")
        }

        return data
    }

    // MARK: - Hourly Breakdown Data

    /// Returns hourly breakdown for a specific date and skill
    /// Result: Dictionary mapping hour (0-23) to seconds accumulated in that hour
    func hourlyDataForSkill(_ skill: Skill?, date: Date) -> [Int: Int64] {
        let calendar = Calendar.current
        var data: [Int: Int64] = [:]

        // Get start and end of the specified day
        let dayStart = calendar.startOfDay(for: date)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
            return data
        }

        let request: NSFetchRequest<Session> = Session.fetchRequest()

        // Build predicate based on whether we're filtering by skill
        if let skill = skill {
            request.predicate = NSPredicate(
                format: "skill == %@ AND startTime >= %@ AND startTime < %@",
                skill, dayStart as NSDate, dayEnd as NSDate
            )
        } else {
            request.predicate = NSPredicate(
                format: "startTime >= %@ AND startTime < %@",
                dayStart as NSDate, dayEnd as NSDate
            )
        }

        do {
            let sessions = try persistenceController.container.viewContext.fetch(request)

            for session in sessions {
                guard let startTime = session.startTime,
                      let endTime = session.endTime else { continue }

                // Calculate which hour(s) this session spans
                var currentTime = startTime
                let sessionEnd = min(endTime, dayEnd) // Don't go past end of day

                while currentTime < sessionEnd {
                    let hour = calendar.component(.hour, from: currentTime)

                    // Calculate how much time is in this hour
                    guard let hourEnd = calendar.date(byAdding: .hour, value: 1, to: calendar.date(bySetting: .minute, value: 0, of: calendar.date(bySetting: .second, value: 0, of: currentTime)!)!)
                    else { break }

                    let segmentEnd = min(hourEnd, sessionEnd)
                    let secondsInHour = Int64(segmentEnd.timeIntervalSince(currentTime))

                    data[hour, default: 0] += secondsInHour

                    currentTime = segmentEnd
                }
            }
        } catch {
            logger.error("Failed to fetch hourly data: \(error.localizedDescription)")
        }

        return data
    }

    /// Returns hourly breakdown for the past 7 days (week view)
    /// Result: Dictionary mapping Date to hourly data
    func hourlyWeekDataForSkill(_ skill: Skill?) -> [Date: [Int: Int64]] {
        let calendar = Calendar.current
        let today = Date()
        var data: [Date: [Int: Int64]] = [:]

        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                let dayStart = calendar.startOfDay(for: date)
                data[dayStart] = hourlyDataForSkill(skill, date: dayStart)
            }
        }

        return data
    }

    // MARK: - Chart Data

    /// Returns daily totals for a skill over a specified period
    /// Result: Array of (Date, seconds) tuples sorted by date
    func dailyTotalsForSkill(_ skill: Skill, daysBack: Int = 30) -> [(date: Date, seconds: Int64)] {
        let calendar = Calendar.current
        let today = Date()
        var dailyData: [Date: Int64] = [:]

        let request: NSFetchRequest<Session> = Session.fetchRequest()
        guard let startDate = calendar.date(byAdding: .day, value: -daysBack, to: today) else {
            return []
        }

        request.predicate = NSPredicate(format: "skill == %@ AND startTime >= %@", skill, startDate as NSDate)

        do {
            let sessions = try persistenceController.container.viewContext.fetch(request)

            for session in sessions {
                guard let startTime = session.startTime else { continue }
                let dayStart = calendar.startOfDay(for: startTime)
                dailyData[dayStart, default: 0] += session.durationSeconds
            }
        } catch {
            logger.error("Failed to fetch daily totals: \(error.localizedDescription)")
        }

        // Fill in missing days with 0
        var result: [(date: Date, seconds: Int64)] = []
        for dayOffset in (0..<daysBack).reversed() {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                let dayStart = calendar.startOfDay(for: date)
                result.append((date: dayStart, seconds: dailyData[dayStart] ?? 0))
            }
        }

        return result
    }

    /// Returns weekly totals for a skill
    /// Result: Array of (week start date, seconds) tuples
    func weeklyTotalsForSkill(_ skill: Skill, weeksBack: Int = 12) -> [(date: Date, seconds: Int64)] {
        let calendar = Calendar.current
        let today = Date()
        var weeklyData: [Date: Int64] = [:]

        let request: NSFetchRequest<Session> = Session.fetchRequest()
        guard let startDate = calendar.date(byAdding: .weekOfYear, value: -weeksBack, to: today) else {
            return []
        }

        request.predicate = NSPredicate(format: "skill == %@ AND startTime >= %@", skill, startDate as NSDate)

        do {
            let sessions = try persistenceController.container.viewContext.fetch(request)

            for session in sessions {
                guard let startTime = session.startTime else { continue }

                // Get the start of the week for this session
                var weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startTime))!
                weekStart = calendar.startOfDay(for: weekStart)

                weeklyData[weekStart, default: 0] += session.durationSeconds
            }
        } catch {
            logger.error("Failed to fetch weekly totals: \(error.localizedDescription)")
        }

        // Fill in missing weeks with 0
        var result: [(date: Date, seconds: Int64)] = []
        for weekOffset in (0..<weeksBack).reversed() {
            if let date = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: today) {
                var weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
                weekStart = calendar.startOfDay(for: weekStart)
                result.append((date: weekStart, seconds: weeklyData[weekStart] ?? 0))
            }
        }

        return result
    }

    /// Returns cumulative hours over time for a skill
    /// Result: Array of (Date, cumulative hours) tuples
    func cumulativeHoursForSkill(_ skill: Skill, daysBack: Int = 90) -> [(date: Date, hours: Double)] {
        let dailyTotals = dailyTotalsForSkill(skill, daysBack: daysBack)
        var cumulative: Double = 0
        var result: [(date: Date, hours: Double)] = []

        for (date, seconds) in dailyTotals {
            cumulative += Double(seconds) / 3600.0 // Convert to hours
            result.append((date: date, hours: cumulative))
        }

        return result
    }
}
