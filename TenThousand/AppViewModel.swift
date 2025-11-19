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

/// The main view model coordinating all app state and business logic.
///
/// AppViewModel follows the MVVM pattern, managing the application's state through
/// published properties that SwiftUI views observe. It coordinates between the
/// TimerManager, CoreData persistence layer, and provides computed statistics.
///
/// ## Responsibilities
/// - Skill CRUD operations
/// - Session tracking lifecycle
/// - Statistics calculation (today's totals, heatmap data)
/// - Goal management
/// - Chart data generation
///
/// ## Usage Example
/// ```swift
/// let viewModel = AppViewModel()
/// viewModel.createSkill(name: "Swift Programming")
/// viewModel.startTracking(skill: mySkill)
/// ```
class AppViewModel: ObservableObject {

    // MARK: - Published Properties

    /// All skills stored in the database, sorted by creation date.
    @Published var skills: [Skill] = []

    /// The skill currently being tracked, or nil if no active session.
    @Published var activeSkill: Skill?

    /// The current tracking session, or nil if not tracking.
    @Published var currentSession: Session?

    /// Whether the add skill UI should be displayed.
    @Published var isAddingSkill = false

    /// The ID of the skill that was just updated (for animation purposes).
    /// Automatically cleared after animation duration.
    @Published var justUpdatedSkillId: UUID? = nil

    /// The skill selected for detail view, or nil if showing main list.
    @Published var selectedSkillForDetail: Skill? = nil

    /// The user's goal settings (daily or weekly targets).
    @Published var goalSettings: GoalSettings?

    // MARK: - Dependencies

    /// Timer manager for tracking session elapsed time.
    let timerManager = TimerManager()

    /// CoreData persistence controller for database operations.
    let persistenceController: PersistenceController

    private let logger = Logger(subsystem: "com.tenthousand.app", category: "AppViewModel")

    // MARK: - Initialization

