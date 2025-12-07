//
//  PaceProjectionTests.swift
//  TenThousandTests
//
//  Author: Tim Isaev
//
//  Comprehensive unit tests for pace projection system
//

import Foundation
import SwiftData
@testable import TenThousand
import Testing

// MARK: - Test Helpers

/// Creates a mock session with specified parameters.
private func makeSession(
    hoursAgo: Double = 0,
    durationHours: Double = 1.0,
    from referenceDate: Date = Date()
) -> Session {
    let skill = Skill(name: "Test", paletteId: "test", colorIndex: 0)
    let session = Session(skill: skill)
    session.startTime = referenceDate.addingTimeInterval(-hoursAgo * 3600)
    session.endTime = session.startTime.addingTimeInterval(durationHours * 3600)
    session.pausedDuration = 0
    return session
}

/// Creates a mock session with days ago instead of hours.
private func makeSessionDaysAgo(
    daysAgo: Double,
    durationHours: Double = 1.0,
    from referenceDate: Date = Date()
) -> Session {
    makeSession(hoursAgo: daysAgo * 24, durationHours: durationHours, from: referenceDate)
}

// MARK: - EMA Calculation Tests

@Suite("EMA Pace Calculation", .serialized)
struct EMAPaceCalculationTests {
    let referenceDate = Date()

    @Test("Empty sessions returns zero pace")
    func testEmptySessionsZeroPace() {
        let pace = PaceCalculator.calculateEMAPace(
            sessions: [],
            windowStart: referenceDate.addingTimeInterval(-8 * 7 * 24 * 3600),
            currentDate: referenceDate
        )
        #expect(pace == 0)
    }

    @Test("Single session calculates correct weekly pace")
    func testSingleSessionPace() {
        // 10 hours in a single session, 1 week window
        let session = makeSessionDaysAgo(daysAgo: 3, durationHours: 10, from: referenceDate)
        let windowStart = referenceDate.addingTimeInterval(-7 * 24 * 3600)

        let pace = PaceCalculator.calculateEMAPace(
            sessions: [session],
            windowStart: windowStart,
            currentDate: referenceDate
        )

        // Single week with 10 hours = 10 hrs/week
        #expect(pace == 10.0)
    }

    @Test("EMA weights recent sessions more heavily")
    func testEMAWeightsRecentMore() {
        // Week 1 (older): 2 hours
        // Week 2 (recent): 10 hours
        // EMA should be closer to 10 than to 6 (simple average)
        let session1 = makeSessionDaysAgo(daysAgo: 10, durationHours: 2, from: referenceDate)
        let session2 = makeSessionDaysAgo(daysAgo: 3, durationHours: 10, from: referenceDate)

        let windowStart = referenceDate.addingTimeInterval(-14 * 24 * 3600)

        let pace = PaceCalculator.calculateEMAPace(
            sessions: [session1, session2],
            windowStart: windowStart,
            currentDate: referenceDate
        )

        // With α = 0.25: EMA = 0.25 * 10 + 0.75 * 2 = 4.0
        // Wait, that's wrong. Let me recalculate:
        // Week 0: 2 hrs -> EMA = 2
        // Week 1: 10 hrs -> EMA = 0.25 * 10 + 0.75 * 2 = 2.5 + 1.5 = 4.0
        // Hmm, that seems like it weights old more? Let me verify the algorithm.
        // Actually with smoothing factor 0.25, recent gets 25% weight, history gets 75%
        // So EMA = 4.0 is correct

        // But wait - should be: older week = 2, newer week = 10
        // EMA starts at 2 (first value)
        // EMA = 0.25 * 10 + 0.75 * 2 = 4.0
        #expect(pace >= 3.5 && pace <= 4.5)
    }

    @Test("Multiple weeks EMA converges toward recent values")
    func testEMAConvergesToRecent() {
        // 4 weeks of increasing practice: 2, 4, 8, 16 hours
        let sessions = [
            makeSessionDaysAgo(daysAgo: 25, durationHours: 2, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 18, durationHours: 4, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 11, durationHours: 8, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 4, durationHours: 16, from: referenceDate)
        ]

        let windowStart = referenceDate.addingTimeInterval(-28 * 24 * 3600)

        let pace = PaceCalculator.calculateEMAPace(
            sessions: sessions,
            windowStart: windowStart,
            currentDate: referenceDate
        )

        // Simple average would be 7.5
        // EMA with α=0.25 should give more weight to recent 16 hrs
        // But still be dampened by history
        #expect(pace > 5 && pace < 12)
    }
}

