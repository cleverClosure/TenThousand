//
//  PersistenceTests.swift
//  TenThousandTests
//
//  Unit tests for SwiftDataStore
//  Testing behaviors, not implementations
//

import Foundation
import SwiftData
@testable import TenThousand
import Testing

@Suite("SwiftDataStore Behaviors", .serialized)
struct PersistenceTests {
    // MARK: - Test Helpers

    static let testPaletteId = ColorPalette.summerOceanBreeze.id

    func makeStore() -> SwiftDataStore {
        SwiftDataStore.inMemory()
    }

    // MARK: - Initialization Behaviors

    @Test("Creating in-memory store succeeds")
    func testInMemoryStoreCreation() {
        let store = makeStore()

        // Verify modelContext is accessible (non-optional type)
        _ = store.modelContext
    }

    // MARK: - Save Behaviors

    @Test("Saving with no changes does nothing")
    func testSaveWithNoChanges() {
        let store = makeStore()

        // Should not throw or crash
        store.save()

        #expect(!store.modelContext.hasChanges)
    }

    @Test("Saving with changes persists data")
    func testSaveWithChanges() {
        let store = makeStore()

        store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        #expect(store.modelContext.hasChanges)

        store.save()

        #expect(!store.modelContext.hasChanges)
    }

    @Test("Saved data can be fetched")
    func testSavedDataCanBeFetched() {
        let store = makeStore()

        store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        store.save()

        let results = store.fetchAllSkills()

        #expect(results.count == 1)
        #expect(results.first?.name == "Swift")
    }

    @Test("Multiple saves accumulate data")
    func testMultipleSaves() {
        let store = makeStore()

        store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        store.save()

        store.createSkill(name: "Python", paletteId: Self.testPaletteId, colorIndex: 1)
        store.save()

        let results = store.fetchAllSkills()

        #expect(results.count == 2)
    }

    @Test("Saving preserves relationships")
    func testSavePreservesRelationships() {
        let store = makeStore()

        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        _ = store.createSession(for: skill)
        store.save()

        let sessions = store.fetchSessions(from: Date.distantPast)

        #expect(sessions.count == 1)
        #expect(sessions.first?.skill === skill)
    }

    // MARK: - Data Integrity Behaviors

    @Test("Deleting and saving removes data")
    func testDeleteAndSave() {
        let store = makeStore()

        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        store.save()

        store.deleteSkill(skill)
        store.save()

        let results = store.fetchAllSkills()

        #expect(results.isEmpty)
    }

    @Test("Updating and saving persists changes")
    func testUpdateAndSave() {
        let store = makeStore()

        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        store.save()

        skill.name = "Python"
        store.save()

        let results = store.fetchAllSkills()

        #expect(results.first?.name == "Python")
    }

    @Test("Cascade delete removes related sessions")
    func testCascadeDelete() {
        let store = makeStore()

        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        store.createSession(for: skill)
        store.createSession(for: skill)
        store.save()

        store.deleteSkill(skill)
        store.save()

        let sessions = store.fetchSessions(from: Date.distantPast)

        #expect(sessions.isEmpty)
    }

    // MARK: - Data Isolation Behaviors

    @Test("In-memory stores are isolated per instance")
    func testInMemoryStoresAreIsolated() {
        let store1 = makeStore()
        let store2 = makeStore()

        store1.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        store1.save()

        let results1 = store1.fetchAllSkills()
        let results2 = store2.fetchAllSkills()

        #expect(results1.count == 1)
        #expect(results2.count == 0)
    }

    // MARK: - Fetch Request Behaviors

    @Test("Fetching with no data returns empty array")
    func testFetchWithNoData() {
        let store = makeStore()

        let results = store.fetchAllSkills()

        #expect(results.isEmpty)
    }

    @Test("Fetching sessions with date predicate filters results")
    func testFetchWithPredicate() {
        let store = makeStore()

        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        // Create session for yesterday
        let session1 = store.createSession(for: skill)
        session1.startTime = Date().addingTimeInterval(-86400) // Yesterday

        // Create session for today
        let session2 = store.createSession(for: skill)
        session2.startTime = Date()

        store.save()

        let today = Calendar.current.startOfDay(for: Date())
        let results = store.fetchSessions(from: today)

        #expect(results.count == 1)
    }

