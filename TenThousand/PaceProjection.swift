//
//  PaceProjection.swift
//  TenThousand
//
//  Created by Tim Isaev
//
//  Pace projection system with EMA + Rolling Window and Target-based modes
//

import Foundation

// MARK: - Projection Mode

/// The mode used for calculating pace projections.
enum ProjectionMode: String, Codable, CaseIterable {
    /// EMA-based projection using rolling window of recent sessions.
    /// Weights recent sessions more heavily and shows trend direction.
    case recentPace

    /// Target-based projection using user-defined weekly hours goal.
    case targetBased
}

// MARK: - Pace Trend

/// Direction of practice pace trend.
enum PaceTrend: String, Codable {
    /// Practicing more than before (recent > historical)
    case increasing

    /// Practicing about the same as before
    case steady

    /// Practicing less than before (recent < historical)
    case decreasing

    /// Not enough data to determine trend
    case unknown
}

// MARK: - Confidence Level

/// Confidence level of the projection based on available data.
enum ProjectionConfidence: String, Codable, Comparable {
    /// Less than minimum required data
    case insufficient

    /// 3-7 unique days - early estimate
    case low

    /// 1-4 weeks of data
    case medium

    /// 4+ weeks of consistent data
    case high

    static func < (lhs: ProjectionConfidence, rhs: ProjectionConfidence) -> Bool {
        let order: [ProjectionConfidence] = [.insufficient, .low, .medium, .high]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else { return false }
        return lhsIndex < rhsIndex
    }
}

// MARK: - Smart Projection Result

/// Result of a pace projection calculation.
struct SmartProjection: Equatable {
    /// Confidence level based on data quality
    let confidence: ProjectionConfidence

    /// Estimated years to mastery (nil if insufficient data)
    let years: Int?

    /// Estimated months to mastery (0-11, nil if insufficient data)
    let months: Int?

    /// For low confidence, upper bound of range
    let yearsUpperBound: Int?

    /// Current pace trend direction
    let trend: PaceTrend

    /// Calculated hours per week (EMA-weighted or target)
    let hoursPerWeek: Double

    /// Mode used for this projection
    let mode: ProjectionMode

    // MARK: - Formatting

    /// Human-readable projection string
    var formatted: String {
        switch confidence {
        case .insufficient:
            return "Keep practicing to see projection"

        case .low:
            guard let years = years, let upper = yearsUpperBound else {
                return "Keep practicing to see projection"
            }
            if years > 50 {
                return "50+ years (early estimate)"
            }
            return "\(years)-\(upper) years (early estimate)"

        case .medium, .high:
            guard let years = years, let months = months else {
                return "Keep practicing to see projection"
            }
            if years > 100 {
                return "100+ years at current pace"
            } else if years > 50 {
                return "50+ years at current pace"
            } else if years == 0 && months == 0 {
                return "Less than a month"
            } else if years == 0 {
                return "\(months) month\(months == 1 ? "" : "s")"
            } else if months == 0 {
                return "\(years) year\(years == 1 ? "" : "s")"
            } else {
                return "\(years) year\(years == 1 ? "" : "s"), \(months) month\(months == 1 ? "" : "s")"
            }
        }
    }

    /// Trend arrow for display
    var trendArrow: String {
        switch trend {
        case .increasing: return "↑"
        case .steady: return "→"
        case .decreasing: return "↓"
        case .unknown: return ""
        }
    }

    /// Trend description
    var trendDescription: String {
        switch trend {
        case .increasing: return "Trending up"
        case .steady: return "Steady pace"
        case .decreasing: return "Trending down"
        case .unknown: return ""
        }
    }

    // MARK: - Factory Methods

    /// Creates an insufficient data projection
    static func insufficient(mode: ProjectionMode) -> SmartProjection {
        SmartProjection(
            confidence: .insufficient,
            years: nil,
            months: nil,
            yearsUpperBound: nil,
            trend: .unknown,
            hoursPerWeek: 0,
            mode: mode
        )
    }
}

// MARK: - Pace Calculator