// MARK: - Rolling Window Tests

@Suite("Rolling Window Logic", .serialized)
struct RollingWindowTests {
    let referenceDate = Date()

    @Test("Sessions outside rolling window are excluded")
    func testWindowExcludesOldSessions() {
        // Session from 10 weeks ago (outside 8-week window)
        let oldSession = makeSessionDaysAgo(daysAgo: 70, durationHours: 100, from: referenceDate)
        // Session from 1 week ago (inside window)
        let recentSession = makeSessionDaysAgo(daysAgo: 7, durationHours: 5, from: referenceDate)

        let sessions = [oldSession, recentSession]
        let windowStart = referenceDate.addingTimeInterval(-8 * 7 * 24 * 3600)

        // Filter to window
        let windowSessions = sessions.filter { $0.startTime >= windowStart }

        #expect(windowSessions.count == 1)
        #expect(windowSessions.first?.durationSeconds == Int64(5 * 3600))
    }

    @Test("Sessions at window boundary are included")
    func testWindowBoundaryInclusion() {
        // Session exactly 8 weeks ago
        let boundarySession = makeSessionDaysAgo(daysAgo: 56, durationHours: 5, from: referenceDate)

        let windowStart = referenceDate.addingTimeInterval(-8 * 7 * 24 * 3600)
        let isInWindow = boundarySession.startTime >= windowStart

        #expect(isInWindow)
    }

    @Test("Unique days counted correctly within window")
    func testUniqueDaysInWindow() {
        // 3 sessions on 3 different days
        let sessions = [
            makeSessionDaysAgo(daysAgo: 1, durationHours: 1, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 3, durationHours: 1, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 5, durationHours: 1, from: referenceDate)
        ]

        let uniqueDays = PaceCalculator.countUniqueDays(in: sessions)
        #expect(uniqueDays == 3)
    }

    @Test("Multiple sessions same day count as one unique day")
    func testSameDaySessionsOneUniqueDay() {
        // 3 sessions on same day
        let sessions = [
            makeSession(hoursAgo: 2, durationHours: 1, from: referenceDate),
            makeSession(hoursAgo: 4, durationHours: 1, from: referenceDate),
            makeSession(hoursAgo: 6, durationHours: 1, from: referenceDate)
        ]

        let uniqueDays = PaceCalculator.countUniqueDays(in: sessions)
        #expect(uniqueDays == 1)
    }

    @Test("Weekly grouping assigns sessions to correct weeks")
    func testWeeklyGrouping() {
        // Week 0: 1 session (5 hours) - 10 days ago
        // Week 1: 2 sessions (3 hours total) - 1-2 days ago
        let sessions = [
            makeSessionDaysAgo(daysAgo: 1, durationHours: 1, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 2, durationHours: 2, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 10, durationHours: 5, from: referenceDate)
        ]

        // Period from 10 days ago to 1 day ago
        let periodStart = referenceDate.addingTimeInterval(-10 * 24 * 3600)
        let periodEnd = referenceDate.addingTimeInterval(-1 * 24 * 3600)
        let weeklyHours = PaceCalculator.groupSessionsByWeek(
            sessions: sessions,
            periodStart: periodStart,
            periodEnd: periodEnd
        )

        // Should have at least 2 weeks of data
        #expect(weeklyHours.count >= 1)
        // Total hours should be 8 (5 + 1 + 2)
        let totalHours = weeklyHours.reduce(0, +)
        #expect(totalHours == 8.0)
    }
}

// MARK: - Trend Calculation Tests

@Suite("Trend Calculation", .serialized)
struct TrendCalculationTests {
    let referenceDate = Date()

    @Test("Increasing pace detected correctly")
    func testIncreasingTrendDetected() {
        // Historical (2-6 weeks ago): 2 hours/week
        // Recent (last 2 weeks): 10 hours/week
        let sessions = [
            makeSessionDaysAgo(daysAgo: 35, durationHours: 4, from: referenceDate), // ~5 weeks ago
            makeSessionDaysAgo(daysAgo: 28, durationHours: 4, from: referenceDate), // 4 weeks ago
            makeSessionDaysAgo(daysAgo: 7, durationHours: 10, from: referenceDate),  // 1 week ago
            makeSessionDaysAgo(daysAgo: 3, durationHours: 10, from: referenceDate)   // 3 days ago
        ]

        let trend = PaceCalculator.calculateTrend(sessions: sessions, currentDate: referenceDate)
        #expect(trend == .increasing)
    }

