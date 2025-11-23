//
//  DataModelTests.swift
//  TenThousandTests
//
//  Unit tests for Skill and Session data models
//  Testing behaviors, not implementations
//

import Foundation
import SwiftData
@testable import TenThousand
import Testing

@Suite("Skill Model Behaviors", .serialized)
struct SkillModelTests {
    // MARK: - Test Helpers

    static let testPaletteId = ColorPalette.summerOceanBreeze.id

    func makeStore() -> SwiftDataStore {
        SwiftDataStore.inMemory()
    }

    // MARK: - Skill Initialization Behaviors

    @Test("Creating a skill sets all required properties")
    func testSkillCreationSetsProperties() {
        let store = makeStore()

        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 3)

        #expect(skill.name == "Swift")
        #expect(skill.paletteId == Self.testPaletteId)
        #expect(skill.colorIndex == 3)
        #expect(skill.id != nil)
        #expect(skill.createdAt != nil)
    }

    @Test("Creating a skill generates unique IDs")
    func testSkillCreationGeneratesUniqueIds() {
        let store = makeStore()

        let skill1 = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        let skill2 = store.createSkill(name: "Python", paletteId: Self.testPaletteId, colorIndex: 1)

        #expect(skill1.id != skill2.id)
    }

    @Test("Creating a skill sets creation timestamp")
    func testSkillCreationSetsTimestamp() {
        let beforeCreation = Date()

        let skill = Skill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let afterCreation = Date()

        #expect(skill.createdAt >= beforeCreation)
        #expect(skill.createdAt <= afterCreation)
    }

    // MARK: - Skill totalSeconds Behaviors

    @Test("Skill with no sessions has zero total seconds")
    func testSkillTotalSecondsNoSessions() {
        let skill = Skill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        #expect(skill.totalSeconds == 0)
    }

    @Test("Skill with one session calculates total seconds correctly")
    func testSkillTotalSecondsOneSession() {
        let store = makeStore()

        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        let session = store.createSession(for: skill)
        session.startTime = Date()
        session.endTime = Date().addingTimeInterval(3600) // 1 hour
        session.pausedDuration = 0

        #expect(skill.totalSeconds == 3600)
    }

    @Test("Skill with multiple sessions sums total seconds")
    func testSkillTotalSecondsMultipleSessions() {
        let store = makeStore()

        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let session1 = store.createSession(for: skill)
        session1.startTime = Date()
        session1.endTime = Date().addingTimeInterval(1800) // 30 minutes
        session1.pausedDuration = 0

        let session2 = store.createSession(for: skill)
        session2.startTime = Date()
        session2.endTime = Date().addingTimeInterval(1200) // 20 minutes
        session2.pausedDuration = 0

        #expect(skill.totalSeconds == 3000) // 30 + 20 minutes
    }

    @Test("Skill total seconds excludes paused duration")
    func testSkillTotalSecondsExcludesPausedDuration() {
        let store = makeStore()

        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        let session = store.createSession(for: skill)
        session.startTime = Date()
        session.endTime = Date().addingTimeInterval(3600) // 1 hour
        session.pausedDuration = 600 // 10 minutes paused

        #expect(skill.totalSeconds == 3000) // 60 - 10 minutes
    }

    @Test("Skill total seconds handles multiple sessions with pauses")
    func testSkillTotalSecondsMultipleSessionsWithPauses() {
        let store = makeStore()

        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let session1 = store.createSession(for: skill)
        session1.startTime = Date()
        session1.endTime = Date().addingTimeInterval(1800) // 30 minutes
        session1.pausedDuration = 300 // 5 minutes paused

        let session2 = store.createSession(for: skill)
        session2.startTime = Date()
        session2.endTime = Date().addingTimeInterval(1200) // 20 minutes
        session2.pausedDuration = 200 // 3.33 minutes paused

        // Session 1: 1800 - 300 = 1500
        // Session 2: 1200 - 200 = 1000
        // Total: 2500
        #expect(skill.totalSeconds == 2500)
    }
}

@Suite("Session Model Behaviors", .serialized)
struct SessionModelTests {
    // MARK: - Test Helpers

    static let testPaletteId = ColorPalette.summerOceanBreeze.id

    func makeStore() -> SwiftDataStore {
        SwiftDataStore.inMemory()
    }

    // MARK: - Session Initialization Behaviors

    @Test("Creating a session sets all required properties")
    func testSessionCreationSetsProperties() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let session = store.createSession(for: skill)