/// Calculator for EMA-based and target-based pace projections.
enum PaceCalculator {
    // MARK: - Constants

    /// Rolling window size in weeks for EMA calculation
    static let rollingWindowWeeks: Double = 8.0

    /// EMA smoothing factor (0-1). Higher = more weight on recent data.
    static let emaSmoothingFactor: Double = 0.25

    /// Weeks to consider for "recent" trend calculation
    static let recentTrendWeeks: Double = 2.0

    /// Weeks to consider for "historical" trend calculation
    static let historicalTrendWeeks: Double = 4.0

    /// Minimum unique days required within rolling window
    static let minimumUniqueDays: Int = 3

    /// Threshold for trend change detection (percentage difference)
    static let trendThreshold: Double = 0.15

    // MARK: - Main Calculation

    /// Calculates smart projection using EMA + rolling window method.
    /// - Parameters:
    ///   - sessions: All sessions for the skill
    ///   - hoursRemaining: Hours remaining to reach 10,000
    ///   - currentDate: Current date (injectable for testing)
    /// - Returns: SmartProjection with confidence, estimate, and trend
    static func calculateEMAProjection(
        sessions: [Session],
        hoursRemaining: Int64,
        currentDate: Date = Date()
    ) -> SmartProjection {
        // Filter to sessions within rolling window
        let windowStart = currentDate.addingTimeInterval(-rollingWindowWeeks * Time.secondsPerWeek)
        let windowSessions = sessions.filter { $0.startTime >= windowStart }

        // Check minimum data requirements
        let uniqueDays = countUniqueDays(in: windowSessions)
        guard uniqueDays >= minimumUniqueDays else {
            return .insufficient(mode: .recentPace)
        }

        // Already at mastery?
        guard hoursRemaining > 0 else {
            return SmartProjection(
                confidence: .high,
                years: 0,
                months: 0,
                yearsUpperBound: nil,
                trend: .steady,
                hoursPerWeek: 0,
                mode: .recentPace
            )
        }

        // Calculate EMA-weighted pace
        let emaPace = calculateEMAPace(
            sessions: windowSessions,
            windowStart: windowStart,
            currentDate: currentDate
        )

        guard emaPace > 0 else {
            return .insufficient(mode: .recentPace)
        }

        // Calculate trend
        let trend = calculateTrend(
            sessions: windowSessions,
            currentDate: currentDate
        )

        // Determine confidence level
        let confidence = determineConfidence(
            uniqueDays: uniqueDays,
            windowSessions: windowSessions,
            currentDate: currentDate
        )

        // Calculate projection
        let weeksRemaining = Double(hoursRemaining) / emaPace
        let totalMonths = Int(weeksRemaining / Time.weeksPerMonth)
        let years = totalMonths / Time.monthsPerYear
        let months = totalMonths % Time.monthsPerYear

        // For low confidence, calculate range (±30%)
        let yearsUpperBound: Int? = confidence == .low
            ? Int(Double(years) * 1.3) + 1
            : nil

        return SmartProjection(
            confidence: confidence,
            years: years,
            months: months,
            yearsUpperBound: yearsUpperBound,
            trend: trend,
            hoursPerWeek: emaPace,
            mode: .recentPace
        )
    }

    /// Calculates projection based on user-defined target pace.
    /// - Parameters:
    ///   - targetHoursPerWeek: User's target hours per week
    ///   - hoursRemaining: Hours remaining to reach 10,000
    ///   - sessions: All sessions (used for actual pace comparison)
    ///   - currentDate: Current date (injectable for testing)
    /// - Returns: SmartProjection with target-based estimate
    static func calculateTargetProjection(
        targetHoursPerWeek: Double,
        hoursRemaining: Int64,
        sessions: [Session],
        currentDate: Date = Date()
    ) -> SmartProjection {
        guard targetHoursPerWeek > 0 else {
            return .insufficient(mode: .targetBased)
        }

        guard hoursRemaining > 0 else {
            return SmartProjection(
                confidence: .high,
                years: 0,
                months: 0,
                yearsUpperBound: nil,
                trend: .steady,
                hoursPerWeek: targetHoursPerWeek,
                mode: .targetBased
            )
        }

        // Calculate projection based on target
        let weeksRemaining = Double(hoursRemaining) / targetHoursPerWeek
        let totalMonths = Int(weeksRemaining / Time.weeksPerMonth)
        let years = totalMonths / Time.monthsPerYear
        let months = totalMonths % Time.monthsPerYear

        // Calculate trend comparing actual to target
        let trend = calculateTargetTrend(
            targetHoursPerWeek: targetHoursPerWeek,
            sessions: sessions,
            currentDate: currentDate
        )

        return SmartProjection(
            confidence: .high, // Target-based is always "confident" since user defines it
            years: years,
            months: months,
            yearsUpperBound: nil,
            trend: trend,
            hoursPerWeek: targetHoursPerWeek,
            mode: .targetBased
        )
    }

