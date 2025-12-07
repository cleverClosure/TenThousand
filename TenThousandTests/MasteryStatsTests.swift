//
//  MasteryStatsTests.swift
//  TenThousandTests
//
//  Author: Tim Isaev
//
//  Unit tests for mastery statistics calculations
//

import Foundation
import SwiftData
@testable import TenThousand
import Testing

// MARK: - Skill Mastery Stats Tests

@Suite("Skill Mastery Stats", .serialized)
struct SkillMasteryStatsTests {
    // MARK: - Test Helpers

    static let testPaletteId = ColorPalette.summerOceanBreeze.id

    func makeStore() -> SwiftDataStore {
        SwiftDataStore.inMemory()
    }

    func createSkillWithSession(
        store: SwiftDataStore,
        durationSeconds: Int64,
        startedDaysAgo: Double = 0
    ) -> Skill {
        let skill = store.createSkill(name: "Test", paletteId: Self.testPaletteId, colorIndex: 0)
        let session = store.createSession(for: skill)
        let startTime = Date().addingTimeInterval(-startedDaysAgo * 24 * 3600)
        session.startTime = startTime
        session.endTime = startTime.addingTimeInterval(Double(durationSeconds))
        session.pausedDuration = 0
        return skill
    }

    // MARK: - totalHours Tests

    @Test("Skill with no sessions has zero total hours")
    func testTotalHoursZero() {
        let skill = Skill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        #expect(skill.totalHours == 0)
    }

    @Test("Skill with 1 hour session has 1.0 total hours")
    func testTotalHoursOneHour() {
        let store = makeStore()
        let skill = createSkillWithSession(store: store, durationSeconds: 3600)

        #expect(skill.totalHours == 1.0)
    }

    @Test("Skill with 90 minutes has 1.5 total hours")
    func testTotalHoursFractional() {
        let store = makeStore()
        let skill = createSkillWithSession(store: store, durationSeconds: 5400) // 90 minutes

        #expect(skill.totalHours == 1.5)
    }

    @Test("Skill with multiple sessions accumulates hours")
    func testTotalHoursMultipleSessions() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        // Add 2 hours
        let session1 = store.createSession(for: skill)
        session1.startTime = Date()
        session1.endTime = Date().addingTimeInterval(7200)
        session1.pausedDuration = 0

        // Add 30 minutes
        let session2 = store.createSession(for: skill)
        session2.startTime = Date()
        session2.endTime = Date().addingTimeInterval(1800)
        session2.pausedDuration = 0

