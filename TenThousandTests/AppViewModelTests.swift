//
//  AppViewModelTests.swift
//  TenThousandTests
//
//  Unit tests for AppViewModel
//  Testing behaviors, not implementations
//

import Testing
import CoreData
@testable import TenThousand

@Suite("AppViewModel Behaviors")
struct AppViewModelTests {

    // MARK: - Test Helpers

    /// Creates a fresh AppViewModel with in-memory persistence for each test
    func makeViewModel() -> AppViewModel {
        let persistence = PersistenceController(inMemory: true)
        return AppViewModel(persistenceController: persistence)
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

    @Test("Creating skill resets isAddingSkill flag")
    func testCreateSkillResetsAddingFlag() {
        let viewModel = makeViewModel()

        viewModel.isAddingSkill = true
        viewModel.createSkill(name: "Swift")

        #expect(!viewModel.isAddingSkill)
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
        #expect(skill.sessions?.count == 1)
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
        let viewModel = makeViewModel()
        let context = viewModel.persistenceController.container.viewContext

        // Create skills
        let skill1 = Skill(context: context, name: "Swift")
        let skill2 = Skill(context: context, name: "Python")

        // Create sessions for today
        let today = Date()
        let session1 = Session(context: context, skill: skill1)
        session1.startTime = today
        session1.endTime = today.addingTimeInterval(60)

        let session2 = Session(context: context, skill: skill1) // Same skill
        session2.startTime = today
        session2.endTime = today.addingTimeInterval(60)

        let session3 = Session(context: context, skill: skill2) // Different skill
        session3.startTime = today
        session3.endTime = today.addingTimeInterval(60)

        viewModel.persistenceController.save()

        #expect(viewModel.todaysSkillCount() == 2) // Only 2 unique skills
    }

    // MARK: - Heatmap Level Behaviors

    @Test("Heatmap level for zero seconds is zero")
    func testHeatmapLevelZero() {
        let viewModel = makeViewModel()

        #expect(viewModel.heatmapLevel(for: 0) == 0)
    }

    @Test("Heatmap level for less than 15 minutes is level 1")
    func testHeatmapLevelOne() {
        let viewModel = makeViewModel()

        #expect(viewModel.heatmapLevel(for: 60) == 1) // 1 minute
        #expect(viewModel.heatmapLevel(for: 600) == 1) // 10 minutes
        #expect(viewModel.heatmapLevel(for: 840) == 1) // 14 minutes
    }

    @Test("Heatmap level for 15-29 minutes is level 2")
    func testHeatmapLevelTwo() {
        let viewModel = makeViewModel()

        #expect(viewModel.heatmapLevel(for: 900) == 2) // 15 minutes
        #expect(viewModel.heatmapLevel(for: 1200) == 2) // 20 minutes
        #expect(viewModel.heatmapLevel(for: 1740) == 2) // 29 minutes
    }

    @Test("Heatmap level for 30-59 minutes is level 3")
    func testHeatmapLevelThree() {
        let viewModel = makeViewModel()

        #expect(viewModel.heatmapLevel(for: 1800) == 3) // 30 minutes
        #expect(viewModel.heatmapLevel(for: 2700) == 3) // 45 minutes
        #expect(viewModel.heatmapLevel(for: 3540) == 3) // 59 minutes
    }

    @Test("Heatmap level for 60-119 minutes is level 4")
    func testHeatmapLevelFour() {
        let viewModel = makeViewModel()

        #expect(viewModel.heatmapLevel(for: 3600) == 4) // 60 minutes
        #expect(viewModel.heatmapLevel(for: 5400) == 4) // 90 minutes
        #expect(viewModel.heatmapLevel(for: 7140) == 4) // 119 minutes
    }

    @Test("Heatmap level for 120-179 minutes is level 5")
    func testHeatmapLevelFive() {
        let viewModel = makeViewModel()

        #expect(viewModel.heatmapLevel(for: 7200) == 5) // 120 minutes
        #expect(viewModel.heatmapLevel(for: 9000) == 5) // 150 minutes
        #expect(viewModel.heatmapLevel(for: 10740) == 5) // 179 minutes
    }

    @Test("Heatmap level for 180+ minutes is level 6")
    func testHeatmapLevelSix() {
        let viewModel = makeViewModel()

        #expect(viewModel.heatmapLevel(for: 10800) == 6) // 180 minutes
        #expect(viewModel.heatmapLevel(for: 18000) == 6) // 300 minutes
        #expect(viewModel.heatmapLevel(for: 36000) == 6) // 600 minutes
    }

    @Test("Heatmap level boundary values are correct")
    func testHeatmapLevelBoundaries() {
        let viewModel = makeViewModel()

        // Just below level 1 threshold (15 min = 900 sec)
        #expect(viewModel.heatmapLevel(for: 899) == 1)
        #expect(viewModel.heatmapLevel(for: 900) == 2)

        // Just below level 2 threshold (30 min = 1800 sec)
        #expect(viewModel.heatmapLevel(for: 1799) == 2)
        #expect(viewModel.heatmapLevel(for: 1800) == 3)

        // Just below level 3 threshold (60 min = 3600 sec)
        #expect(viewModel.heatmapLevel(for: 3599) == 3)
        #expect(viewModel.heatmapLevel(for: 3600) == 4)

        // Just below level 4 threshold (120 min = 7200 sec)
        #expect(viewModel.heatmapLevel(for: 7199) == 4)
        #expect(viewModel.heatmapLevel(for: 7200) == 5)

        // Just below level 5 threshold (180 min = 10800 sec)
        #expect(viewModel.heatmapLevel(for: 10799) == 5)
        #expect(viewModel.heatmapLevel(for: 10800) == 6)
    }

    // MARK: - Heatmap Data Behaviors

    @Test("Heatmap data with no sessions returns all zeros")
    func testHeatmapDataNoSessions() {
        let viewModel = makeViewModel()

        let heatmap = viewModel.heatmapData(weeksBack: 4)

        #expect(heatmap.count == 4)
        #expect(heatmap.allSatisfy { $0.count == 7 })
        #expect(heatmap.flatMap { $0 }.allSatisfy { $0 == 0 })
    }

    @Test("Heatmap data has correct structure")
    func testHeatmapDataStructure() {
        let viewModel = makeViewModel()

        let heatmap = viewModel.heatmapData(weeksBack: 4)

        #expect(heatmap.count == 4) // 4 weeks
        heatmap.forEach { week in
            #expect(week.count == 7) // 7 days per week
        }
    }

    @Test("Heatmap data with different weeks back has correct structure")
    func testHeatmapDataDifferentWeeksBack() {
        let viewModel = makeViewModel()

        let heatmap2 = viewModel.heatmapData(weeksBack: 2)
        #expect(heatmap2.count == 2)

        let heatmap8 = viewModel.heatmapData(weeksBack: 8)
        #expect(heatmap8.count == 8)
    }
}
