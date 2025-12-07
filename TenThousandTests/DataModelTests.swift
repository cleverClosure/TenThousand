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
        // Verify id and createdAt are set (non-optional types)
        _ = skill.id
        _ = skill.createdAt
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
        // Verify id and startTime are set (non-optional types)
        _ = session.id
        _ = session.startTime
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

    // MARK: - Duration Edge Case Behaviors

    @Test("Long-running open session calculates duration correctly")
    func testLongRunningOpenSession() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let session = store.createSession(for: skill)
        // Session started 7 days ago and still running
        session.startTime = Date().addingTimeInterval(-7 * 24 * 3600)
        session.pausedDuration = 0

        let expectedSeconds: Int64 = 7 * 24 * 3600
        let duration = session.durationSeconds

        // Should be approximately 7 days worth of seconds
        #expect(duration >= expectedSeconds - 10)
        #expect(duration <= expectedSeconds + 10)
    }

    @Test("Very large completed session duration is accurate")
    func testVeryLargeDuration() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let session = store.createSession(for: skill)
        let startTime = Date()
        // Simulate a 30-day session
        let thirtyDaysInSeconds: Int64 = 30 * 24 * 3600
        session.startTime = startTime
        session.endTime = startTime.addingTimeInterval(Double(thirtyDaysInSeconds))
        session.pausedDuration = 0

        #expect(session.durationSeconds == thirtyDaysInSeconds)
    }

    @Test("Session with very large paused duration is clamped to zero")
    func testVeryLargePausedDuration() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let session = store.createSession(for: skill)
        let startTime = Date()
        session.startTime = startTime
        session.endTime = startTime.addingTimeInterval(3600) // 1 hour
        session.pausedDuration = Int64.max // Extreme edge case

        // Should clamp to 0, not overflow to negative
        #expect(session.durationSeconds == 0)
    }

    @Test("Very short session (sub-second precision) calculates correctly")
    func testSubSecondSession() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let session = store.createSession(for: skill)
        let startTime = Date()
        // Session lasting 0.5 seconds
        session.startTime = startTime
        session.endTime = startTime.addingTimeInterval(0.5)
        session.pausedDuration = 0

        // Int64 truncation should round down to 0
        #expect(session.durationSeconds == 0)
    }

    @Test("Session of exactly one second")
    func testExactlyOneSecondSession() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let session = store.createSession(for: skill)
        let startTime = Date()
        session.startTime = startTime
        session.endTime = startTime.addingTimeInterval(1.0)
        session.pausedDuration = 0

        #expect(session.durationSeconds == 1)
    }

    @Test("Session duration with fractional seconds truncates correctly")
    func testFractionalSecondsTruncation() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let session = store.createSession(for: skill)
        let startTime = Date()
        // 3.9 seconds should truncate to 3
        session.startTime = startTime
        session.endTime = startTime.addingTimeInterval(3.9)
        session.pausedDuration = 0

        #expect(session.durationSeconds == 3)
    }
}

// MARK: - Skill Color Resolution Behaviors

@Suite("Skill Color Resolution Behaviors", .serialized)
struct SkillColorResolutionTests {
    // MARK: - Valid Color Resolution Tests

    @Test("Skill with valid palette and color index resolves to correct color")
    func testValidColorResolution() {
        let skill = Skill(
            name: "Swift",
            paletteId: ColorPalette.summerOceanBreeze.id,
            colorIndex: 0
        )

        let color = skill.color

        // Should not be gray (gray is the fallback)
        #expect(color != .gray)
    }

    @Test("Skill color resolves correctly for each palette")
    func testColorResolutionForEachPalette() {
        for palette in ColorPalette.all {
            let skill = Skill(
                name: "Test",
                paletteId: palette.id,
                colorIndex: 0
            )

            let color = skill.color

            // Each valid palette should resolve to a non-gray color
            #expect(color != .gray, "Palette \(palette.id) should resolve to non-gray color")
        }
    }

    @Test("Skill color resolves correctly for each color index in palette")
    func testColorResolutionForEachColorIndex() {
        let palette = ColorPalette.summerOceanBreeze

        for index in 0..<palette.colorCount {
            let skill = Skill(
                name: "Test",
                paletteId: palette.id,
                colorIndex: Int16(index)
            )

            let color = skill.color

            #expect(color != .gray, "Color index \(index) should resolve to non-gray color")
        }
    }

    // MARK: - Invalid Color Resolution Tests

    @Test("Skill with invalid palette ID returns gray color")
    func testInvalidPaletteIdReturnsGray() {
        let skill = Skill(
            name: "Swift",
            paletteId: "nonexistent_palette",
            colorIndex: 0
        )

        let color = skill.color

        #expect(color == .gray)
    }