        #expect(skill.totalHours == 2.5)
    }

    // MARK: - masteryProgress Tests

    @Test("Skill with no time has zero progress")
    func testMasteryProgressZero() {
        let skill = Skill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        #expect(skill.masteryProgress == 0.0)
    }

    @Test("Skill with 1000 hours has 10% progress")
    func testMasteryProgressTenPercent() {
        let store = makeStore()
        let skill = createSkillWithSession(store: store, durationSeconds: 1000 * 3600)

        #expect(skill.masteryProgress == 0.1)
    }

    @Test("Skill with 5000 hours has 50% progress")
    func testMasteryProgressFiftyPercent() {
        let store = makeStore()
        let skill = createSkillWithSession(store: store, durationSeconds: 5000 * 3600)

        #expect(skill.masteryProgress == 0.5)
    }

    @Test("Skill with exactly 10000 hours has 100% progress")
    func testMasteryProgressComplete() {
        let store = makeStore()
        let skill = createSkillWithSession(store: store, durationSeconds: 10000 * 3600)

        #expect(skill.masteryProgress == 1.0)
    }

    @Test("Skill with more than 10000 hours is capped at 100%")
    func testMasteryProgressCapped() {
        let store = makeStore()
        let skill = createSkillWithSession(store: store, durationSeconds: 15000 * 3600)

        #expect(skill.masteryProgress == 1.0)
    }

    // MARK: - masteryPercentage Tests

    @Test("Mastery percentage is progress times 100")
    func testMasteryPercentage() {
        let store = makeStore()
        let skill = createSkillWithSession(store: store, durationSeconds: 100 * 3600) // 100 hours = 1%

        #expect(skill.masteryPercentage == 1.0)
    }

    @Test("Mastery percentage handles small values")
    func testMasteryPercentageSmall() {
        let store = makeStore()
        let skill = createSkillWithSession(store: store, durationSeconds: 3600) // 1 hour = 0.01%

        #expect(skill.masteryPercentage == 0.01)
    }

    // MARK: - hoursRemaining Tests

    @Test("Skill with no time has 10000 hours remaining")
    func testHoursRemainingFull() {
        let skill = Skill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        #expect(skill.hoursRemaining == 10000)
    }

    @Test("Skill with 1000 hours has 9000 hours remaining")
    func testHoursRemainingPartial() {
        let store = makeStore()
        let skill = createSkillWithSession(store: store, durationSeconds: 1000 * 3600)

        #expect(skill.hoursRemaining == 9000)
    }

    @Test("Skill at mastery has zero hours remaining")
    func testHoursRemainingZero() {
        let store = makeStore()
        let skill = createSkillWithSession(store: store, durationSeconds: 10000 * 3600)

        #expect(skill.hoursRemaining == 0)
    }

    @Test("Skill beyond mastery still has zero hours remaining")
    func testHoursRemainingNeverNegative() {
        let store = makeStore()
        let skill = createSkillWithSession(store: store, durationSeconds: 15000 * 3600)

        #expect(skill.hoursRemaining == 0)
    }

    // MARK: - firstSessionDate Tests

    @Test("Skill with no sessions has nil first session date")
    func testFirstSessionDateNil() {
        let skill = Skill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        #expect(skill.firstSessionDate == nil)
    }

    @Test("Skill with one session returns that session's start time")
    func testFirstSessionDateSingle() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        let session = store.createSession(for: skill)
        let startTime = Date().addingTimeInterval(-3600)
        session.startTime = startTime

        #expect(skill.firstSessionDate == startTime)
    }

    @Test("Skill with multiple sessions returns earliest start time")
    func testFirstSessionDateMultiple() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let oldestTime = Date().addingTimeInterval(-7 * 24 * 3600) // 7 days ago
        let newerTime = Date().addingTimeInterval(-1 * 24 * 3600) // 1 day ago

        let session1 = store.createSession(for: skill)
        session1.startTime = newerTime

        let session2 = store.createSession(for: skill)
        session2.startTime = oldestTime

        #expect(skill.firstSessionDate == oldestTime)
    }

    // MARK: - lastSessionDate Tests

    @Test("Skill with no sessions has nil last session date")
    func testLastSessionDateNil() {
        let skill = Skill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        #expect(skill.lastSessionDate == nil)
    }

    @Test("Skill with multiple sessions returns latest start time")
    func testLastSessionDateMultiple() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let oldestTime = Date().addingTimeInterval(-7 * 24 * 3600) // 7 days ago
        let newestTime = Date().addingTimeInterval(-1 * 24 * 3600) // 1 day ago

        let session1 = store.createSession(for: skill)
        session1.startTime = oldestTime

        let session2 = store.createSession(for: skill)
        session2.startTime = newestTime

        #expect(skill.lastSessionDate == newestTime)
    }

    // MARK: - uniqueLoggedDays Tests

    @Test("Skill with no sessions has zero unique logged days")
    func testUniqueLoggedDaysNoSessions() {
        let skill = Skill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        #expect(skill.uniqueLoggedDays == 0)
    }

    @Test("Skill with one session has one unique logged day")
    func testUniqueLoggedDaysOneSession() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)
        _ = store.createSession(for: skill)

        #expect(skill.uniqueLoggedDays == 1)
    }

    @Test("Multiple sessions on same day count as one unique day")
    func testUniqueLoggedDaysSameDay() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let session1 = store.createSession(for: skill)
        session1.startTime = Date()

        let session2 = store.createSession(for: skill)
        session2.startTime = Date().addingTimeInterval(3600) // 1 hour later, same day

        #expect(skill.uniqueLoggedDays == 1)
    }

    @Test("Sessions on different days count as separate unique days")
    func testUniqueLoggedDaysDifferentDays() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        let session1 = store.createSession(for: skill)
        session1.startTime = Date()

        let session2 = store.createSession(for: skill)
        session2.startTime = Date().addingTimeInterval(-24 * 3600) // Yesterday

        let session3 = store.createSession(for: skill)
        session3.startTime = Date().addingTimeInterval(-48 * 3600) // 2 days ago

        #expect(skill.uniqueLoggedDays == 3)
    }

    // MARK: - hoursPerWeek Tests (Closed Period)

    @Test("Skill with no sessions has zero hours per week")
    func testHoursPerWeekNoSessions() {
        let skill = Skill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        #expect(skill.hoursPerWeek == 0)
    }

    @Test("Skill with sessions spanning 1 week calculates hours per week correctly")
    func testHoursPerWeekClosedPeriod() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        // First session 7 days ago (3 hours)
        let session1 = store.createSession(for: skill)
        session1.startTime = Date().addingTimeInterval(-7 * 24 * 3600)
        session1.endTime = session1.startTime.addingTimeInterval(3 * 3600)
        session1.pausedDuration = 0

        // Last session today (4 hours)
        let session2 = store.createSession(for: skill)
        session2.startTime = Date()
        session2.endTime = session2.startTime.addingTimeInterval(4 * 3600)
        session2.pausedDuration = 0

        // 7 hours over 1 week closed period = 7 hours/week
        let hoursPerWeek = skill.hoursPerWeek
        #expect(hoursPerWeek >= 6.9 && hoursPerWeek <= 7.1)
    }

    @Test("Open-ended time after last session is not counted in pace")
    func testHoursPerWeekIgnoresOpenEndedTime() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        // First session 21 days ago (3.5 hours)
        let session1 = store.createSession(for: skill)
        session1.startTime = Date().addingTimeInterval(-21 * 24 * 3600)
        session1.endTime = session1.startTime.addingTimeInterval(3.5 * 3600)
        session1.pausedDuration = 0

        // Last session 14 days ago (3.5 hours) - 7 days of open-ended time
        let session2 = store.createSession(for: skill)
        session2.startTime = Date().addingTimeInterval(-14 * 24 * 3600)
        session2.endTime = session2.startTime.addingTimeInterval(3.5 * 3600)
        session2.pausedDuration = 0

        // Closed period is 7 days (21 days ago to 14 days ago)
        // 7 hours / 1 week = 7 hours/week
        // NOT: 7 hours / 3 weeks = 2.33 hours/week
        let hoursPerWeek = skill.hoursPerWeek
        #expect(hoursPerWeek >= 6.9 && hoursPerWeek <= 7.1)
    }

    // MARK: - projectedTimeToMastery Tests

    @Test("Skill with no sessions has nil projection")
    func testProjectionNilNoSessions() {
        let skill = Skill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        #expect(skill.projectedTimeToMastery == nil)
    }

    @Test("Skill with fewer than 3 unique logged days has nil projection")
    func testProjectionNilInsufficientDays() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        // Only 2 unique days
        let session1 = store.createSession(for: skill)
        session1.startTime = Date().addingTimeInterval(-7 * 24 * 3600)
        session1.endTime = session1.startTime.addingTimeInterval(10 * 3600)
        session1.pausedDuration = 0

        let session2 = store.createSession(for: skill)
        session2.startTime = Date()
        session2.endTime = session2.startTime.addingTimeInterval(10 * 3600)
        session2.pausedDuration = 0

        #expect(skill.uniqueLoggedDays == 2)
        #expect(skill.projectedTimeToMastery == nil)
    }

    @Test("Skill at mastery has nil projection")
    func testProjectionNilAtMastery() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        // Create 3 sessions on different days to meet the requirement
        let session1 = store.createSession(for: skill)
        session1.startTime = Date().addingTimeInterval(-2 * 24 * 3600)
        session1.endTime = session1.startTime.addingTimeInterval(5000 * 3600)
        session1.pausedDuration = 0

        let session2 = store.createSession(for: skill)
        session2.startTime = Date().addingTimeInterval(-1 * 24 * 3600)
        session2.endTime = session2.startTime.addingTimeInterval(3000 * 3600)
        session2.pausedDuration = 0

        let session3 = store.createSession(for: skill)
        session3.startTime = Date()
        session3.endTime = session3.startTime.addingTimeInterval(2000 * 3600)
        session3.pausedDuration = 0

        #expect(skill.projectedTimeToMastery == nil)
    }

    @Test("Skill with 3+ days and 10 hours/week projects ~19 years to mastery")
    func testProjectionTenHoursPerWeek() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        // 3 sessions on 3 different days spanning 1 week, totaling 10 hours
        let session1 = store.createSession(for: skill)
        session1.startTime = Date().addingTimeInterval(-7 * 24 * 3600)
        session1.endTime = session1.startTime.addingTimeInterval(3 * 3600)
        session1.pausedDuration = 0

        let session2 = store.createSession(for: skill)
        session2.startTime = Date().addingTimeInterval(-4 * 24 * 3600)
        session2.endTime = session2.startTime.addingTimeInterval(3 * 3600)
        session2.pausedDuration = 0

        let session3 = store.createSession(for: skill)
        session3.startTime = Date()
        session3.endTime = session3.startTime.addingTimeInterval(4 * 3600)
        session3.pausedDuration = 0

        // 10 hours over 1 week = 10 hours/week
        // 10000 hours / 10 hours/week = 1000 weeks = ~19.2 years
        let projection = skill.projectedTimeToMastery
        #expect(projection != nil)
        #expect(projection!.years >= 18 && projection!.years <= 20)
    }

    @Test("Skill with 3+ days and 40 hours/week projects ~5 years to mastery")
    func testProjectionFortyHoursPerWeek() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        // 3 sessions on 3 different days spanning 1 week, totaling 40 hours
        let session1 = store.createSession(for: skill)
        session1.startTime = Date().addingTimeInterval(-7 * 24 * 3600)
        session1.endTime = session1.startTime.addingTimeInterval(15 * 3600)
        session1.pausedDuration = 0

        let session2 = store.createSession(for: skill)
        session2.startTime = Date().addingTimeInterval(-4 * 24 * 3600)
        session2.endTime = session2.startTime.addingTimeInterval(10 * 3600)
        session2.pausedDuration = 0

        let session3 = store.createSession(for: skill)
        session3.startTime = Date()
        session3.endTime = session3.startTime.addingTimeInterval(15 * 3600)
        session3.pausedDuration = 0

        // 40 hours over 1 week = 40 hours/week
        // 10000 hours / 40 hours/week = 250 weeks = ~4.8 years
        let projection = skill.projectedTimeToMastery
        #expect(projection != nil)
        #expect(projection!.years >= 4 && projection!.years <= 6)
    }

    @Test("Skill close to completion has short projection")
    func testProjectionNearCompletion() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        // 3 sessions over ~990 weeks, totaling 9900 hours
        let session1 = store.createSession(for: skill)
        session1.startTime = Date().addingTimeInterval(-990 * 7 * 24 * 3600)
        session1.endTime = session1.startTime.addingTimeInterval(5000 * 3600)
        session1.pausedDuration = 0

        let session2 = store.createSession(for: skill)
        session2.startTime = Date().addingTimeInterval(-500 * 7 * 24 * 3600)
        session2.endTime = session2.startTime.addingTimeInterval(2500 * 3600)
        session2.pausedDuration = 0

        let session3 = store.createSession(for: skill)
        session3.startTime = Date()
        session3.endTime = session3.startTime.addingTimeInterval(2400 * 3600)
        session3.pausedDuration = 0

        // ~9900 hours, ~100 remaining, at 10 hours/week
        let projection = skill.projectedTimeToMastery
        #expect(projection != nil)
        #expect(projection!.years == 0)
        #expect(projection!.months >= 1 && projection!.months <= 4)
    }
}

