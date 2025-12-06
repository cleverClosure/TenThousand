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