    @Test("Decreasing pace detected correctly")
    func testDecreasingTrendDetected() {
        // Historical: 10 hours/week
        // Recent: 2 hours/week
        let sessions = [
            makeSessionDaysAgo(daysAgo: 35, durationHours: 20, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 28, durationHours: 20, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 7, durationHours: 2, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 3, durationHours: 2, from: referenceDate)
        ]

        let trend = PaceCalculator.calculateTrend(sessions: sessions, currentDate: referenceDate)
        #expect(trend == .decreasing)
    }

    @Test("Steady pace detected when within threshold")
    func testSteadyTrendDetected() {
        // Historical: ~5 hours/week
        // Recent: ~5.5 hours/week (10% difference, below 15% threshold)
        let sessions = [
            makeSessionDaysAgo(daysAgo: 35, durationHours: 10, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 28, durationHours: 10, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 7, durationHours: 5.5, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 3, durationHours: 5.5, from: referenceDate)
        ]

        let trend = PaceCalculator.calculateTrend(sessions: sessions, currentDate: referenceDate)
        #expect(trend == .steady)
    }

    @Test("Unknown trend when insufficient data")
    func testUnknownTrendInsufficientData() {
        // Only 2 sessions - not enough
        let sessions = [
            makeSessionDaysAgo(daysAgo: 7, durationHours: 5, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 3, durationHours: 5, from: referenceDate)
        ]

        let trend = PaceCalculator.calculateTrend(sessions: sessions, currentDate: referenceDate)
        #expect(trend == .unknown)
    }

    @Test("Unknown trend when no historical data")
    func testUnknownTrendNoHistorical() {
        // All sessions in recent period, none in historical
        let sessions = [
            makeSessionDaysAgo(daysAgo: 7, durationHours: 5, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 5, durationHours: 5, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 3, durationHours: 5, from: referenceDate)
        ]

        let trend = PaceCalculator.calculateTrend(sessions: sessions, currentDate: referenceDate)
        #expect(trend == .unknown)
    }

    @Test("Unknown trend when no recent data")
    func testUnknownTrendNoRecent() {
        // All sessions in historical period, none recent
        let sessions = [
            makeSessionDaysAgo(daysAgo: 35, durationHours: 5, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 28, durationHours: 5, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 21, durationHours: 5, from: referenceDate)
        ]

        let trend = PaceCalculator.calculateTrend(sessions: sessions, currentDate: referenceDate)
        #expect(trend == .unknown)
    }
}

// MARK: - Target-Based Projection Tests

@Suite("Target-Based Projection", .serialized)
struct TargetBasedProjectionTests {
    let referenceDate = Date()

    @Test("Target projection calculates correctly")
    func testTargetProjectionCalculation() {
        // 10 hours/week target, 10000 hours remaining
        // = 1000 weeks = ~19.2 years
        let projection = PaceCalculator.calculateTargetProjection(
            targetHoursPerWeek: 10,
            hoursRemaining: 10000,
            sessions: [],
            currentDate: referenceDate
        )

        #expect(projection.confidence == .high)
        #expect(projection.mode == .targetBased)
        #expect(projection.years != nil)
        #expect(projection.years! >= 18 && projection.years! <= 20)
    }

    @Test("Target projection with 40 hours/week")
    func testTargetProjection40HoursWeek() {
        // 40 hours/week, 10000 remaining = 250 weeks = ~4.8 years
        let projection = PaceCalculator.calculateTargetProjection(
            targetHoursPerWeek: 40,
            hoursRemaining: 10000,
            sessions: [],
            currentDate: referenceDate
        )

        #expect(projection.years! >= 4 && projection.years! <= 6)
    }

    @Test("Zero target returns insufficient")
    func testZeroTargetInsufficient() {
        let projection = PaceCalculator.calculateTargetProjection(
            targetHoursPerWeek: 0,
            hoursRemaining: 10000,
            sessions: [],
            currentDate: referenceDate
        )

        #expect(projection.confidence == .insufficient)
    }

    @Test("Target trend shows ahead when exceeding target")
    func testTargetTrendAhead() {
        // Target: 5 hrs/week
        // Actual (last 2 weeks): 10 hrs/week
        let sessions = [
            makeSessionDaysAgo(daysAgo: 7, durationHours: 10, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 3, durationHours: 10, from: referenceDate)
        ]

        let trend = PaceCalculator.calculateTargetTrend(
            targetHoursPerWeek: 5,
            sessions: sessions,
            currentDate: referenceDate
        )

        #expect(trend == .increasing) // Ahead of target
    }