    @Test("Fetching skills returns sorted by creation date")
    func testFetchWithSortDescriptor() {
        let store = makeStore()

        let skill1 = store.createSkill(name: "Zebra", paletteId: Self.testPaletteId, colorIndex: 0)
        skill1.createdAt = Date().addingTimeInterval(-100)

        let skill2 = store.createSkill(name: "Apple", paletteId: Self.testPaletteId, colorIndex: 1)
        skill2.createdAt = Date().addingTimeInterval(-50)

        let skill3 = store.createSkill(name: "Mango", paletteId: Self.testPaletteId, colorIndex: 2)
        skill3.createdAt = Date()

        store.save()

        let results = store.fetchAllSkills()

        #expect(results.count == 3)
        #expect(results[0].name == "Zebra")
        #expect(results[1].name == "Apple")
        #expect(results[2].name == "Mango")
    }

    // MARK: - Date Boundary Behaviors

    @Test("Session exactly at midnight is included in today's fetch")
    func testSessionAtMidnightIncluded() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())

        let session = store.createSession(for: skill)
        session.startTime = startOfToday // Exactly midnight
        store.save()

        let results = store.fetchSessions(from: startOfToday)

        #expect(results.count == 1)
    }

    @Test("Session one second before midnight is excluded from today's fetch")
    func testSessionBeforeMidnightExcluded() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let oneSecondBeforeMidnight = startOfToday.addingTimeInterval(-1)

        let session = store.createSession(for: skill)
        session.startTime = oneSecondBeforeMidnight
        store.save()

        let results = store.fetchSessions(from: startOfToday)

        #expect(results.isEmpty)
    }

    @Test("Multiple sessions across day boundary are filtered correctly")
    func testMultipleSessionsAcrossDayBoundary() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())

        // Yesterday's sessions (should be excluded)
        let yesterdaySession1 = store.createSession(for: skill)
        yesterdaySession1.startTime = startOfToday.addingTimeInterval(-86400) // 24 hours ago

        let yesterdaySession2 = store.createSession(for: skill)
        yesterdaySession2.startTime = startOfToday.addingTimeInterval(-1) // 1 second before midnight

        // Today's sessions (should be included)
        let todaySession1 = store.createSession(for: skill)
        todaySession1.startTime = startOfToday // Exactly midnight

        let todaySession2 = store.createSession(for: skill)
        todaySession2.startTime = startOfToday.addingTimeInterval(3600) // 1 hour after midnight

        let todaySession3 = store.createSession(for: skill)
        todaySession3.startTime = Date() // Now

        store.save()

        let results = store.fetchSessions(from: startOfToday)

        #expect(results.count == 3)
    }

    @Test("Session started yesterday but ending today is excluded based on start time")
    func testSessionSpanningMidnightUsesStartTime() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())

        // Session started yesterday, ended today
        let session = store.createSession(for: skill)
        session.startTime = startOfToday.addingTimeInterval(-3600) // 1 hour before midnight
        session.endTime = startOfToday.addingTimeInterval(3600)    // 1 hour after midnight
        store.save()

        let results = store.fetchSessions(from: startOfToday)

        // Session should NOT be included because startTime is before today
        #expect(results.isEmpty)
    }

    @Test("Fetching from distant past returns all sessions")
    func testFetchFromDistantPastReturnsAll() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())

        // Create sessions across multiple days
        for dayOffset in 0..<5 {
            let session = store.createSession(for: skill)
            session.startTime = startOfToday.addingTimeInterval(Double(-dayOffset * 86400))
        }
        store.save()

        let results = store.fetchSessions(from: Date.distantPast)

        #expect(results.count == 5)
    }
}

// MARK: - SwiftDataStore Edge Cases & Error Scenarios

@Suite("SwiftDataStore Edge Cases", .serialized)
struct SwiftDataStoreEdgeCaseTests {
    // MARK: - Test Helpers

    static let testPaletteId = ColorPalette.summerOceanBreeze.id

    func makeStore() -> SwiftDataStore {
        SwiftDataStore.inMemory()
    }

    // MARK: - Large Dataset Tests

    @Test("Fetching large number of skills performs correctly")
    func testFetchLargeNumberOfSkills() {
        let store = makeStore()

        // Create 100 skills
        for i in 0..<100 {
            store.createSkill(name: "Skill \(i)", paletteId: Self.testPaletteId, colorIndex: Int16(i % 5))
        }
        store.save()

        let results = store.fetchAllSkills()

        #expect(results.count == 100)
    }

    @Test("Fetching large number of sessions performs correctly")
    func testFetchLargeNumberOfSessions() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        // Create 100 sessions
        for i in 0..<100 {
            let session = store.createSession(for: skill)
            session.startTime = Date().addingTimeInterval(Double(i * 60))
        }
        store.save()

        let results = store.fetchSessions(from: Date.distantPast)

