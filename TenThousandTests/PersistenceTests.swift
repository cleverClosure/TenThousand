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