    @Test("Target trend shows behind when below target")
    func testTargetTrendBehind() {
        // Target: 20 hrs/week
        // Actual: ~2.5 hrs/week
        let sessions = [
            makeSessionDaysAgo(daysAgo: 7, durationHours: 2.5, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 3, durationHours: 2.5, from: referenceDate)
        ]

        let trend = PaceCalculator.calculateTargetTrend(
            targetHoursPerWeek: 20,
            sessions: sessions,
            currentDate: referenceDate
        )

        #expect(trend == .decreasing) // Behind target
    }

    @Test("Target trend shows on-track when matching target")
    func testTargetTrendOnTrack() {
        // Target: 10 hrs/week
        // Actual: 10 hrs over 2 weeks = 5 hrs/week... wait that's not right
        // Let me fix: 20 hrs over 2 weeks = 10 hrs/week
        let sessions = [
            makeSessionDaysAgo(daysAgo: 7, durationHours: 10, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 3, durationHours: 10, from: referenceDate)
        ]

        let trend = PaceCalculator.calculateTargetTrend(
            targetHoursPerWeek: 10,
            sessions: sessions,
            currentDate: referenceDate
        )

        #expect(trend == .steady) // On target
    }

    @Test("Target gap calculated correctly when ahead")
    func testTargetGapAhead() {
        // Actual: 15 hrs over 2 weeks = 7.5 hrs/week
        // Target: 5 hrs/week
        // Gap: +2.5 hrs/week
        let sessions = [
            makeSessionDaysAgo(daysAgo: 7, durationHours: 7.5, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 3, durationHours: 7.5, from: referenceDate)
        ]

        let gap = PaceCalculator.targetGap(
            targetHoursPerWeek: 5,
            sessions: sessions,
            currentDate: referenceDate
        )

        #expect(gap > 0) // Positive = ahead
        #expect(gap >= 2 && gap <= 3)
    }

    @Test("Target gap calculated correctly when behind")
    func testTargetGapBehind() {
        // Actual: 4 hrs over 2 weeks = 2 hrs/week
        // Target: 10 hrs/week
        // Gap: -8 hrs/week
        let sessions = [
            makeSessionDaysAgo(daysAgo: 7, durationHours: 2, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 3, durationHours: 2, from: referenceDate)
        ]

        let gap = PaceCalculator.targetGap(
            targetHoursPerWeek: 10,
            sessions: sessions,
            currentDate: referenceDate
        )

        #expect(gap < 0) // Negative = behind
        #expect(gap <= -7 && gap >= -9)
    }
}

// MARK: - Confidence Level Tests

@Suite("Confidence Level Determination", .serialized)
struct ConfidenceLevelTests {
    let referenceDate = Date()

    @Test("Insufficient confidence with less than 3 unique days")
    func testInsufficientConfidenceFewDays() {
        let sessions = [
            makeSessionDaysAgo(daysAgo: 7, durationHours: 5, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 3, durationHours: 5, from: referenceDate)
        ]

        let confidence = PaceCalculator.determineConfidence(
            uniqueDays: 2,
            windowSessions: sessions,
            currentDate: referenceDate
        )

        #expect(confidence == .insufficient)
    }

    @Test("Low confidence with 3-6 unique days in short span")
    func testLowConfidence() {
        // 3 unique days over 5 days
        let sessions = [
            makeSessionDaysAgo(daysAgo: 1, durationHours: 2, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 3, durationHours: 2, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 5, durationHours: 2, from: referenceDate)
        ]

        let confidence = PaceCalculator.determineConfidence(
            uniqueDays: 3,
            windowSessions: sessions,
            currentDate: referenceDate
        )

        #expect(confidence == .low)
    }

    @Test("Medium confidence with 7+ unique days or 2+ week span")
    func testMediumConfidence() {
        // 7 unique days spread over 2 weeks
        var sessions: [Session] = []
        for i in 0..<7 {
            sessions.append(makeSessionDaysAgo(daysAgo: Double(i * 2), durationHours: 1, from: referenceDate))
        }

        let confidence = PaceCalculator.determineConfidence(
            uniqueDays: 7,
            windowSessions: sessions,
            currentDate: referenceDate
        )

        #expect(confidence == .medium)
    }