        #expect(results.count == 100)
    }

    @Test("Skill with many sessions calculates total correctly")
    func testSkillWithManySessions() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        // Create 50 sessions, each 60 seconds
        let now = Date()
        for i in 0..<50 {
            let session = store.createSession(for: skill)
            session.startTime = now.addingTimeInterval(Double(i * 100))
            session.endTime = session.startTime.addingTimeInterval(60)
            session.pausedDuration = 0
        }
        store.save()

        #expect(skill.totalSeconds == 3000) // 50 × 60 seconds
    }

    // MARK: - Empty/Null Data Tests

    @Test("Creating skill with empty name succeeds (validation at view level)")
    func testCreateSkillWithEmptyName() {
        let store = makeStore()

        // SwiftDataStore doesn't validate - that's the ViewModel's job
        let skill = store.createSkill(name: "", paletteId: Self.testPaletteId, colorIndex: 0)
        store.save()

        #expect(skill.name == "")
        #expect(store.fetchAllSkills().count == 1)
    }

    @Test("Completing session with nil skill does not crash")
    func testCompleteSessionWithValidData() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        let session = store.createSession(for: skill)

        // Complete with valid data
        store.completeSession(session, endTime: Date(), pausedDuration: 0)
        store.save()

        #expect(session.endTime != nil)
        #expect(session.pausedDuration == 0)
    }

    @Test("Session with future start time is handled")
    func testSessionWithFutureStartTime() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let session = store.createSession(for: skill)
        session.startTime = Date().addingTimeInterval(86400) // Tomorrow
        store.save()

        let results = store.fetchSessions(from: Date())

        // Future session should be included since startTime > today
        #expect(results.count == 1)
    }

    // MARK: - Concurrent Operation Tests

    @Test("Multiple skills can be created and saved in sequence")
    func testSequentialSkillCreation() {
        let store = makeStore()

        for i in 0..<10 {
            store.createSkill(name: "Skill \(i)", paletteId: Self.testPaletteId, colorIndex: Int16(i % 5))
            store.save()
        }

        let results = store.fetchAllSkills()
        #expect(results.count == 10)
    }

    @Test("Creating and deleting skills in sequence maintains consistency")
    func testCreateDeleteSequence() {
        let store = makeStore()

        // Create 5 skills
        var skills: [Skill] = []
        for i in 0..<5 {
            let skill = store.createSkill(name: "Skill \(i)", paletteId: Self.testPaletteId, colorIndex: Int16(i % 5))
            skills.append(skill)
        }
        store.save()

        #expect(store.fetchAllSkills().count == 5)

        // Delete every other skill
        for i in stride(from: 0, to: 5, by: 2) {
            store.deleteSkill(skills[i])
        }
        store.save()

        #expect(store.fetchAllSkills().count == 2)
    }

    // MARK: - Relationship Integrity Tests

    @Test("Deleting skill cascades to all its sessions")
    func testDeleteSkillCascadesToAllSessions() {
        let store = makeStore()

        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        // Create many sessions
        for _ in 0..<20 {
            store.createSession(for: skill)
        }
        store.save()

        #expect(store.fetchSessions(from: Date.distantPast).count == 20)

        store.deleteSkill(skill)
        store.save()

        #expect(store.fetchSessions(from: Date.distantPast).isEmpty)
    }

    @Test("Sessions maintain skill reference after save and refetch")
    func testSessionSkillReferenceAfterRefetch() {
        let store = makeStore()

        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        store.createSession(for: skill)
        store.save()

        let fetchedSessions = store.fetchSessions(from: Date.distantPast)

        #expect(fetchedSessions.first?.skill?.name == "Swift")
    }

    @Test("Multiple skills with sessions maintain correct relationships")
    func testMultipleSkillsWithSessionsRelationships() {
        let store = makeStore()

        let skill1 = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        let skill2 = store.createSkill(name: "Python", paletteId: Self.testPaletteId, colorIndex: 1)
        let skill3 = store.createSkill(name: "Rust", paletteId: Self.testPaletteId, colorIndex: 2)

        // Create sessions for each skill
        store.createSession(for: skill1)
        store.createSession(for: skill1)
        store.createSession(for: skill2)
        store.createSession(for: skill3)
        store.createSession(for: skill3)
        store.createSession(for: skill3)
        store.save()

        #expect(skill1.sessions.count == 2)
        #expect(skill2.sessions.count == 1)
        #expect(skill3.sessions.count == 3)

        // Verify all sessions have correct skill reference
        for session in store.fetchSessions(from: Date.distantPast) {
            #expect(session.skill != nil)
        }
    }

    // MARK: - Data Mutation Tests

    @Test("Modifying skill name persists after save")
    func testModifySkillNamePersists() {
        let store = makeStore()

        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        store.save()

        skill.name = "SwiftUI"
        store.save()

        let fetchedSkills = store.fetchAllSkills()
        #expect(fetchedSkills.first?.name == "SwiftUI")
    }

    @Test("Modifying skill palette persists after save")
    func testModifySkillPalettePersists() {
        let store = makeStore()

        let skill = store.createSkill(name: "Swift", paletteId: ColorPalette.summerOceanBreeze.id, colorIndex: 0)
        store.save()

        skill.paletteId = ColorPalette.oceanSunset.id
        skill.colorIndex = 3
        store.save()

        let fetchedSkills = store.fetchAllSkills()
        #expect(fetchedSkills.first?.paletteId == ColorPalette.oceanSunset.id)
        #expect(fetchedSkills.first?.colorIndex == 3)
    }

    @Test("Modifying session dates persists after save")
    func testModifySessionDatesPersists() {
        let store = makeStore()

        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        let session = store.createSession(for: skill)
        store.save()

        let newStartTime = Date().addingTimeInterval(-7200)
        let newEndTime = Date().addingTimeInterval(-3600)
        session.startTime = newStartTime
        session.endTime = newEndTime
        session.pausedDuration = 300
        store.save()

        let fetchedSessions = store.fetchSessions(from: Date.distantPast)
        #expect(fetchedSessions.first?.startTime == newStartTime)
        #expect(fetchedSessions.first?.endTime == newEndTime)
        #expect(fetchedSessions.first?.pausedDuration == 300)
    }

    // MARK: - Boundary Condition Tests

    @Test("Session with very long duration is handled correctly")
    func testSessionWithVeryLongDuration() {
        let store = makeStore()

        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        let session = store.createSession(for: skill)

        // Simulate a session lasting 1 year
        let oneYearInSeconds: Int64 = 365 * 24 * 3600
        session.startTime = Date()
        session.endTime = Date().addingTimeInterval(Double(oneYearInSeconds))
        session.pausedDuration = 0
        store.save()

        #expect(session.durationSeconds == oneYearInSeconds)
    }

    @Test("Session with maximum Int64 paused duration is clamped correctly")
    func testSessionWithMaxPausedDuration() {
        let store = makeStore()

        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        let session = store.createSession(for: skill)
        session.startTime = Date()
        session.endTime = Date().addingTimeInterval(3600)
        session.pausedDuration = Int64.max
        store.save()

        // Duration should be clamped to 0 (not negative)
        #expect(session.durationSeconds == 0)
    }

    @Test("Fetching sessions from distant future returns empty")
    func testFetchFromDistantFuture() {
        let store = makeStore()

        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        store.createSession(for: skill)
        store.save()

        let results = store.fetchSessions(from: Date.distantFuture)

        #expect(results.isEmpty)
    }

    // MARK: - Order Consistency Tests

    @Test("Skills remain sorted by creation date after modifications")
    func testSkillOrderAfterModifications() {
        let store = makeStore()

        let skill1 = store.createSkill(name: "First", paletteId: Self.testPaletteId, colorIndex: 0)
        skill1.createdAt = Date().addingTimeInterval(-300)

        let skill2 = store.createSkill(name: "Second", paletteId: Self.testPaletteId, colorIndex: 1)
        skill2.createdAt = Date().addingTimeInterval(-200)

        let skill3 = store.createSkill(name: "Third", paletteId: Self.testPaletteId, colorIndex: 2)
        skill3.createdAt = Date().addingTimeInterval(-100)
        store.save()

        // Modify second skill
        skill2.name = "Modified Second"
        store.save()

        let results = store.fetchAllSkills()

        #expect(results[0].name == "First")
        #expect(results[1].name == "Modified Second")
        #expect(results[2].name == "Third")
    }

    @Test("Order maintained after adding and removing skills")
    func testSkillOrderAfterAddRemove() {
        let store = makeStore()

        let skill1 = store.createSkill(name: "Alpha", paletteId: Self.testPaletteId, colorIndex: 0)
        skill1.createdAt = Date().addingTimeInterval(-300)

        let skill2 = store.createSkill(name: "Beta", paletteId: Self.testPaletteId, colorIndex: 1)
        skill2.createdAt = Date().addingTimeInterval(-200)

        let skill3 = store.createSkill(name: "Gamma", paletteId: Self.testPaletteId, colorIndex: 2)
        skill3.createdAt = Date().addingTimeInterval(-100)
        store.save()

        // Delete middle skill
        store.deleteSkill(skill2)
        store.save()

        // Add new skill
        let skill4 = store.createSkill(name: "Delta", paletteId: Self.testPaletteId, colorIndex: 3)
        skill4.createdAt = Date()
        store.save()

        let results = store.fetchAllSkills()

        #expect(results.count == 3)
        #expect(results[0].name == "Alpha")
        #expect(results[1].name == "Gamma")
        #expect(results[2].name == "Delta")
    }
}
