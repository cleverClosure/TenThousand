//
//  Skill.swift
//  TenThousand
//
//  Created by Tim Isaev on 18.11.2025.
//

import Foundation
import SwiftUI

struct Skill: Codable, Identifiable {
    let id: UUID
    var name: String
    var totalSeconds: Double
    var goalHours: Double
    var colorHex: String
    let createdAt: Date
    var sessions: [Session]
    var currentSession: Session?

    init(
        id: UUID = UUID(),
        name: String,
        totalSeconds: Double = 0,
        goalHours: Double = 10000,
        colorHex: String,
        createdAt: Date = Date(),
        sessions: [Session] = [],
        currentSession: Session? = nil
    ) {
        self.id = id
        self.name = name
        self.totalSeconds = totalSeconds
        self.goalHours = goalHours
        self.colorHex = colorHex
        self.createdAt = createdAt
        self.sessions = sessions
        self.currentSession = currentSession
    }

    // MARK: - Computed Properties

    var totalHours: Double {
        totalSeconds / 3600.0
    }

    var percentComplete: Double {
        (totalHours / goalHours) * 100.0
    }

    var isTracking: Bool {
        currentSession != nil
    }

    var color: Color {
        Color(hex: colorHex) ?? .blue
    }

    // MARK: - Time Tracking

    mutating func startTracking() {
        currentSession = Session()
    }

    mutating func pauseTracking() {
        guard var session = currentSession else { return }
        session.endTime = Date()
        totalSeconds += session.duration
        sessions.append(session)
        currentSession = nil
    }

    mutating func addTime(_ seconds: TimeInterval) {
        totalSeconds += seconds
    }

    // MARK: - Projections

    func projectedCompletionDate() -> Date? {
        let last30DaysSeconds = totalSecondsInLast30Days()
        guard last30DaysSeconds > 0 else { return nil }

        let remainingSeconds = (goalHours * 3600.0) - totalSeconds
        let weeksToComplete = (remainingSeconds / last30DaysSeconds) * (30.0 / 7.0)
        let daysToComplete = weeksToComplete * 7.0

        return Calendar.current.date(byAdding: .day, value: Int(daysToComplete), to: Date())
    }

    private func totalSecondsInLast30Days() -> Double {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let recentSessions = sessions.filter { $0.startTime >= thirtyDaysAgo }
        return recentSessions.reduce(0) { $0 + $1.duration }
    }

    // MARK: - Formatting

    func formattedTotalTime() -> String {
        let hours = Int(totalHours)
        let minutes = Int((totalSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h \(minutes)m"
    }

    func formattedGoal() -> String {
        let hours = Int(goalHours)
        return "\(hours.formatted())h"
    }

    func formattedPercentage() -> String {
        String(format: "%.1f%%", percentComplete)
    }
}

// MARK: - Color Extension

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    func toHex() -> String? {
        guard let components = NSColor(self).cgColor.components,
              components.count >= 3 else { return nil }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])

        return String(format: "#%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
}
