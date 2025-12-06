//
//  AppViewModelTests.swift
//  TenThousandTests
//
//  Unit tests for AppViewModel
//  Testing behaviors, not implementations
//

import Foundation
@testable import TenThousand
import Testing

@Suite("AppViewModel Behaviors", .serialized)
struct AppViewModelTests {
    // MARK: - Test Helpers

    static let testPaletteId = ColorPalette.summerOceanBreeze.id

    /// Creates a fresh AppViewModel with in-memory persistence for each test
    func makeViewModel() -> AppViewModel {
        let dataStore = SwiftDataStore.inMemory()
        guard let defaults = UserDefaults(suiteName: UUID().uuidString) else {
            fatalError("Failed to create test UserDefaults")
        }
        let paletteManager = ColorPaletteManager(defaults: defaults)
        return AppViewModel(dataStore: dataStore, colorPaletteManager: paletteManager)
    }

    // MARK: - Skill Creation Behaviors

    @Test("Creating a valid skill adds it to the skills list")
    func testCreateValidSkill() {
        let viewModel = makeViewModel()

        #expect(viewModel.skills.isEmpty)

        viewModel.createSkill(name: "Swift Programming")

        #expect(viewModel.skills.count == 1)
        #expect(viewModel.skills.first?.name == "Swift Programming")
    }

    @Test("Creating multiple skills adds them all")
    func testCreateMultipleSkills() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        viewModel.createSkill(name: "Python")
        viewModel.createSkill(name: "JavaScript")