    /// Initializes the view model with the specified persistence controller.
    ///
    /// - Parameter persistenceController: The CoreData controller to use.
    ///   Defaults to the shared singleton instance.
    ///
    /// - Note: This constructor automatically fetches all skills and goal settings
    ///   from the database. Use `PersistenceController(inMemory: true)` for testing.
    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
        fetchSkills()
        fetchOrCreateGoalSettings()
    }

    // MARK: - Skill Management

    /// Fetches all skills from CoreData and updates the published `skills` array.
    ///
    /// Skills are sorted by creation date (oldest first). This method is called
    /// automatically during initialization and after create/delete operations.
    ///
    /// - Note: Errors are logged but do not throw. The skills array will remain
    ///   unchanged if the fetch fails.
    func fetchSkills() {
        let request: NSFetchRequest<Skill> = Skill.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Skill.createdAt, ascending: true)]

        do {
            skills = try persistenceController.container.viewContext.fetch(request)
        } catch {
            logger.error("Failed to fetch skills: \(error.localizedDescription)")
        }
    }

    /// Creates a new skill with the specified name.
    ///
    /// The skill name is validated and processed before creation:
    /// - Whitespace is trimmed from both ends
    /// - Empty names are rejected
    /// - Names longer than 30 characters are rejected
    /// - Duplicate names (case-sensitive) are rejected
    ///
    /// If creation succeeds, the skill is:
    /// - Assigned a color index based on current skill count
    /// - Saved to CoreData
    /// - Added to the skills array
    /// - The `isAddingSkill` flag is reset to false
    ///
    /// - Parameter name: The name for the new skill (max 30 characters)
    ///
    /// ## Example
    /// ```swift
    /// viewModel.createSkill(name: "Swift Programming")  // Creates skill
    /// viewModel.createSkill(name: "  ")                 // Rejected (empty)
    /// viewModel.createSkill(name: "Swift Programming")  // Rejected (duplicate)
    /// ```
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

    /// Deletes the specified skill from CoreData.
    ///
    /// This operation also deletes all associated sessions due to CoreData's
    /// cascade delete rule. The skills array is refreshed after deletion.
    ///
    /// - Parameter skill: The skill to delete
    ///
    /// - Warning: This operation cannot be undone. All session data for this
    ///   skill will be permanently deleted.
    func deleteSkill(_ skill: Skill) {
        persistenceController.container.viewContext.delete(skill)
        persistenceController.save()
        fetchSkills()
    }

    // MARK: - Session Management

    /// Starts tracking time for the specified skill.
    ///
    /// This method performs the following actions:
    /// 1. Stops any currently active session
    /// 2. Sets the specified skill as active
    /// 3. Creates a new CoreData Session entity
    /// 4. Starts the timer
    ///
    /// - Parameter skill: The skill to start tracking
    ///
    /// - Note: If a session is already running for a different skill, it will be
    ///   stopped and saved before starting the new session.
    ///
    /// ## Example
    /// ```swift
    /// let skill = viewModel.skills.first!
    /// viewModel.startTracking(skill: skill)
    /// // Timer starts, session created
    /// ```
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

    /// Pauses the current tracking session without ending it.
    ///
    /// The timer is paused and pause duration is tracked. Call `resumeTracking()`
    /// to continue the session. Pause time is excluded from the final session duration.
    ///
    /// - Note: This method does nothing if no session is active.
    func pauseTracking() {
        timerManager.pause()
    }

    /// Resumes a paused tracking session.
    ///
    /// The timer continues from where it was paused. The pause duration is tracked
    /// and will be excluded from the final session duration.
    ///
    /// - Note: This method does nothing if the session is not paused.
    func resumeTracking() {
        timerManager.resume()
    }

    /// Stops the current tracking session and saves it to CoreData.
    ///
    /// This method performs the following actions:
    /// 1. Stops the timer and retrieves final elapsed time
    /// 2. Records the end time and pause duration on the session
    /// 3. Saves the session to CoreData
    /// 4. Sets `justUpdatedSkillId` for animation (cleared after 1 second)
    /// 5. Clears the active session and skill
    /// 6. Refreshes the skills array to update total times
    ///
    /// - Note: If no session is active, this method does nothing.
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

    /// Calculates the total seconds tracked today across all skills.
    ///
    /// - Returns: Total seconds tracked today, or 0 if fetch fails or no sessions exist.
    ///
    /// - Note: "Today" is determined by the calendar's start of day (midnight).
    ///   Active sessions in progress are included in the calculation.
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

    /// Counts the number of unique skills practiced today.
    ///
    /// - Returns: Number of unique skills with at least one session today,
    ///   or 0 if fetch fails or no sessions exist.
    ///
    /// - Note: "Today" is determined by the calendar's start of day (midnight).
    ///   Multiple sessions for the same skill count as one.
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

    /// Generates heatmap data for the specified number of weeks.
    ///
    /// The heatmap is a 2D array where:
    /// - First dimension: weeks (0 = oldest, last = most recent)
    /// - Second dimension: days (0 = Sunday, 6 = Saturday)
    /// - Values: total seconds tracked on that day
    ///
    /// - Parameter weeksBack: Number of weeks to include (default: 4)
    /// - Returns: 2D array of seconds tracked per day, organized by week
    ///
    /// ## Example
    /// ```swift
    /// let heatmap = viewModel.heatmapData(weeksBack: 4)
    /// // Returns: [[week1_day0, week1_day1, ...], [week2_day0, ...], ...]
    /// // heatmap[0][0] = seconds tracked on Sunday of oldest week
    /// // heatmap[3][6] = seconds tracked on Saturday of most recent week
    /// ```
    ///
    /// - Note: Days with no tracking are represented as 0.
    ///   Use `heatmapLevel(for:)` to convert seconds to intensity levels.
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

    /// Converts seconds into a heatmap intensity level (0-6).
    ///
    /// Intensity levels are based on activity duration:
    /// - **Level 0**: 0 minutes (no activity)
    /// - **Level 1**: < 15 minutes
    /// - **Level 2**: 15-29 minutes
    /// - **Level 3**: 30-59 minutes
    /// - **Level 4**: 60-119 minutes (1-2 hours)
    /// - **Level 5**: 120-179 minutes (2-3 hours)
    /// - **Level 6**: 180+ minutes (3+ hours)
    ///
    /// - Parameter seconds: Total seconds of activity
    /// - Returns: Intensity level from 0 to 6
    ///
    /// ## Example
    /// ```swift
    /// viewModel.heatmapLevel(for: 0)      // Returns: 0
    /// viewModel.heatmapLevel(for: 600)    // Returns: 1 (10 minutes)
    /// viewModel.heatmapLevel(for: 1800)   // Returns: 3 (30 minutes)
    /// viewModel.heatmapLevel(for: 10800)  // Returns: 6 (3 hours)
    /// ```
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

    /// Generates heatmap data for a specific skill over a date range.
    ///
    /// Returns a dictionary mapping dates (normalized to start of day) to total
    /// seconds tracked on that date for the specified skill. Days with no activity
    /// are not included in the dictionary.
    ///
    /// - Parameters:
    ///   - skill: The skill to generate heatmap data for
    ///   - daysBack: Number of days to include (default: 365)
    ///
    /// - Returns: Dictionary mapping dates to total seconds tracked
    ///
    /// ## Example
    /// ```swift
    /// let data = viewModel.heatmapDataForSkill(mySkill, daysBack: 90)
    /// // Returns: [2024-01-01: 3600, 2024-01-03: 7200, ...]
    /// // Note: 2024-01-02 not in dict (no activity that day)
    /// ```
    ///
    /// - Note: This performs a CoreData fetch and may be expensive for large date ranges.
    ///   Consider caching results if calling frequently.
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

    // MARK: - Goal Management

    func fetchOrCreateGoalSettings() {
        let request: NSFetchRequest<GoalSettings> = GoalSettings.fetchRequest()

        do {
            let results = try persistenceController.container.viewContext.fetch(request)
            if let existing = results.first {
                goalSettings = existing
            } else {
                // Create default goal settings
                let newGoal = GoalSettings(
                    context: persistenceController.container.viewContext,
                    goalType: "daily",
                    targetMinutes: 60
                )
                persistenceController.save()
                goalSettings = newGoal
            }
        } catch {
            logger.error("Failed to fetch goal settings: \(error.localizedDescription)")
        }
    }

    func updateGoalSettings(goalType: String, targetMinutes: Int64, isEnabled: Bool) {
        if let goal = goalSettings {
            goal.goalType = goalType
            goal.targetMinutes = targetMinutes
            goal.isEnabled = isEnabled
        } else {
            let newGoal = GoalSettings(
                context: persistenceController.container.viewContext,
                goalType: goalType,
                targetMinutes: targetMinutes
            )
            newGoal.isEnabled = isEnabled
            goalSettings = newGoal
        }
        persistenceController.save()
    }

    // MARK: - Goal Progress Calculations

    /// Returns total seconds tracked today
    func todaysProgress() -> Int64 {
        return todaysTotalSeconds()
    }

    /// Returns total seconds tracked this week
    func thisWeeksProgress() -> Int64 {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else {
            return 0
        }

        let request: NSFetchRequest<Session> = Session.fetchRequest()
        request.predicate = NSPredicate(format: "startTime >= %@", startOfWeek as NSDate)

        do {
            let sessions = try persistenceController.container.viewContext.fetch(request)
            return sessions.reduce(0) { total, session in
                total + session.durationSeconds
            }
        } catch {
            logger.error("Failed to fetch this week's sessions: \(error.localizedDescription)")
            return 0
        }
    }

    /// Check if today's/week's goal is met
    func isGoalMet() -> Bool {
        guard let goal = goalSettings, goal.isEnabled else { return false }

        if goal.isDaily {
            return todaysProgress() >= goal.targetSeconds
        } else {
            return thisWeeksProgress() >= goal.targetSeconds
        }
    }

    /// Calculate remaining time needed to meet goal (in seconds)
    /// Returns 0 if goal is already met or disabled
    func remainingTimeForGoal() -> Int64 {
        guard let goal = goalSettings, goal.isEnabled else { return 0 }

        let currentProgress = goal.isDaily ? todaysProgress() : thisWeeksProgress()
        let remaining = goal.targetSeconds - currentProgress

        return max(0, remaining)
    }

    /// Calculate goal progress as a percentage (0.0 to 1.0)
    func goalProgressPercentage() -> Double {
        guard let goal = goalSettings, goal.isEnabled, goal.targetSeconds > 0 else { return 0.0 }

        let currentProgress = goal.isDaily ? todaysProgress() : thisWeeksProgress()
        let percentage = Double(currentProgress) / Double(goal.targetSeconds)

        return min(1.0, max(0.0, percentage))
    }

    /// Format remaining time as a string (e.g., "2h 30m", "45m", "15s")
    func formattedRemainingTime() -> String {
        let remaining = remainingTimeForGoal()

        if remaining == 0 {
            return "Goal met!"
        }

        let hours = remaining / 3600
        let minutes = (remaining % 3600) / 60
        let seconds = remaining % 60

        if hours > 0 {
            if minutes > 0 {
                return "\(hours)h \(minutes)m remaining"
            } else {
                return "\(hours)h remaining"
            }
        } else if minutes > 0 {
            return "\(minutes)m remaining"
        } else {
            return "\(seconds)s remaining"
        }
    }
}
