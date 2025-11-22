//
//  AppViewModelTests.swift
//  TenThousandTests
//
//  Unit tests for AppViewModel
//  Testing behaviors, not implementations
//

import Testing
import Foundation
@testable import TenThousand

@Suite("AppViewModel Behaviors", .serialized)
struct AppViewModelTests {

    // MARK: - Test Helpers

    /// Creates a fresh AppViewModel with in-memory persistence for each test
    func makeViewModel() -> AppViewModel {
        let dataStore = SwiftDataStore.inMemory()
        return AppViewModel(dataStore: dataStore)
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

    @Test("Creating skills assigns different color indices")
    func testCreateSkillsAssignsDifferentColors() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Skill 1")
        viewModel.createSkill(name: "Skill 2")
        viewModel.createSkill(name: "Skill 3")

        #expect(viewModel.skills.count == 3)
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

        let skill = viewModel.skills.first!
        viewModel.deleteSkill(skill)

        #expect(viewModel.skills.isEmpty)
    }

    @Test("Deleting one skill keeps others intact")
    func testDeleteSkillKeepsOthers() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        viewModel.createSkill(name: "Python")
        viewModel.createSkill(name: "JavaScript")

        let skillToDelete = viewModel.skills.first { $0.name == "Python" }!
        viewModel.deleteSkill(skillToDelete)

        #expect(viewModel.skills.count == 2)
        #expect(!viewModel.skills.contains { $0.name == "Python" })
        #expect(viewModel.skills.contains { $0.name == "Swift" })
        #expect(viewModel.skills.contains { $0.name == "JavaScript" })
    }

    // MARK: - Session Management Behaviors

    @Test("Starting tracking creates an active session")
    func testStartTrackingCreatesSession() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        let skill = viewModel.skills.first!

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

        let skill1 = viewModel.skills.first { $0.name == "Swift" }!
        let skill2 = viewModel.skills.first { $0.name == "Python" }!

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
        let skill = viewModel.skills.first!

        viewModel.startTracking(skill: skill)
        viewModel.pauseTracking()

        #expect(viewModel.timerManager.isPaused)
    }

    @Test("Resuming tracking resumes the timer")
    func testResumeTrackingResumesTimer() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        let skill = viewModel.skills.first!

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
        let skill = viewModel.skills.first!

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
        let skill = viewModel.skills.first!

        viewModel.startTracking(skill: skill)
        viewModel.stopTracking()

        // Session should have been saved - verify through skill's sessions
        #expect(skill.sessions.count == 1)
    }

    @Test("Stopping tracking sets justUpdatedSkillId temporarily")
    func testStopTrackingSetsUpdatedSkillId() {
        let viewModel = makeViewModel()

        viewModel.createSkill(name: "Swift")
        let skill = viewModel.skills.first!

        viewModel.startTracking(skill: skill)
        viewModel.stopTracking()

        #expect(viewModel.justUpdatedSkillId == skill.id)
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
        let viewModel = AppViewModel(dataStore: dataStore)

        // Create skills via dataStore
        let skill1 = dataStore.createSkill(name: "Swift", colorIndex: 0)
        let skill2 = dataStore.createSkill(name: "Python", colorIndex: 1)

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

}
