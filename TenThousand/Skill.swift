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

    @Relationship(deleteRule: .cascade, inverse: \Session.skill)
    var sessions: [Session] = []

    // MARK: - Computed Properties

    /// Total tracked seconds across all sessions for this skill.
    var totalSeconds: Int64 {
        sessions.reduce(0) { total, session in
            total + session.durationSeconds
        }
    }

    /// Total hours tracked (decimal).
    var totalHours: Double {
        Double(totalSeconds) / Double(TimeConstants.secondsPerHour)
    }

    /// Progress toward 10,000 hours mastery (0.0 to 1.0).
    var masteryProgress: Double {
        min(Double(totalSeconds) / Double(MasteryConstants.masterySeconds), 1.0)
    }

    /// Progress percentage (0 to 100).
    var masteryPercentage: Double {
        masteryProgress * 100
    }

    /// Hours remaining to reach 10,000 hours.
    var hoursRemaining: Int64 {
        max(MasteryConstants.masteryHours - Int64(totalHours), 0)
    }

    /// Date of the first session, if any.
    var firstSessionDate: Date? {
        sessions.map(\.startTime).min()
    }

    /// Weeks since first session (minimum 1 week to avoid division issues).
    var weeksSinceStart: Double {
        guard let firstDate = firstSessionDate else { return 0 }
        let seconds = Date().timeIntervalSince(firstDate)
        let weeks = seconds / (7 * 24 * 60 * 60)
        return max(weeks, 1.0 / 7.0) // Minimum 1 day
    }

    /// Average hours practiced per week.
    var hoursPerWeek: Double {
        guard weeksSinceStart > 0 else { return 0 }
        return totalHours / weeksSinceStart
    }

    /// Projected time to reach 10,000 hours at current pace.
    /// Returns nil if no sessions yet or pace is zero.
    var projectedTimeToMastery: MasteryProjection? {
        guard hoursPerWeek > 0, hoursRemaining > 0 else { return nil }

        let weeksRemaining = Double(hoursRemaining) / hoursPerWeek
        let totalMonths = Int(weeksRemaining / 4.33) // Average weeks per month

        let years = totalMonths / 12
        let months = totalMonths % 12

        return MasteryProjection(years: years, months: months)
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
