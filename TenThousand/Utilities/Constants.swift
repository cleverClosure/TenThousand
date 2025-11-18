//
//  Constants.swift
//  TenThousand
//
//  Created by Tim Isaev on 18.11.2025.
//

import Foundation

enum Constants {
    // UI Dimensions
    static let panelWidth: CGFloat = 320
    static let panelPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 12
    static let rowSpacing: CGFloat = 8
    static let buttonPaddingHorizontal: CGFloat = 12
    static let buttonPaddingVertical: CGFloat = 8

    // Colors
    static let skillColors = [
        "#FF6B6B", // Red
        "#4ECDC4", // Teal
        "#45B7D1", // Blue
        "#FFA07A", // Orange
        "#98D8C8", // Mint
        "#F7DC6F", // Yellow
        "#BB8FCE", // Purple
        "#85C1E2"  // Light Blue
    ]

    // Defaults
    static let defaultGoalHours: Double = 10000
    static let autosaveInterval: TimeInterval = 60.0

    // UserDefaults Keys
    static let skillsKey = "savedSkills"
    static let launchAtStartupKey = "launchAtStartup"
}