    // MARK: - EMA Calculation

    /// Calculates EMA-weighted hours per week.
    /// Uses the "active period" from first to last session, not the full rolling window.
    static func calculateEMAPace(
        sessions: [Session],
        windowStart: Date,
        currentDate: Date
    ) -> Double {
        guard !sessions.isEmpty else { return 0 }

        // Sort sessions by date (oldest first for EMA calculation)
        let sortedSessions = sessions.sorted { $0.startTime < $1.startTime }

        // Use active period (first to last session) for EMA, not full window
        // This prevents penalizing new users with weeks of zeros
        guard let firstSession = sortedSessions.first,
              let lastSession = sortedSessions.last else { return 0 }

        let activePeriodStart = firstSession.startTime
        let activePeriodEnd = max(lastSession.startTime, currentDate)

        // Group sessions by week within active period
        let weeklyHours = groupSessionsByWeek(
            sessions: sortedSessions,
            periodStart: activePeriodStart,
            periodEnd: activePeriodEnd
        )

        guard !weeklyHours.isEmpty else { return 0 }

        // Apply EMA
        var ema = weeklyHours[0]
        for i in 1..<weeklyHours.count {
            ema = emaSmoothingFactor * weeklyHours[i] + (1 - emaSmoothingFactor) * ema
        }

        return ema
    }

    /// Groups sessions into weekly buckets and returns hours per week.
    static func groupSessionsByWeek(
        sessions: [Session],
        periodStart: Date,
        periodEnd: Date
    ) -> [Double] {
        // Calculate number of weeks in period
        let periodDays = periodEnd.timeIntervalSince(periodStart) / Time.secondsPerDay
        let numWeeks = max(1, Int(ceil(periodDays / 7)))

        // Initialize weekly buckets
        var weeklyHours = [Double](repeating: 0, count: numWeeks)

        for session in sessions {
            let daysSincePeriodStart = session.startTime.timeIntervalSince(periodStart) / Time.secondsPerDay
            let weekIndex = min(max(0, Int(daysSincePeriodStart / 7)), numWeeks - 1)
            let hours = Double(session.durationSeconds) / Double(Time.secondsPerHour)
            weeklyHours[weekIndex] += hours
        }

        // Remove trailing zero weeks (incomplete current week handling)
        while weeklyHours.count > 1 && weeklyHours.last == 0 {
            weeklyHours.removeLast()
        }

        return weeklyHours
    }

    // MARK: - Trend Calculation

