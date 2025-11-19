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
}
