//
//  Session.swift
//  TenThousand
//
//  Created by Tim Isaev
//
//  SwiftData model for tracking sessions
//

import Foundation
import SwiftData

@Model
final class Session {

    // MARK: - Properties

    var id: UUID
    var startTime: Date
    var endTime: Date?
    var pausedDuration: Int64

    var skill: Skill?

    // MARK: - Computed Properties

    /// Duration in seconds, excluding paused time.
    var durationSeconds: Int64 {
        let end = endTime ?? Date()
        let duration = Int64(end.timeIntervalSince(startTime)) - pausedDuration
        return max(0, duration)
    }

    // MARK: - Initialization

    init(skill: Skill) {
        self.id = UUID()
        self.startTime = Date()
        self.pausedDuration = 0
        self.skill = skill
    }
}

extension Session: Identifiable {}
