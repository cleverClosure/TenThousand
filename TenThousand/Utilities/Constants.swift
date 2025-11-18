//
//  Constants.swift
//  TenThousand
//
//  Created by Tim Isaev on 18.11.2025.
//

import Foundation

enum Constants {
    // MARK: - Design System

    // App Identity
    static let appName = "10k"
    static let appTagline = "Track your path to mastery"

    // UI Dimensions
    static let panelWidth: CGFloat = 360  // Updated from 320 to match design spec
    static let panelPadding: CGFloat = 20  // Updated from 16 for more generous spacing
    static let sectionSpacing: CGFloat = 16
    static let rowSpacing: CGFloat = 12  // Updated from 8 for better breathing room
    static let buttonPaddingHorizontal: CGFloat = 16  // Updated from 12
    static let buttonPaddingVertical: CGFloat = 8

    // Spacing Scale (Design Tokens)
    static let spacing_xs: CGFloat = 4
    static let spacing_sm: CGFloat = 8
    static let spacing_md: CGFloat = 12
    static let spacing_lg: CGFloat = 16
    static let spacing_xl: CGFloat = 24

    // Border Radius Scale
    static let radius_sm: CGFloat = 6
    static let radius_md: CGFloat = 10
    static let radius_lg: CGFloat = 12
    static let radius_xl: CGFloat = 16

    // Typography Sizes (SF Pro)
    static let fontSize_hero: CGFloat = 36
    static let fontSize_title1: CGFloat = 24
    static let fontSize_title2: CGFloat = 22
    static let fontSize_headline: CGFloat = 16
    static let fontSize_body: CGFloat = 14
    static let fontSize_callout: CGFloat = 13
    static let fontSize_caption: CGFloat = 11

    // Skill Colors (Updated to match design spec)
    static let skillColors = [
        "#6366F1",  // Electric Indigo (Default for first skill)
        "#F59E0B",  // Amber Gold (Warm, energetic)
        "#10B981",  // Emerald Green (Growth, progress)
        "#EF4444",  // Crimson Red (Passion, intensity)
        "#8B5CF6",  // Royal Purple (Creative, artistic)
        "#EC4899",  // Hot Pink (Bold, memorable)
        "#3B82F6",  // Sky Blue (Calm, focused)
        "#F97316"   // Coral Orange (Enthusiastic)
    ]

    // State Colors
    static let color_active = "#10B981"      // Vibrant green
    static let color_paused = "#F59E0B"      // Warm orange
    static let color_idle = "#86868B"        // Neutral gray
    static let color_danger = "#EF4444"      // Red

    // Progress Bar
    static let progressBarHeight: CGFloat = 6
    static let progressBarRadius: CGFloat = 3

    // Defaults
    static let defaultGoalHours: Double = 10000
    static let autosaveInterval: TimeInterval = 60.0

    // UserDefaults Keys
    static let skillsKey = "savedSkills"
    static let launchAtStartupKey = "launchAtStartup"
}