// MARK: - MasteryProjection Formatting Tests

@Suite("MasteryProjection Formatting")
struct MasteryProjectionTests {
    @Test("Zero years and zero months formats as less than a month")
    func testFormatLessThanMonth() {
        let projection = MasteryProjection(years: 0, months: 0)

        #expect(projection.formatted == "less than a month")
    }

    @Test("One month formats correctly with singular")
    func testFormatOneMonth() {
        let projection = MasteryProjection(years: 0, months: 1)

        #expect(projection.formatted == "1 month")
    }

    @Test("Multiple months format correctly with plural")
    func testFormatMultipleMonths() {
        let projection = MasteryProjection(years: 0, months: 6)

        #expect(projection.formatted == "6 months")
    }

    @Test("One year formats correctly with singular")
    func testFormatOneYear() {
        let projection = MasteryProjection(years: 1, months: 0)

        #expect(projection.formatted == "1 year")
    }

    @Test("Multiple years format correctly with plural")
    func testFormatMultipleYears() {
        let projection = MasteryProjection(years: 5, months: 0)

        #expect(projection.formatted == "5 years")
    }

    @Test("One year and one month format correctly")
    func testFormatOneYearOneMonth() {
        let projection = MasteryProjection(years: 1, months: 1)

        #expect(projection.formatted == "1 year, 1 month")
    }

