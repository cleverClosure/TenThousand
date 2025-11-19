//
//  HeatmapWindowPreferences.swift
//  TenThousand
//
//  Manages window size, position, and view preferences
//

import Foundation
import SwiftUI

class HeatmapWindowPreferences: ObservableObject {
    private static let windowFrameKey = "heatmapWindowFrame"
    private static let selectedViewModeKey = "heatmapViewMode"
    private static let selectedSkillIdKey = "heatmapSelectedSkillId"

    @Published var windowFrame: CGRect {
        didSet {
            saveWindowFrame()
        }
    }

    @Published var selectedViewMode: HeatmapViewMode {
        didSet {
            saveViewMode()
        }
    }

    @Published var selectedSkillId: UUID? {
        didSet {
            saveSelectedSkillId()
        }
    }

    init() {
        // Load window frame or use default
        if let frameData = UserDefaults.standard.data(forKey: Self.windowFrameKey),
           let frame = try? JSONDecoder().decode(CGRect.self, from: frameData) {
            self.windowFrame = frame
        } else {
            // Default size: 800x600
            self.windowFrame = CGRect(x: 100, y: 100, width: 800, height: 600)
        }

        // Load view mode
        if let modeRaw = UserDefaults.standard.string(forKey: Self.selectedViewModeKey),
           let mode = HeatmapViewMode(rawValue: modeRaw) {
            self.selectedViewMode = mode
        } else {
            self.selectedViewMode = .year
        }

        // Load selected skill ID
        if let idString = UserDefaults.standard.string(forKey: Self.selectedSkillIdKey),
           let uuid = UUID(uuidString: idString) {
            self.selectedSkillId = uuid
        } else {
            self.selectedSkillId = nil // "All Skills" mode
        }
    }

    private func saveWindowFrame() {
        if let encoded = try? JSONEncoder().encode(windowFrame) {
            UserDefaults.standard.set(encoded, forKey: Self.windowFrameKey)
        }
    }

    private func saveViewMode() {
        UserDefaults.standard.set(selectedViewMode.rawValue, forKey: Self.selectedViewModeKey)
    }

    private func saveSelectedSkillId() {
        if let id = selectedSkillId {
            UserDefaults.standard.set(id.uuidString, forKey: Self.selectedSkillIdKey)
        } else {
            UserDefaults.standard.removeObject(forKey: Self.selectedSkillIdKey)
        }
    }
}

// MARK: - View Mode Enum

enum HeatmapViewMode: String, CaseIterable, Identifiable {
    case week = "week"
    case month = "month"
    case year = "year"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        }
    }

    var daysToShow: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .year: return 365
        }
    }
}

// MARK: - CGRect Codable Extension

extension CGRect: Codable {
    enum CodingKeys: String, CodingKey {
        case x, y, width, height
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(origin.x, forKey: .x)
        try container.encode(origin.y, forKey: .y)
        try container.encode(size.width, forKey: .width)
        try container.encode(size.height, forKey: .height)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(CGFloat.self, forKey: .x)
        let y = try container.decode(CGFloat.self, forKey: .y)
        let width = try container.decode(CGFloat.self, forKey: .width)
        let height = try container.decode(CGFloat.self, forKey: .height)
        self.init(x: x, y: y, width: width, height: height)
    }
}