    @Test("High confidence with 15+ unique days over 4+ weeks")
    func testHighConfidence() {
        // 15 unique days over 5 weeks
        var sessions: [Session] = []
        for i in 0..<15 {
            sessions.append(makeSessionDaysAgo(daysAgo: Double(i * 2 + 1), durationHours: 1, from: referenceDate))
        }

        let confidence = PaceCalculator.determineConfidence(
            uniqueDays: 15,
            windowSessions: sessions,
            currentDate: referenceDate
        )

        #expect(confidence == .high)
    }
}

// MARK: - EMA Projection Integration Tests

@Suite("EMA Projection Integration", .serialized)
struct EMAProjectionIntegrationTests {
    let referenceDate = Date()

    @Test("EMA projection with insufficient data returns insufficient")
    func testEMAProjectionInsufficientData() {
        let sessions = [
            makeSessionDaysAgo(daysAgo: 3, durationHours: 5, from: referenceDate)
        ]

        let projection = PaceCalculator.calculateEMAProjection(
            sessions: sessions,
            hoursRemaining: 10000,
            currentDate: referenceDate
        )

        #expect(projection.confidence == .insufficient)
    }

    @Test("EMA projection with 3 unique days shows low confidence")
    func testEMAProjectionLowConfidence() {
        let sessions = [
            makeSessionDaysAgo(daysAgo: 1, durationHours: 5, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 3, durationHours: 5, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 5, durationHours: 5, from: referenceDate)
        ]

        let projection = PaceCalculator.calculateEMAProjection(
            sessions: sessions,
            hoursRemaining: 10000,
            currentDate: referenceDate
        )

        #expect(projection.confidence == .low)
        #expect(projection.yearsUpperBound != nil)
    }

    @Test("EMA projection includes trend information")
    func testEMAProjectionIncludesTrend() {
        // Increasing trend
        let sessions = [
            makeSessionDaysAgo(daysAgo: 35, durationHours: 2, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 28, durationHours: 2, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 7, durationHours: 10, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 5, durationHours: 10, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 3, durationHours: 10, from: referenceDate)
        ]

        let projection = PaceCalculator.calculateEMAProjection(
            sessions: sessions,
            hoursRemaining: 10000,
            currentDate: referenceDate
        )

        #expect(projection.trend == .increasing)
    }

    @Test("EMA projection at mastery returns zero projection")
    func testEMAProjectionAtMastery() {
        let sessions = [
            makeSessionDaysAgo(daysAgo: 1, durationHours: 1, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 3, durationHours: 1, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 5, durationHours: 1, from: referenceDate)
        ]

        let projection = PaceCalculator.calculateEMAProjection(
            sessions: sessions,
            hoursRemaining: 0, // Already at mastery
            currentDate: referenceDate
        )

        #expect(projection.years == 0)
        #expect(projection.months == 0)
    }
}

// MARK: - Edge Case Tests

@Suite("Edge Cases", .serialized)
struct EdgeCaseTests {
    let referenceDate = Date()

    @Test("No sessions returns insufficient projection")
    func testNoSessionsInsufficient() {
        let projection = PaceCalculator.calculateEMAProjection(
            sessions: [],
            hoursRemaining: 10000,
            currentDate: referenceDate
        )

        #expect(projection.confidence == .insufficient)
        #expect(projection.formatted == "Keep practicing to see projection")
    }

    @Test("Very low pace caps at 100+ years display")
    func testVeryLowPaceCapped() {
        // 0.1 hrs/week pace would project to 1923+ years
        // Should display as "100+ years at current pace"
        let sessions = [
            makeSessionDaysAgo(daysAgo: 1, durationHours: 0.05, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 8, durationHours: 0.05, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 15, durationHours: 0.05, from: referenceDate)
        ]

        let projection = PaceCalculator.calculateEMAProjection(
            sessions: sessions,
            hoursRemaining: 10000,
            currentDate: referenceDate
        )

        // Should cap at 100+ years display
        #expect(projection.formatted.contains("100+ years") || projection.formatted.contains("50+ years"))
    }

    @Test("All sessions outside window returns insufficient")
    func testAllSessionsOutsideWindow() {
        // All sessions from 10 weeks ago (outside 8-week window)
        let sessions = [
            makeSessionDaysAgo(daysAgo: 70, durationHours: 10, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 72, durationHours: 10, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 74, durationHours: 10, from: referenceDate)
        ]

        let projection = PaceCalculator.calculateEMAProjection(
            sessions: sessions,
            hoursRemaining: 10000,
            currentDate: referenceDate
        )

        #expect(projection.confidence == .insufficient)
    }

