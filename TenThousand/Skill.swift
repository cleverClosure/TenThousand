//
//  Skill.swift
//  TenThousand
//
//  Created by Tim Isaev
//
//  SwiftData model for skills
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Skill {
    // MARK: - Properties

    var id: UUID
    var name: String
    var paletteId: String
    var colorIndex: Int16
    var createdAt: Date

    /// Mode used for pace projection (recentPace or targetBased)
    var projectionModeRaw: String = ProjectionMode.recentPace.rawValue

    /// Target hours per week for target-based projection mode
    var targetHoursPerWeek: Double?

    @Relationship(deleteRule: .cascade, inverse: \Session.skill)
    var sessions: [Session] = []

    // MARK: - Projection Mode

    /// The projection mode for this skill
    var projectionMode: ProjectionMode {
        get { ProjectionMode(rawValue: projectionModeRaw) ?? .recentPace }
        set { projectionModeRaw = newValue.rawValue }
    }

    // MARK: - Computed Properties

    /// Total tracked seconds across all sessions for this skill.
    var totalSeconds: Int64 {
        sessions.reduce(0) { total, session in
            total + session.durationSeconds
        }
    }

    /// Total hours tracked (decimal).
    var totalHours: Double {
        Double(totalSeconds) / Double(Time.secondsPerHour)
    }

    /// Progress toward 10,000 hours mastery (0.0 to 1.0).
    var masteryProgress: Double {
        min(Double(totalSeconds) / Double(Mastery.targetSeconds), 1.0)
    }

    /// Progress percentage (0 to 100).
    var masteryPercentage: Double {
        masteryProgress * 100
    }

    /// Hours remaining to reach 10,000 hours.
    var hoursRemaining: Int64 {
        max(Mastery.targetHours - Int64(totalHours), 0)
    }

    /// Date of the first session, if any.
    var firstSessionDate: Date? {
        sessions.map(\.startTime).min()
    }

    /// Date of the last session, if any.
    var lastSessionDate: Date? {
        sessions.map(\.startTime).max()
    }

    /// Number of unique calendar days with logged sessions.
    var uniqueLoggedDays: Int {
        let calendar = Calendar.current
        let uniqueDays = Set(sessions.map { calendar.startOfDay(for: $0.startTime) })
        return uniqueDays.count
    }

    /// Weeks in the "closed" tracking period (first session to last session).
    /// This excludes the open-ended time after the last session.
    private var closedPeriodWeeks: Double {
        guard let firstDate = firstSessionDate,
              let lastDate = lastSessionDate else { return 0 }

        let seconds = lastDate.timeIntervalSince(firstDate)
        let weeks = seconds / Time.secondsPerWeek
        return max(weeks, 1.0 / 7.0) // Minimum 1 day
    }

    /// Average hours practiced per week, based on closed period only.
    var hoursPerWeek: Double {
        guard closedPeriodWeeks > 0 else { return 0 }
        return totalHours / closedPeriodWeeks
    }

    /// Projected time to reach 10,000 hours at current pace.
    /// Returns nil if fewer than 3 unique days logged, no sessions, or pace is zero.
    @available(*, deprecated, message: "Use smartProjection instead")
    var projectedTimeToMastery: MasteryProjection? {
        // Require at least 3 unique logged days for a meaningful projection
        guard uniqueLoggedDays >= 3,
              hoursPerWeek > 0,
              hoursRemaining > 0 else { return nil }

        let weeksRemaining = Double(hoursRemaining) / hoursPerWeek
        let totalMonths = Int(weeksRemaining / Time.weeksPerMonth)

        let years = totalMonths / Time.monthsPerYear
        let months = totalMonths % Time.monthsPerYear

        return MasteryProjection(years: years, months: months)
    }

    /// Smart projection using EMA + Rolling Window or Target-based mode.
    /// Includes confidence level, trend direction, and formatted display.
    var smartProjection: SmartProjection {
        smartProjection(at: Date())
    }

    /// Smart projection with injectable date for testing.
    func smartProjection(at currentDate: Date) -> SmartProjection {
        switch projectionMode {
        case .recentPace:
            return PaceCalculator.calculateEMAProjection(
                sessions: sessions,
                hoursRemaining: hoursRemaining,
                currentDate: currentDate
            )
        case .targetBased:
            guard let target = targetHoursPerWeek, target > 0 else {
                return .insufficient(mode: .targetBased)
            }
            return PaceCalculator.calculateTargetProjection(
                targetHoursPerWeek: target,
                hoursRemaining: hoursRemaining,
                sessions: sessions,
                currentDate: currentDate
            )
        }
    }

    /// Actual pace over the last 2 weeks (for comparison with target).
    var actualRecentPace: Double {
        PaceCalculator.actualRecentPace(sessions: sessions)
    }

    /// Gap between actual and target pace (positive = ahead, negative = behind).
    var targetPaceGap: Double? {
        guard let target = targetHoursPerWeek else { return nil }
        return PaceCalculator.targetGap(
            targetHoursPerWeek: target,
            sessions: sessions
        )
    }

    /// The resolved color for this skill based on palette and color index.
    var color: Color {
        ColorPaletteManager.shared.color(forPaletteId: paletteId, colorIndex: Int(colorIndex))
    }

    // MARK: - Initialization

    init(name: String, paletteId: String, colorIndex: Int16) {
        self.id = UUID()
        self.name = name
        self.paletteId = paletteId
        self.colorIndex = colorIndex
        self.createdAt = Date()
    }
}

extension Skill: Identifiable {}