    @Test("Skill with empty palette ID returns gray color")
    func testEmptyPaletteIdReturnsGray() {
        let skill = Skill(
            name: "Swift",
            paletteId: "",
            colorIndex: 0
        )

        let color = skill.color

        #expect(color == .gray)
    }

    @Test("Skill with out-of-range color index returns gray color")
    func testOutOfRangeColorIndexReturnsGray() {
        let skill = Skill(
            name: "Swift",
            paletteId: ColorPalette.summerOceanBreeze.id,
            colorIndex: 99 // Way out of range (only 5 colors)
        )

        let color = skill.color

        #expect(color == .gray)
    }

    @Test("Skill with color index at boundary (5) returns gray color")
    func testBoundaryColorIndexReturnsGray() {
        let skill = Skill(
            name: "Swift",
            paletteId: ColorPalette.summerOceanBreeze.id,
            colorIndex: 5 // Exactly one past the last valid index (0-4)
        )

        let color = skill.color

        #expect(color == .gray)
    }

    @Test("Skill with negative color index returns gray color")
    func testNegativeColorIndexReturnsGray() {
        let skill = Skill(
            name: "Swift",
            paletteId: ColorPalette.summerOceanBreeze.id,
            colorIndex: -1
        )

        let color = skill.color

        #expect(color == .gray)
    }

    @Test("Skill with very large negative color index returns gray color")
    func testVeryLargeNegativeColorIndexReturnsGray() {
        let skill = Skill(
            name: "Swift",
            paletteId: ColorPalette.summerOceanBreeze.id,
            colorIndex: Int16.min
        )

        let color = skill.color

        #expect(color == .gray)
    }

    @Test("Skill with very large positive color index returns gray color")
    func testVeryLargePositiveColorIndexReturnsGray() {
        let skill = Skill(
            name: "Swift",
            paletteId: ColorPalette.summerOceanBreeze.id,
            colorIndex: Int16.max
        )

        let color = skill.color

        #expect(color == .gray)
    }

    // MARK: - ColorAssignment Tests

    @Test("Skill colorAssignment has correct palette ID")
    func testColorAssignmentPaletteId() {
        let paletteId = ColorPalette.oceanSunset.id
        let skill = Skill(name: "Swift", paletteId: paletteId, colorIndex: 2)

        let assignment = skill.colorAssignment

        #expect(assignment.paletteId == paletteId)
    }

    @Test("Skill colorAssignment has correct color index")
    func testColorAssignmentColorIndex() {
        let skill = Skill(
            name: "Swift",
            paletteId: ColorPalette.oceanSunset.id,
            colorIndex: 3
        )

        let assignment = skill.colorAssignment

        #expect(assignment.colorIndex == 3)
    }

    @Test("ColorAssignment from skill resolves to same color as skill.color")
    func testColorAssignmentResolvesToSameColor() {
        let skill = Skill(
            name: "Swift",
            paletteId: ColorPalette.summerOceanBreeze.id,
            colorIndex: 2
        )

        let skillColor = skill.color
        let assignmentColor = skill.colorAssignment.color

        #expect(skillColor == assignmentColor)
    }

    // MARK: - Consistency Tests

    @Test("Skill color is consistent across multiple accesses")
    func testColorConsistency() {
        let skill = Skill(
            name: "Swift",
            paletteId: ColorPalette.summerOceanBreeze.id,
            colorIndex: 1
        )

        let color1 = skill.color
        let color2 = skill.color
        let color3 = skill.color

        #expect(color1 == color2)
        #expect(color2 == color3)
    }

    @Test("Different skills with same color settings have same color")
    func testSameColorSettingsSameColor() {
        let skill1 = Skill(
            name: "Swift",
            paletteId: ColorPalette.summerOceanBreeze.id,
            colorIndex: 2
        )

        let skill2 = Skill(
            name: "Python",
            paletteId: ColorPalette.summerOceanBreeze.id,
            colorIndex: 2
        )

        #expect(skill1.color == skill2.color)
    }

    @Test("Skills with different color indices have different colors")
    func testDifferentColorIndicesDifferentColors() {
        let skill1 = Skill(
            name: "Swift",
            paletteId: ColorPalette.summerOceanBreeze.id,
            colorIndex: 0
        )

        let skill2 = Skill(
            name: "Python",
            paletteId: ColorPalette.summerOceanBreeze.id,
            colorIndex: 1
        )

        // Colors should be different (both valid but different indices)
        #expect(skill1.color != skill2.color)
    }

    @Test("Skills with different palettes can have different colors even with same index")
    func testDifferentPalettesDifferentColors() {
        let skill1 = Skill(
            name: "Swift",
            paletteId: ColorPalette.summerOceanBreeze.id,
            colorIndex: 0
        )

        let skill2 = Skill(
            name: "Python",
            paletteId: ColorPalette.oceanSunset.id,
            colorIndex: 0
        )

        // Different palettes have different first colors
        #expect(skill1.color != skill2.color)
    }
}