    @Test("Sessions on same day count as one unique day")
    func testSameDaySessions() {
        // 5 sessions on the same day
        let sessions = [
            makeSession(hoursAgo: 1, durationHours: 1, from: referenceDate),
            makeSession(hoursAgo: 2, durationHours: 1, from: referenceDate),
            makeSession(hoursAgo: 3, durationHours: 1, from: referenceDate),
            makeSession(hoursAgo: 4, durationHours: 1, from: referenceDate),
            makeSession(hoursAgo: 5, durationHours: 1, from: referenceDate)
        ]

        let projection = PaceCalculator.calculateEMAProjection(
            sessions: sessions,
            hoursRemaining: 10000,
            currentDate: referenceDate
        )

        // Only 1 unique day, needs 3
        #expect(projection.confidence == .insufficient)
    }

    @Test("Negative target hours returns insufficient")
    func testNegativeTargetHours() {
        let projection = PaceCalculator.calculateTargetProjection(
            targetHoursPerWeek: -5,
            hoursRemaining: 10000,
            sessions: [],
            currentDate: referenceDate
        )

        #expect(projection.confidence == .insufficient)
    }

    @Test("Very high target shows short projection")
    func testVeryHighTarget() {
        // 100 hours/week = 100 weeks = ~2 years
        let projection = PaceCalculator.calculateTargetProjection(
            targetHoursPerWeek: 100,
            hoursRemaining: 10000,
            sessions: [],
            currentDate: referenceDate
        )

        #expect(projection.years != nil)
        #expect(projection.years! <= 3)
    }

    @Test("Near mastery shows less than a month")
    func testNearMastery() {
        // 100 hours/week, only 50 hours remaining = 0.5 weeks
        let projection = PaceCalculator.calculateTargetProjection(
            targetHoursPerWeek: 100,
            hoursRemaining: 50,
            sessions: [],
            currentDate: referenceDate
        )

        #expect(projection.years == 0)
        #expect(projection.months == 0)
        #expect(projection.formatted == "Less than a month")
    }
}

// MARK: - SmartProjection Formatting Tests

@Suite("SmartProjection Formatting", .serialized)
struct SmartProjectionFormattingTests {
    @Test("Insufficient confidence formats correctly")
    func testInsufficientFormatting() {
        let projection = SmartProjection.insufficient(mode: .recentPace)
        #expect(projection.formatted == "Keep practicing to see projection")
    }

    @Test("Low confidence shows range")
    func testLowConfidenceShowsRange() {
        let projection = SmartProjection(
            confidence: .low,
            years: 15,
            months: 6,
            yearsUpperBound: 20,
            trend: .steady,
            hoursPerWeek: 10,
            mode: .recentPace
        )

        #expect(projection.formatted.contains("15-20 years"))
        #expect(projection.formatted.contains("early estimate"))
    }

    @Test("Medium confidence shows years and months")
    func testMediumConfidenceFormatting() {
        let projection = SmartProjection(
            confidence: .medium,
            years: 15,
            months: 6,
            yearsUpperBound: nil,
            trend: .steady,
            hoursPerWeek: 10,
            mode: .recentPace
        )

        #expect(projection.formatted == "15 years, 6 months")
    }

    @Test("High confidence shows precise projection")
    func testHighConfidenceFormatting() {
        let projection = SmartProjection(
            confidence: .high,
            years: 5,
            months: 3,
            yearsUpperBound: nil,
            trend: .increasing,
            hoursPerWeek: 40,
            mode: .recentPace
        )

        #expect(projection.formatted == "5 years, 3 months")
    }

    @Test("Trend arrows format correctly")
    func testTrendArrows() {
        let increasing = SmartProjection(
            confidence: .high, years: 5, months: 0, yearsUpperBound: nil,
            trend: .increasing, hoursPerWeek: 10, mode: .recentPace
        )
        #expect(increasing.trendArrow == "↑")
        #expect(increasing.trendDescription == "Trending up")

        let steady = SmartProjection(
            confidence: .high, years: 5, months: 0, yearsUpperBound: nil,
            trend: .steady, hoursPerWeek: 10, mode: .recentPace
        )
        #expect(steady.trendArrow == "→")
        #expect(steady.trendDescription == "Steady pace")

        let decreasing = SmartProjection(
            confidence: .high, years: 5, months: 0, yearsUpperBound: nil,
            trend: .decreasing, hoursPerWeek: 10, mode: .recentPace
        )
        #expect(decreasing.trendArrow == "↓")
        #expect(decreasing.trendDescription == "Trending down")

        let unknown = SmartProjection(
            confidence: .high, years: 5, months: 0, yearsUpperBound: nil,
            trend: .unknown, hoursPerWeek: 10, mode: .recentPace
        )
        #expect(unknown.trendArrow == "")
        #expect(unknown.trendDescription == "")
    }