        #expect(viewModel.skills.count == 3)
        #expect(viewModel.skills.map { $0.name }.contains("Swift"))
        #expect(viewModel.skills.map { $0.name }.contains("Python"))
        #expect(viewModel.skills.map { $0.name }.contains("JavaScript"))
    }

    @Test("Creating a skill with whitespace trims the name")
    func testCreateSkillTrimsWhitespace() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "  Swift  ")

        #expect(viewModel.skills.count == 1)
        #expect(viewModel.skills.first?.name == "Swift")
    }

    @Test("Creating a skill with only whitespace is rejected")
    func testCreateSkillRejectsWhitespaceOnly() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "   ")

        #expect(viewModel.skills.isEmpty)
    }

    @Test("Creating a skill with empty name is rejected")
    func testCreateSkillRejectsEmptyName() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "")

        #expect(viewModel.skills.isEmpty)
    }

    @Test("Creating a skill with name too long is rejected")
    func testCreateSkillRejectsNameTooLong() {
        let viewModel = makeViewModel()

        let longName = String(repeating: "a", count: 31) // Over 30 char limit

        viewModel.createSkill(name: longName)

        #expect(viewModel.skills.isEmpty)
    }

    @Test("Creating a skill with exactly 30 characters is accepted")
    func testCreateSkillAcceptsMaxLength() {
        let viewModel = makeViewModel()

        let maxLengthName = String(repeating: "a", count: 30)

        viewModel.createSkill(name: maxLengthName)

        #expect(viewModel.skills.count == 1)
        #expect(viewModel.skills.first?.name == maxLengthName)
    }

    @Test("Creating duplicate skill names is rejected")
    func testCreateSkillRejectsDuplicates() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        viewModel.createSkill(name: "Swift") // Duplicate

        #expect(viewModel.skills.count == 1)
    }

    @Test("Creating duplicate skill names with different whitespace is rejected")
    func testCreateSkillRejectsDuplicatesWithWhitespace() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        viewModel.createSkill(name: "  Swift  ") // Same after trimming

        #expect(viewModel.skills.count == 1)
    }

    @Test("Creating skills assigns different colors from the same palette")
    func testCreateSkillsAssignsDifferentColors() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Skill 1")
        viewModel.createSkill(name: "Skill 2")
        viewModel.createSkill(name: "Skill 3")

        #expect(viewModel.skills.count == 3)
        // All skills should be from the same palette
        let firstPaletteId = viewModel.skills[0].paletteId
        #expect(viewModel.skills[1].paletteId == firstPaletteId)
        #expect(viewModel.skills[2].paletteId == firstPaletteId)
        // Colors should be assigned in order
        #expect(viewModel.skills[0].colorIndex == 0)
        #expect(viewModel.skills[1].colorIndex == 1)
        #expect(viewModel.skills[2].colorIndex == 2)
    }

    // MARK: - Skill Deletion Behaviors

    @Test("Deleting a skill removes it from the list")
    func testDeleteSkillRemovesFromList() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        #expect(viewModel.skills.count == 1)

        guard let skill = viewModel.skills.first else {
            Issue.record("Expected skill to exist")
            return
        }
        viewModel.deleteSkill(skill)

        #expect(viewModel.skills.isEmpty)
    }

    @Test("Deleting one skill keeps others intact")
    func testDeleteSkillKeepsOthers() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        viewModel.createSkill(name: "Python")
        viewModel.createSkill(name: "JavaScript")

        guard let skillToDelete = viewModel.skills.first(where: { $0.name == "Python" }) else {
            Issue.record("Expected Python skill to exist")
            return
        }
        viewModel.deleteSkill(skillToDelete)

        #expect(viewModel.skills.count == 2)
        #expect(!viewModel.skills.contains { $0.name == "Python" })
        #expect(viewModel.skills.contains { $0.name == "Swift" })
        #expect(viewModel.skills.contains { $0.name == "JavaScript" })
    }

    @Test("Deleting viewed skill navigates back to list")
    func testDeleteSkillNavigatesBackWhenDeletingViewedSkill() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        guard let skill = viewModel.skills.first else {
            Issue.record("Expected skill to exist")
            return
        }

        viewModel.showSkillDetail(skill)
        #expect(viewModel.panelRoute == .skillDetail(skill))

        viewModel.deleteSkill(skill)

        #expect(viewModel.panelRoute == .skillList)
    }

    @Test("Deleting non-viewed skill keeps current route intact")
    func testDeleteSkillKeepsRouteWhenDeletingOtherSkill() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        viewModel.createSkill(name: "Python")

        guard let swiftSkill = viewModel.skills.first(where: { $0.name == "Swift" }),
              let pythonSkill = viewModel.skills.first(where: { $0.name == "Python" }) else {
            Issue.record("Expected both skills to exist")
            return
        }

        viewModel.showSkillDetail(swiftSkill)
        viewModel.deleteSkill(pythonSkill)

        #expect(viewModel.panelRoute == .skillDetail(swiftSkill))
    }

    // MARK: - Navigation Behaviors

    @Test("Initial panel route is skill list")
    func testInitialPanelRouteIsSkillList() {
        let viewModel = makeViewModel()

        #expect(viewModel.panelRoute == .skillList)
    }

    @Test("showSkillDetail navigates to skill detail")
    func testShowSkillDetailNavigatesToDetail() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        guard let skill = viewModel.skills.first else {
            Issue.record("Expected skill to exist")
            return
        }

        viewModel.showSkillDetail(skill)

        #expect(viewModel.panelRoute == .skillDetail(skill))
    }

    @Test("showSkillList navigates to skill list")
    func testShowSkillListNavigatesToList() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        guard let skill = viewModel.skills.first else {
            Issue.record("Expected skill to exist")
            return
        }

        viewModel.showSkillDetail(skill)
        viewModel.showSkillList()

        #expect(viewModel.panelRoute == .skillList)
    }

    @Test("Starting tracking navigates to active tracking")
    func testStartTrackingNavigatesToActiveTracking() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        guard let skill = viewModel.skills.first else {
            Issue.record("Expected skill to exist")
            return
        }

        viewModel.startTracking(skill: skill)

        #expect(viewModel.panelRoute == .activeTracking)
    }

    @Test("Stopping tracking navigates to skill list")
    func testStopTrackingNavigatesToSkillList() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        guard let skill = viewModel.skills.first else {
            Issue.record("Expected skill to exist")
            return
        }

        viewModel.startTracking(skill: skill)
        viewModel.stopTracking()

        #expect(viewModel.panelRoute == .skillList)
    }

    @Test("Can navigate to skill list while tracking")
    func testCanNavigateToSkillListWhileTracking() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        guard let skill = viewModel.skills.first else {
            Issue.record("Expected skill to exist")
            return
        }

        viewModel.startTracking(skill: skill)
        #expect(viewModel.panelRoute == .activeTracking)

        viewModel.showSkillList()

        #expect(viewModel.panelRoute == .skillList)
        #expect(viewModel.activeSkill != nil) // Still tracking
        #expect(viewModel.timerManager.isRunning)
    }

    @Test("showActiveTracking navigates to tracking view when tracking")
    func testShowActiveTrackingNavigatesWhenTracking() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        guard let skill = viewModel.skills.first else {
            Issue.record("Expected skill to exist")
            return
        }

        viewModel.startTracking(skill: skill)
        viewModel.showSkillList()
        viewModel.showActiveTracking()

        #expect(viewModel.panelRoute == .activeTracking)
    }

    @Test("showActiveTracking does nothing when not tracking")
    func testShowActiveTrackingDoesNothingWhenNotTracking() {
        let viewModel = makeViewModel()

        viewModel.showActiveTracking()

        #expect(viewModel.panelRoute == .skillList)
    }

    // MARK: - Session Management Behaviors

    @Test("Starting tracking creates an active session")
    func testStartTrackingCreatesSession() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        guard let skill = viewModel.skills.first else {
            Issue.record("Expected skill to exist")
            return
        }

        viewModel.startTracking(skill: skill)

        #expect(viewModel.activeSkill == skill)
        #expect(viewModel.currentSession != nil)
        #expect(viewModel.timerManager.isRunning)
    }

    @Test("Starting tracking on a new skill stops previous session")
    func testStartTrackingStopsPreviousSession() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        viewModel.createSkill(name: "Python")

        guard let skill1 = viewModel.skills.first(where: { $0.name == "Swift" }),
              let skill2 = viewModel.skills.first(where: { $0.name == "Python" }) else {
            Issue.record("Expected skills to exist")
            return
        }

        viewModel.startTracking(skill: skill1)
        #expect(viewModel.activeSkill == skill1)

        viewModel.startTracking(skill: skill2)
        #expect(viewModel.activeSkill == skill2)
        #expect(viewModel.timerManager.isRunning)
    }

    @Test("Pausing tracking pauses the timer")
    func testPauseTrackingPausesTimer() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        guard let skill = viewModel.skills.first else {
            Issue.record("Expected skill to exist")
            return
        }

        viewModel.startTracking(skill: skill)
        viewModel.pauseTracking()

        #expect(viewModel.timerManager.isPaused)
    }

    @Test("Resuming tracking resumes the timer")
    func testResumeTrackingResumesTimer() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        guard let skill = viewModel.skills.first else {
            Issue.record("Expected skill to exist")
            return
        }

        viewModel.startTracking(skill: skill)
        viewModel.pauseTracking()
        viewModel.resumeTracking()

        #expect(!viewModel.timerManager.isPaused)
        #expect(viewModel.timerManager.isRunning)
    }

    @Test("Stopping tracking clears active session")
    func testStopTrackingClearsSession() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        guard let skill = viewModel.skills.first else {
            Issue.record("Expected skill to exist")
            return
        }

        viewModel.startTracking(skill: skill)
        viewModel.stopTracking()

        #expect(viewModel.activeSkill == nil)
        #expect(viewModel.currentSession == nil)
        #expect(!viewModel.timerManager.isRunning)
    }

    @Test("Stopping tracking saves the session")
    func testStopTrackingSavesSession() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        guard let skill = viewModel.skills.first else {
            Issue.record("Expected skill to exist")
            return
        }

        viewModel.startTracking(skill: skill)
        viewModel.stopTracking()

        // Session should have been saved - verify through skill's sessions
        #expect(skill.sessions.count == 1)
    }

    @Test("Stopping tracking sets justUpdatedSkillId temporarily")
    func testStopTrackingSetsUpdatedSkillId() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        guard let skill = viewModel.skills.first else {
            Issue.record("Expected skill to exist")
            return
        }

        viewModel.startTracking(skill: skill)
        viewModel.stopTracking()

        #expect(viewModel.justUpdatedSkillId == skill.id)
    }

    @Test("Pausing without active tracking is a no-op")
    func testPauseWithoutActiveTrackingIsNoOp() {
        let viewModel = makeViewModel()

        viewModel.pauseTracking()

        #expect(!viewModel.timerManager.isPaused)
        #expect(!viewModel.timerManager.isRunning)
    }

    @Test("Resuming without being paused is a no-op")
    func testResumeWithoutPauseIsNoOp() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        guard let skill = viewModel.skills.first else {
            Issue.record("Expected skill to exist")
            return
        }

        viewModel.startTracking(skill: skill)
        // Not paused, try to resume
        viewModel.resumeTracking()

        #expect(viewModel.timerManager.isRunning)
        #expect(!viewModel.timerManager.isPaused)
    }

    @Test("Stopping without active tracking is a no-op")
    func testStopWithoutActiveTrackingIsNoOp() {
        let viewModel = makeViewModel()

        viewModel.stopTracking()

        #expect(viewModel.activeSkill == nil)
        #expect(viewModel.currentSession == nil)
    }

    @Test("Multiple pause calls are idempotent")
    func testMultiplePauseCallsAreIdempotent() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        guard let skill = viewModel.skills.first else {
            Issue.record("Expected skill to exist")
            return
        }

        viewModel.startTracking(skill: skill)
        viewModel.pauseTracking()
        viewModel.pauseTracking()
        viewModel.pauseTracking()

        #expect(viewModel.timerManager.isPaused)
        #expect(viewModel.timerManager.isRunning)
    }

    @Test("Pause and resume cycle maintains active skill")
    func testPauseResumeCycleMaintainsActiveSkill() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        guard let skill = viewModel.skills.first else {
            Issue.record("Expected skill to exist")
            return
        }

        viewModel.startTracking(skill: skill)
        #expect(viewModel.activeSkill?.id == skill.id)

        viewModel.pauseTracking()
        #expect(viewModel.activeSkill?.id == skill.id)

        viewModel.resumeTracking()
        #expect(viewModel.activeSkill?.id == skill.id)

        viewModel.pauseTracking()
        #expect(viewModel.activeSkill?.id == skill.id)

        viewModel.resumeTracking()
        #expect(viewModel.activeSkill?.id == skill.id)
    }

    @Test("Stopping while paused clears active session")
    func testStopWhilePausedClearsSession() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        guard let skill = viewModel.skills.first else {
            Issue.record("Expected skill to exist")
            return
        }

        viewModel.startTracking(skill: skill)
        viewModel.pauseTracking()
        #expect(viewModel.timerManager.isPaused)

        viewModel.stopTracking()

        #expect(viewModel.activeSkill == nil)
        #expect(viewModel.currentSession == nil)
        #expect(!viewModel.timerManager.isRunning)
        #expect(!viewModel.timerManager.isPaused)
    }

    @Test("Starting same skill while tracking restarts the session")
    func testStartSameSkillWhileTrackingRestartsSession() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        guard let skill = viewModel.skills.first else {
            Issue.record("Expected skill to exist")
            return
        }

        viewModel.startTracking(skill: skill)
        let firstSession = viewModel.currentSession

        viewModel.startTracking(skill: skill)
        let secondSession = viewModel.currentSession

        #expect(viewModel.activeSkill?.id == skill.id)
        #expect(firstSession?.id != secondSession?.id)
        #expect(skill.sessions.count == 2) // First session was saved, second is active
    }

    @Test("Session is added to skill.sessions immediately on creation")
    func testSessionAddedToSkillSessionsOnCreation() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        guard let skill = viewModel.skills.first else {
            Issue.record("Expected skill to exist")
            return
        }

        #expect(skill.sessions.isEmpty)

        viewModel.startTracking(skill: skill)

        #expect(skill.sessions.count == 1)
        #expect(skill.sessions.first?.id == viewModel.currentSession?.id)
    }

    @Test("Skill totalSeconds accumulates after completing session")
    func testSkillTotalSecondsAccumulatesAfterSession() {
        let dataStore = SwiftDataStore.inMemory()
        guard let defaults = UserDefaults(suiteName: UUID().uuidString) else {
            Issue.record("Failed to create test UserDefaults")
            return
        }
        let paletteManager = ColorPaletteManager(defaults: defaults)
        let viewModel = AppViewModel(dataStore: dataStore, colorPaletteManager: paletteManager)

        let skill = dataStore.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        dataStore.save()
        viewModel.fetchSkills()

        // Create and complete a 60-second session
        let session = dataStore.createSession(for: skill)
        let startTime = Date()
        session.startTime = startTime
        dataStore.completeSession(session, endTime: startTime.addingTimeInterval(60), pausedDuration: 0)
        dataStore.save()

        #expect(skill.totalSeconds == 60)
    }

    @Test("Multiple sessions accumulate in skill totalSeconds")
    func testMultipleSessionsAccumulateInTotalSeconds() {
        let dataStore = SwiftDataStore.inMemory()
        guard let defaults = UserDefaults(suiteName: UUID().uuidString) else {
            Issue.record("Failed to create test UserDefaults")
            return
        }
        let paletteManager = ColorPaletteManager(defaults: defaults)
        let viewModel = AppViewModel(dataStore: dataStore, colorPaletteManager: paletteManager)

        let skill = dataStore.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        dataStore.save()
        viewModel.fetchSkills()

        let now = Date()

        // First session: 60 seconds
        let session1 = dataStore.createSession(for: skill)
        session1.startTime = now
        dataStore.completeSession(session1, endTime: now.addingTimeInterval(60), pausedDuration: 0)

        // Second session: 120 seconds
        let session2 = dataStore.createSession(for: skill)
        session2.startTime = now.addingTimeInterval(100)
        dataStore.completeSession(session2, endTime: session2.startTime.addingTimeInterval(120), pausedDuration: 0)

        // Third session: 30 seconds
        let session3 = dataStore.createSession(for: skill)
        session3.startTime = now.addingTimeInterval(300)
        dataStore.completeSession(session3, endTime: session3.startTime.addingTimeInterval(30), pausedDuration: 0)

        dataStore.save()

        #expect(skill.totalSeconds == 210) // 60 + 120 + 30
    }

    @Test("Skill totalSeconds excludes paused duration")
    func testSkillTotalSecondsExcludesPausedDuration() {
        let dataStore = SwiftDataStore.inMemory()
        guard let defaults = UserDefaults(suiteName: UUID().uuidString) else {
            Issue.record("Failed to create test UserDefaults")
            return
        }
        let paletteManager = ColorPaletteManager(defaults: defaults)
        let viewModel = AppViewModel(dataStore: dataStore, colorPaletteManager: paletteManager)

        let skill = dataStore.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        dataStore.save()
        viewModel.fetchSkills()

        // Create a 100-second session with 40 seconds paused
        let session = dataStore.createSession(for: skill)
        let startTime = Date()
        session.startTime = startTime
        dataStore.completeSession(session, endTime: startTime.addingTimeInterval(100), pausedDuration: 40)
        dataStore.save()

        #expect(skill.totalSeconds == 60) // 100 - 40
    }

    @Test("Session bidirectional relationship is maintained")
    func testSessionBidirectionalRelationship() {
        let dataStore = SwiftDataStore.inMemory()
        guard let defaults = UserDefaults(suiteName: UUID().uuidString) else {
            Issue.record("Failed to create test UserDefaults")
            return
        }
        let paletteManager = ColorPaletteManager(defaults: defaults)
        let viewModel = AppViewModel(dataStore: dataStore, colorPaletteManager: paletteManager)

        let skill = dataStore.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        dataStore.save()

        let session = dataStore.createSession(for: skill)
        dataStore.save()

        // Verify bidirectional relationship
        #expect(session.skill?.id == skill.id)
        #expect(skill.sessions.contains { $0.id == session.id })
    }

    // MARK: - Statistics Behaviors

    @Test("Today's total seconds is zero with no sessions")
    func testTodaysTotalSecondsZeroWithNoSessions() {
        let viewModel = makeViewModel()

        #expect(viewModel.todaysTotalSeconds() == 0)
    }

    @Test("Today's skill count is zero with no sessions")
    func testTodaysSkillCountZeroWithNoSessions() {
        let viewModel = makeViewModel()

        #expect(viewModel.todaysSkillCount() == 0)
    }

    @Test("Today's skill count counts unique skills")
    func testTodaysSkillCountCountsUniqueSkills() {
        let dataStore = SwiftDataStore.inMemory()
        guard let defaults = UserDefaults(suiteName: UUID().uuidString) else {
            Issue.record("Failed to create test UserDefaults")
            return
        }
        let paletteManager = ColorPaletteManager(defaults: defaults)
        let viewModel = AppViewModel(dataStore: dataStore, colorPaletteManager: paletteManager)

        // Create skills via dataStore
        let skill1 = dataStore.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        let skill2 = dataStore.createSkill(name: "Python", paletteId: Self.testPaletteId, colorIndex: 1)

        // Create sessions for today
        let today = Date()
        let session1 = dataStore.createSession(for: skill1)
        dataStore.completeSession(session1, endTime: today.addingTimeInterval(60), pausedDuration: 0)

        let session2 = dataStore.createSession(for: skill1) // Same skill
        dataStore.completeSession(session2, endTime: today.addingTimeInterval(60), pausedDuration: 0)

        let session3 = dataStore.createSession(for: skill2) // Different skill
        dataStore.completeSession(session3, endTime: today.addingTimeInterval(60), pausedDuration: 0)

        dataStore.save()

        #expect(viewModel.todaysSkillCount() == 2) // Only 2 unique skills
    }

    // MARK: - Statistics Edge Case Behaviors

    @Test("Today's total seconds accumulates multiple sessions for same skill")
    func testTodaysTotalSecondsAccumulatesMultipleSessions() {
        let dataStore = SwiftDataStore.inMemory()
        guard let defaults = UserDefaults(suiteName: UUID().uuidString) else {
            Issue.record("Failed to create test UserDefaults")
            return
        }
        let paletteManager = ColorPaletteManager(defaults: defaults)
        let viewModel = AppViewModel(dataStore: dataStore, colorPaletteManager: paletteManager)

        let skill = dataStore.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        // Create three 60-second sessions
        let now = Date()
        for i in 0..<3 {
            let session = dataStore.createSession(for: skill)
            session.startTime = now.addingTimeInterval(Double(i * 100))
            dataStore.completeSession(session, endTime: session.startTime.addingTimeInterval(60), pausedDuration: 0)
        }
        dataStore.save()

        #expect(viewModel.todaysTotalSeconds() == 180) // 3 × 60 seconds
    }

    @Test("Today's total seconds excludes paused duration")
    func testTodaysTotalSecondsExcludesPausedDuration() {
        let dataStore = SwiftDataStore.inMemory()
        guard let defaults = UserDefaults(suiteName: UUID().uuidString) else {
            Issue.record("Failed to create test UserDefaults")
            return
        }
        let paletteManager = ColorPaletteManager(defaults: defaults)
        let viewModel = AppViewModel(dataStore: dataStore, colorPaletteManager: paletteManager)

        let skill = dataStore.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        // Create a 120-second session with 30 seconds paused
        let now = Date()
        let session = dataStore.createSession(for: skill)
        session.startTime = now
        dataStore.completeSession(session, endTime: now.addingTimeInterval(120), pausedDuration: 30)
        dataStore.save()

        #expect(viewModel.todaysTotalSeconds() == 90) // 120 - 30 = 90 seconds
    }

    @Test("Today's total seconds excludes yesterday's sessions")
    func testTodaysTotalSecondsExcludesYesterday() {
        let dataStore = SwiftDataStore.inMemory()
        guard let defaults = UserDefaults(suiteName: UUID().uuidString) else {
            Issue.record("Failed to create test UserDefaults")
            return
        }
        let paletteManager = ColorPaletteManager(defaults: defaults)
        let viewModel = AppViewModel(dataStore: dataStore, colorPaletteManager: paletteManager)

        let skill = dataStore.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())

        // Yesterday's session (should be excluded)
        let yesterdaySession = dataStore.createSession(for: skill)
        yesterdaySession.startTime = startOfToday.addingTimeInterval(-3600) // 1 hour before midnight
        dataStore.completeSession(yesterdaySession, endTime: yesterdaySession.startTime.addingTimeInterval(1000), pausedDuration: 0)

        // Today's session (should be included)
        let todaySession = dataStore.createSession(for: skill)
        todaySession.startTime = startOfToday.addingTimeInterval(3600) // 1 hour after midnight
        dataStore.completeSession(todaySession, endTime: todaySession.startTime.addingTimeInterval(60), pausedDuration: 0)

        dataStore.save()

        #expect(viewModel.todaysTotalSeconds() == 60) // Only today's 60 seconds
    }

    @Test("Today's skill count excludes yesterday's sessions")
    func testTodaysSkillCountExcludesYesterday() {
        let dataStore = SwiftDataStore.inMemory()
        guard let defaults = UserDefaults(suiteName: UUID().uuidString) else {
            Issue.record("Failed to create test UserDefaults")
            return
        }
        let paletteManager = ColorPaletteManager(defaults: defaults)
        let viewModel = AppViewModel(dataStore: dataStore, colorPaletteManager: paletteManager)

        let skill1 = dataStore.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        let skill2 = dataStore.createSkill(name: "Python", paletteId: Self.testPaletteId, colorIndex: 1)

        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())

        // Yesterday's session for skill1 (should be excluded)
        let yesterdaySession = dataStore.createSession(for: skill1)
        yesterdaySession.startTime = startOfToday.addingTimeInterval(-3600)
        dataStore.completeSession(yesterdaySession, endTime: yesterdaySession.startTime.addingTimeInterval(60), pausedDuration: 0)

        // Today's session for skill2 (should be included)
        let todaySession = dataStore.createSession(for: skill2)
        todaySession.startTime = startOfToday.addingTimeInterval(3600)
        dataStore.completeSession(todaySession, endTime: todaySession.startTime.addingTimeInterval(60), pausedDuration: 0)

        dataStore.save()

        #expect(viewModel.todaysSkillCount() == 1) // Only skill2 practiced today
    }

    @Test("Today's total seconds handles sessions across multiple skills")
    func testTodaysTotalSecondsAcrossMultipleSkills() {
        let dataStore = SwiftDataStore.inMemory()
        guard let defaults = UserDefaults(suiteName: UUID().uuidString) else {
            Issue.record("Failed to create test UserDefaults")
            return
        }
        let paletteManager = ColorPaletteManager(defaults: defaults)
        let viewModel = AppViewModel(dataStore: dataStore, colorPaletteManager: paletteManager)

        let skill1 = dataStore.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        let skill2 = dataStore.createSkill(name: "Python", paletteId: Self.testPaletteId, colorIndex: 1)
        let skill3 = dataStore.createSkill(name: "Rust", paletteId: Self.testPaletteId, colorIndex: 2)

        let now = Date()

        // Create sessions for each skill
        let session1 = dataStore.createSession(for: skill1)
        session1.startTime = now
        dataStore.completeSession(session1, endTime: now.addingTimeInterval(100), pausedDuration: 0)

        let session2 = dataStore.createSession(for: skill2)
        session2.startTime = now.addingTimeInterval(200)
        dataStore.completeSession(session2, endTime: session2.startTime.addingTimeInterval(200), pausedDuration: 50)

        let session3 = dataStore.createSession(for: skill3)
        session3.startTime = now.addingTimeInterval(500)
        dataStore.completeSession(session3, endTime: session3.startTime.addingTimeInterval(300), pausedDuration: 0)

        dataStore.save()

        // 100 + (200 - 50) + 300 = 550 seconds
        #expect(viewModel.todaysTotalSeconds() == 550)
    }
}
