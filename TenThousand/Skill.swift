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

@Model
final class Skill {

    // MARK: - Properties

    var id: UUID
    var name: String
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

    // MARK: - Initialization

    init(name: String, colorIndex: Int16 = 0) {
        self.id = UUID()
        self.name = name
        self.colorIndex = colorIndex
        self.createdAt = Date()
    }
}

extension Skill: Identifiable {}