    /// Calculates trend by comparing recent pace to historical pace.
    static func calculateTrend(
        sessions: [Session],
        currentDate: Date
    ) -> PaceTrend {
        // Need enough data to calculate trend
        guard sessions.count >= 3 else { return .unknown }

        let recentStart = currentDate.addingTimeInterval(-recentTrendWeeks * Time.secondsPerWeek)
        let historicalStart = currentDate.addingTimeInterval(-(recentTrendWeeks + historicalTrendWeeks) * Time.secondsPerWeek)

        // Recent sessions (last 2 weeks)
        let recentSessions = sessions.filter { $0.startTime >= recentStart }

        // Historical sessions (2-6 weeks ago)
        let historicalSessions = sessions.filter {
            $0.startTime >= historicalStart && $0.startTime < recentStart
        }

        // Need data in both periods to compare
        guard !recentSessions.isEmpty && !historicalSessions.isEmpty else {
            return .unknown
        }

        // Calculate hours per week for each period
        let recentHours = totalHours(in: recentSessions)
        let recentWeeks = recentTrendWeeks
        let recentPace = recentHours / recentWeeks

        let historicalHours = totalHours(in: historicalSessions)
        let historicalWeeks = historicalTrendWeeks
        let historicalPace = historicalHours / historicalWeeks

        guard historicalPace > 0 else {
            return recentPace > 0 ? .increasing : .unknown
        }

        let percentChange = (recentPace - historicalPace) / historicalPace

        if percentChange > trendThreshold {
            return .increasing
        } else if percentChange < -trendThreshold {
            return .decreasing
        } else {
            return .steady
        }
    }

    /// Calculates trend comparing actual pace to target.
    static func calculateTargetTrend(
        targetHoursPerWeek: Double,
        sessions: [Session],
        currentDate: Date
    ) -> PaceTrend {
        // Calculate actual pace over last 2 weeks
        let recentStart = currentDate.addingTimeInterval(-recentTrendWeeks * Time.secondsPerWeek)
        let recentSessions = sessions.filter { $0.startTime >= recentStart }

        guard !recentSessions.isEmpty else { return .unknown }

        let recentHours = totalHours(in: recentSessions)
        let actualPace = recentHours / recentTrendWeeks

        let percentDiff = (actualPace - targetHoursPerWeek) / targetHoursPerWeek

        if percentDiff > trendThreshold {
            return .increasing // Ahead of target
        } else if percentDiff < -trendThreshold {
            return .decreasing // Behind target
        } else {
            return .steady // On target
        }
    }

    // MARK: - Confidence Calculation

    /// Determines confidence level based on data quality.
    static func determineConfidence(
        uniqueDays: Int,
        windowSessions: [Session],
        currentDate: Date
    ) -> ProjectionConfidence {
        guard uniqueDays >= minimumUniqueDays else {
            return .insufficient
        }

        // Check span of data
        guard let firstSession = windowSessions.min(by: { $0.startTime < $1.startTime }),
              let lastSession = windowSessions.max(by: { $0.startTime < $1.startTime }) else {
            return .insufficient
        }

        let dataSpanWeeks = lastSession.startTime.timeIntervalSince(firstSession.startTime) / Time.secondsPerWeek

        if uniqueDays >= 15 && dataSpanWeeks >= 4 {
            return .high
        } else if uniqueDays >= 7 || dataSpanWeeks >= 2 {
            return .medium
        } else {
            return .low
        }
    }

    // MARK: - Helper Methods

    /// Counts unique calendar days with sessions.
    static func countUniqueDays(in sessions: [Session]) -> Int {
        let calendar = Calendar.current
        let uniqueDays = Set(sessions.map { calendar.startOfDay(for: $0.startTime) })
        return uniqueDays.count
    }

    /// Calculates total hours from sessions.
    static func totalHours(in sessions: [Session]) -> Double {
        sessions.reduce(0) { total, session in
            total + Double(session.durationSeconds) / Double(Time.secondsPerHour)
        }
    }

    // MARK: - Actual vs Target Comparison

    /// Returns the actual hours per week over the last 2 weeks.
    static func actualRecentPace(
        sessions: [Session],
        currentDate: Date = Date()
    ) -> Double {
        let recentStart = currentDate.addingTimeInterval(-recentTrendWeeks * Time.secondsPerWeek)
        let recentSessions = sessions.filter { $0.startTime >= recentStart }
        let hours = totalHours(in: recentSessions)
        return hours / recentTrendWeeks
    }

    /// Returns the gap between actual and target pace.
    static func targetGap(
        targetHoursPerWeek: Double,
        sessions: [Session],
        currentDate: Date = Date()
    ) -> Double {
        let actual = actualRecentPace(sessions: sessions, currentDate: currentDate)
        return actual - targetHoursPerWeek
    }
}