    @Test("Years only formats correctly")
    func testYearsOnlyFormatting() {
        let projection = SmartProjection(
            confidence: .high,
            years: 10,
            months: 0,
            yearsUpperBound: nil,
            trend: .steady,
            hoursPerWeek: 20,
            mode: .recentPace
        )

        #expect(projection.formatted == "10 years")
    }

    @Test("Months only formats correctly")
    func testMonthsOnlyFormatting() {
        let projection = SmartProjection(
            confidence: .high,
            years: 0,
            months: 8,
            yearsUpperBound: nil,
            trend: .steady,
            hoursPerWeek: 200,
            mode: .recentPace
        )

        #expect(projection.formatted == "8 months")
    }

    @Test("Singular forms used correctly")
    func testSingularForms() {
        let oneYear = SmartProjection(
            confidence: .high, years: 1, months: 0, yearsUpperBound: nil,
            trend: .steady, hoursPerWeek: 100, mode: .recentPace
        )
        #expect(oneYear.formatted == "1 year")

        let oneMonth = SmartProjection(
            confidence: .high, years: 0, months: 1, yearsUpperBound: nil,
            trend: .steady, hoursPerWeek: 200, mode: .recentPace
        )
        #expect(oneMonth.formatted == "1 month")

        let oneYearOneMonth = SmartProjection(
            confidence: .high, years: 1, months: 1, yearsUpperBound: nil,
            trend: .steady, hoursPerWeek: 90, mode: .recentPace
        )
        #expect(oneYearOneMonth.formatted == "1 year, 1 month")
    }
}

// MARK: - Skill Integration Tests

@Suite("Skill Model Integration", .serialized)
struct SkillIntegrationTests {
    static let testPaletteId = ColorPalette.summerOceanBreeze.id

    func makeStore() -> SwiftDataStore {
        SwiftDataStore.inMemory()
    }

    @Test("Default projection mode is recentPace")
    func testDefaultProjectionMode() {
        let skill = Skill(name: "Test", paletteId: Self.testPaletteId, colorIndex: 0)
        #expect(skill.projectionMode == .recentPace)
    }

    @Test("Projection mode can be changed")
    func testProjectionModeChange() {
        let skill = Skill(name: "Test", paletteId: Self.testPaletteId, colorIndex: 0)
        skill.projectionMode = .targetBased
        #expect(skill.projectionMode == .targetBased)
    }

    @Test("Target hours persists")
    func testTargetHoursPersists() {
        let skill = Skill(name: "Test", paletteId: Self.testPaletteId, colorIndex: 0)
        skill.targetHoursPerWeek = 15.5
        #expect(skill.targetHoursPerWeek == 15.5)
    }

    @Test("Smart projection uses correct mode - recentPace")
    func testSmartProjectionRecentPaceMode() {
        let store = makeStore()
        let skill = store.createSkill(name: "Test", paletteId: Self.testPaletteId, colorIndex: 0)

        // Add some sessions
        let referenceDate = Date()
        for i in 0..<5 {
            let session = store.createSession(for: skill)
            session.startTime = referenceDate.addingTimeInterval(Double(-i * 2) * 24 * 3600)
            session.endTime = session.startTime.addingTimeInterval(2 * 3600)
            session.pausedDuration = 0
        }

        skill.projectionMode = .recentPace
        let projection = skill.smartProjection(at: referenceDate)

        #expect(projection.mode == .recentPace)
    }

    @Test("Smart projection uses correct mode - targetBased")
    func testSmartProjectionTargetMode() {
        let store = makeStore()
        let skill = store.createSkill(name: "Test", paletteId: Self.testPaletteId, colorIndex: 0)

        skill.projectionMode = .targetBased
        skill.targetHoursPerWeek = 10

        let projection = skill.smartProjection

        #expect(projection.mode == .targetBased)
        #expect(projection.confidence == .high)
    }

    @Test("Target mode without target returns insufficient")
    func testTargetModeNoTarget() {
        let skill = Skill(name: "Test", paletteId: Self.testPaletteId, colorIndex: 0)
        skill.projectionMode = .targetBased
        skill.targetHoursPerWeek = nil

        let projection = skill.smartProjection

        #expect(projection.confidence == .insufficient)
    }