    @Test("Multiple years and multiple months format correctly")
    func testFormatMultipleYearsAndMonths() {
        let projection = MasteryProjection(years: 6, months: 3)

        #expect(projection.formatted == "6 years, 3 months")
    }

    @Test("Large projection formats correctly")
    func testFormatLargeProjection() {
        let projection = MasteryProjection(years: 19, months: 2)

        #expect(projection.formatted == "19 years, 2 months")
    }

    @Test("11 months formats correctly")
    func testFormatElevenMonths() {
        let projection = MasteryProjection(years: 0, months: 11)

        #expect(projection.formatted == "11 months")
    }

    @Test("Year with 11 months formats correctly")
    func testFormatYearWithElevenMonths() {
        let projection = MasteryProjection(years: 2, months: 11)

        #expect(projection.formatted == "2 years, 11 months")
    }
}

// MARK: - Time Formatting Tests (Hours)

@Suite("Hours Formatting")
struct HoursFormattingTests {
    static let testPaletteId = ColorPalette.summerOceanBreeze.id

    func makeStore() -> SwiftDataStore {
        SwiftDataStore.inMemory()
    }

    @Test("Zero hours displays correctly")
    func testZeroHours() {
        let skill = Skill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        #expect(skill.totalHours == 0.0)
    }

    @Test("Fractional hours are precise")
    func testFractionalHours() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        // 1.5 hours = 5400 seconds
        let session = store.createSession(for: skill)
        session.startTime = Date()
        session.endTime = Date().addingTimeInterval(5400)
        session.pausedDuration = 0

        #expect(skill.totalHours == 1.5)
    }

    @Test("Large hour counts are accurate")
    func testLargeHourCount() {
        let store = makeStore()
        let skill = store.createSkill(name: "Swift", paletteId: Self.testPaletteId, colorIndex: 0)

        // 5000 hours
        let session = store.createSession(for: skill)
        session.startTime = Date()
        session.endTime = Date().addingTimeInterval(5000 * 3600)
        session.pausedDuration = 0

        #expect(skill.totalHours == 5000.0)
    }
}