        #expect(session.skill === skill)
        #expect(session.id != nil)
        #expect(session.startTime != nil)
        #expect(session.pausedDuration == 0)
        #expect(session.endTime == nil)
    }

    @Test("Creating a session generates unique IDs")
    func testSessionCreationGeneratesUniqueIds() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let session1 = store.createSession(for: skill)
        let session2 = store.createSession(for: skill)

        #expect(session1.id != session2.id)
    }

    @Test("Creating a session sets start time to now")
    func testSessionCreationSetsStartTime() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        let beforeCreation = Date()

        let session = store.createSession(for: skill)

        let afterCreation = Date()

        #expect(session.startTime >= beforeCreation)
        #expect(session.startTime <= afterCreation)
    }

    // MARK: - Session durationSeconds Behaviors

    @Test("Session without end time uses current time for duration")
    func testSessionDurationWithoutEndTime() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let session = store.createSession(for: skill)
        session.startTime = Date().addingTimeInterval(-3600) // Started 1 hour ago
        session.pausedDuration = 0

        let duration = session.durationSeconds

        // Should be approximately 3600 seconds (allowing for small timing differences)
        #expect(duration >= 3590)
        #expect(duration <= 3610)
    }

    @Test("Session with end time calculates exact duration")
    func testSessionDurationWithEndTime() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let session = store.createSession(for: skill)
        let startTime = Date()
        session.startTime = startTime
        session.endTime = startTime.addingTimeInterval(1800) // 30 minutes
        session.pausedDuration = 0

        #expect(session.durationSeconds == 1800)
    }

    @Test("Session duration excludes paused time")
    func testSessionDurationExcludesPausedTime() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let session = store.createSession(for: skill)
        let startTime = Date()
        session.startTime = startTime
        session.endTime = startTime.addingTimeInterval(3600) // 1 hour
        session.pausedDuration = 600 // 10 minutes paused

        #expect(session.durationSeconds == 3000) // 60 - 10 minutes
    }

    @Test("Session with only paused time returns correct duration")
    func testSessionDurationOnlyPausedTime() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let session = store.createSession(for: skill)
        let startTime = Date()
        session.startTime = startTime
        session.endTime = startTime.addingTimeInterval(600)
        session.pausedDuration = 600 // Entire time paused

        #expect(session.durationSeconds == 0)
    }

    @Test("Session duration is never negative")
    func testSessionDurationNeverNegative() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let session = store.createSession(for: skill)
        let startTime = Date()
        session.startTime = startTime
        session.endTime = startTime.addingTimeInterval(600)
        session.pausedDuration = 1200 // Paused longer than session (edge case)

        // Duration should not be negative
        #expect(session.durationSeconds >= 0)
    }

    @Test("Session duration calculations are consistent")
    func testSessionDurationConsistency() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let session = store.createSession(for: skill)
        let startTime = Date()
        session.startTime = startTime
        session.endTime = startTime.addingTimeInterval(7200) // 2 hours
        session.pausedDuration = 900 // 15 minutes

        // Calculate expected: 7200 - 900 = 6300
        let duration1 = session.durationSeconds
        let duration2 = session.durationSeconds

        #expect(duration1 == 6300)
        #expect(duration1 == duration2) // Should be consistent
    }

    // MARK: - Session-Skill Relationship Behaviors

    @Test("Session belongs to the correct skill")
    func testSessionBelongsToSkill() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let session = store.createSession(for: skill)

        #expect(session.skill === skill)
    }

    @Test("Skill contains its sessions")
    func testSkillContainsSessions() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let session1 = store.createSession(for: skill)
        let session2 = store.createSession(for: skill)

        #expect(skill.sessions.count == 2)
        #expect(skill.sessions.contains { $0 === session1 })
        #expect(skill.sessions.contains { $0 === session2 })
    }

    @Test("Multiple skills can have different sessions")
    func testMultipleSkillsHaveDifferentSessions() {
        let store = makeStore()
        let skill1 = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        let skill2 = store.createSkill(name: "Python", paletteId: Self.testPaletteId, colorIndex: 1)

        let session1 = store.createSession(for: skill1)
        let session2 = store.createSession(for: skill2)

        #expect(skill1.sessions.count == 1)
        #expect(skill2.sessions.count == 1)
        #expect(skill1.sessions.contains { $0 === session1 })
        #expect(skill2.sessions.contains { $0 === session2 })
    }
}
