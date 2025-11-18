//
//  Session.swift
//  TenThousand
//
//  Created by Tim Isaev on 18.11.2025.
//

import Foundation

struct Session: Codable, Identifiable {
    let id: UUID
    let startTime: Date
    var endTime: Date?

    init(id: UUID = UUID(), startTime: Date = Date(), endTime: Date? = nil) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
    }

    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }
}