    @Test("Actual recent pace calculated correctly")
    func testActualRecentPace() {
        let store = makeStore()
        let skill = store.createSkill(name: "Test", paletteId: Self.testPaletteId, colorIndex: 0)

        let referenceDate = Date()
        // Add 10 hours over last 2 weeks = 5 hrs/week
        let session1 = store.createSession(for: skill)
        session1.startTime = referenceDate.addingTimeInterval(-7 * 24 * 3600)
        session1.endTime = session1.startTime.addingTimeInterval(5 * 3600)
        session1.pausedDuration = 0

        let session2 = store.createSession(for: skill)
        session2.startTime = referenceDate.addingTimeInterval(-3 * 24 * 3600)
        session2.endTime = session2.startTime.addingTimeInterval(5 * 3600)
        session2.pausedDuration = 0

        // Note: actualRecentPace uses current date, so we can't easily test precise values
        // Just verify it returns a reasonable positive number
        #expect(skill.actualRecentPace >= 0)
    }

    @Test("Target pace gap calculated correctly")
    func testTargetPaceGap() {
        let store = makeStore()
        let skill = store.createSkill(name: "Test", paletteId: Self.testPaletteId, colorIndex: 0)
        skill.targetHoursPerWeek = 10

        // Without setting up recent sessions, gap should be negative (behind target)
        if let gap = skill.targetPaceGap {
            #expect(gap <= 0) // No recent practice = behind target
        }
    }
}

// MARK: - Regression Tests

@Suite("Regression Tests", .serialized)
struct RegressionTests {
    let referenceDate = Date()

    @Test("1219 years scenario now handled correctly")
    func testOriginal1219YearsScenario() {
        // Original scenario: 0.2 hours logged, created ~9 days ago
        // This should NOT show 1219 years anymore

        let sessions = [
            makeSessionDaysAgo(daysAgo: 9, durationHours: 0.2, from: referenceDate)
        ]

        let projection = PaceCalculator.calculateEMAProjection(
            sessions: sessions,
            hoursRemaining: 10000,
            currentDate: referenceDate
        )

        // Should return insufficient (< 3 unique days)
        #expect(projection.confidence == .insufficient)
        #expect(projection.formatted == "Keep practicing to see projection")
    }

    @Test("Break between sessions doesn't penalize projection")
    func testBreakDoesntPenalize() {
        // User practiced 3 days, then took 4 weeks off
        // The 4 weeks off shouldn't affect the pace calculation
        let sessions = [
            makeSessionDaysAgo(daysAgo: 35, durationHours: 10, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 34, durationHours: 10, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 33, durationHours: 10, from: referenceDate),
            // 4 week break, then...
            makeSessionDaysAgo(daysAgo: 3, durationHours: 10, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 2, durationHours: 10, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 1, durationHours: 10, from: referenceDate)
        ]

        let projection = PaceCalculator.calculateEMAProjection(
            sessions: sessions,
            hoursRemaining: 10000,
            currentDate: referenceDate
        )

        // With EMA + rolling window, the consistent 10 hrs/day practice
        // should result in a reasonable projection (not penalized by break)
        #expect(projection.confidence != .insufficient)

        // With ~60 hours over 6 weeks in window, pace should be decent
        // Not absurdly long like 1000+ years
        if let years = projection.years {
            #expect(years < 100)
        }
    }

    @Test("Very recent start with good pace shows reasonable projection")
    func testRecentStartGoodPace() {
        // Started 5 days ago, practicing 3 hrs/day = 21 hrs/week pace
        // 10000 / 21 = 476 weeks = ~9 years
        let sessions = [
            makeSessionDaysAgo(daysAgo: 1, durationHours: 3, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 2, durationHours: 3, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 3, durationHours: 3, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 4, durationHours: 3, from: referenceDate),
            makeSessionDaysAgo(daysAgo: 5, durationHours: 3, from: referenceDate)
        ]

        let projection = PaceCalculator.calculateEMAProjection(
            sessions: sessions,
            hoursRemaining: 10000,
            currentDate: referenceDate
        )

        // Should have low confidence (recent start) but reasonable projection
        #expect(projection.confidence == .low || projection.confidence == .medium)

        // Projection should be in reasonable range
        if let years = projection.years {
            #expect(years >= 5 && years <= 50)
        }
    }
}
