//
//  Tokens.swift
//  TenThousand
//
//  Created by Tim Isaev
//
//  Design System
//
//  PHILOSOPHY:
//  1. System-First: Use macOS semantic colors for UI chrome
//  2. 8-Point Grid: All spacing is multiples of 4 (4, 8, 12, 16, 24, 32)
//  3. Minimal Tokens: Only define what differs from system defaults
//  4. Semantic Naming: Names describe purpose, not appearance
//
//  USAGE:
//  All design tokens are accessed via the DS namespace:
//    DS.Spacing.md
//    DS.DS.Color.accent
//    DS.Font.title
//    DS.Opacity.subtle
//

import SwiftUI

// MARK: - Design System Namespace

enum DS {
    // MARK: - Spacing (8-Point Grid)
    //
    // Based on 4px base unit. Use for all padding, margins, and gaps.
    //
    enum Spacing {
        static let xs: CGFloat = 4      // Tight: icon padding, inline gaps
        static let sm: CGFloat = 8      // Small: related element spacing
        static let md: CGFloat = 12     // Medium: default internal padding
        static let lg: CGFloat = 16     // Large: section padding
        static let xl: CGFloat = 24     // Extra large: major sections
        static let xxl: CGFloat = 32    // Maximum: generous whitespace
    }

    // MARK: - Sizing
    //
    // Component-specific dimensions grouped by feature area.
    //
    enum Size {
        // Panel
        static let panelWidth: CGFloat = 320
        static let panelMinHeight: CGFloat = 140
        static let panelMaxHeight: CGFloat = 480

        // Skill rows
        static let skillRowHeight: CGFloat = 72
        static let colorDot: CGFloat = 28
        static let colorDotSmall: CGFloat = 12
        static let percentageLabel: CGFloat = 48

        // Buttons
        static let buttonHeight: CGFloat = 36
        static let colorPickerButton: CGFloat = 32

        // Progress indicators
        static let progressBarHeight: CGFloat = 6
        static let progressBarLarge: CGFloat = 10
        static let circularProgress: CGFloat = 140
        static let circularStroke: CGFloat = 10

        // Active session
        static let pulseIndicator: CGFloat = 6

        // Icons
        static let iconSmall: CGFloat = 14
        static let iconMedium: CGFloat = 20
        static let iconLarge: CGFloat = 32

        // Menubar
        static let menubarTimer: CGFloat = 52
        static let menubarIcon: CGFloat = 20
        static let menubarStroke: CGFloat = 2

        // Typography
        static let heroTimer: CGFloat = 64
        static let heroHours: CGFloat = 56
    }

    // MARK: - Radius
    //
    // Corner radii for rounded elements.
    //
    enum Radius {
        static let small: CGFloat = 6
        static let medium: CGFloat = 10
        static let large: CGFloat = 14
    }

    // MARK: - Opacity
    //
    // Semantic opacity levels for backgrounds, overlays, and states.
    //
    enum Opacity {
        // Backgrounds
        static let subtle: Double = 0.04      // Subtle backgrounds
        static let light: Double = 0.06       // Light backgrounds
        static let medium: Double = 0.10      // Hover states
        static let strong: Double = 0.15      // Visible backgrounds

        // Overlays
        static let overlay: Double = 0.30     // Borders, overlays
        static let overlayDark: Double = 0.40 // Dark overlays

        // States
        static let muted: Double = 0.50       // Disabled, de-emphasized
        static let secondary: Double = 0.60   // Secondary text opacity
        static let prominent: Double = 0.70   // Secondary but visible
        static let accent: Double = 0.80      // Accent emphasis
        static let gradient: Double = 0.85    // Gradient endpoints
    }

    // MARK: - Shadow
    //
    // Pre-configured shadow values for elevation hierarchy.
    //
    enum Shadow {
        struct Config {
            let radius: CGFloat
            let y: CGFloat
            let opacity: Double
        }

        static let panel = Config(radius: 24, y: 8, opacity: 0.12)
        static let elevated = Config(radius: 4, y: 2, opacity: 0.15)
        static let glow = Config(radius: 8, y: 0, opacity: 0.25)
        static let subtle = Config(radius: 2, y: 0, opacity: 0.50)
        static let colorGlow = Config(radius: 2, y: 1, opacity: 0.15)
    }

    // MARK: - Animation
    //
    // Timing durations for consistent motion.
    //
    enum Duration {
        static let quick: Double = 0.15
        static let standard: Double = 0.25
        static let emphasized: Double = 0.4
        static let slow: Double = 0.6
        static let pulse: Double = 1.5
        static let highlight: Double = 1.0
    }

    // MARK: - Scale
    //
    // Transform scales for interactive states.
    //
    enum Scale {
        static let pressed: CGFloat = 0.97
        static let hover: CGFloat = 1.02
        static let dismiss: CGFloat = 0.95
    }
}

// MARK: - Animation Extensions

extension Animation {
    static let dsQuick = Animation.easeOut(duration: DS.Duration.quick)
    static let dsStandard = Animation.easeInOut(duration: DS.Duration.standard)
    static let dsEmphasized = Animation.easeOut(duration: DS.Duration.emphasized)
}

// MARK: - Time Constants

enum Time {
    static let secondsPerMinute: Int64 = 60
    static let secondsPerHour: Int64 = 3600
    static let timerUpdateInterval: TimeInterval = 1.0
}

// MARK: - Limits

enum Limits {
    static let maxSkillNameLength = 30
    static let maxSkillCount = 12
}

// MARK: - Mastery

enum Mastery {
    static let targetHours: Int64 = 10_000
    static let targetSeconds: Int64 = targetHours * Time.secondsPerHour
}

// MARK: - Mastery Projection

struct MasteryProjection {
    let years: Int
    let months: Int

    var formatted: String {
        if years == 0 && months == 0 {
            return "less than a month"
        } else if years == 0 {
            return "\(months) month\(months == 1 ? "" : "s")"
        } else if months == 0 {
            return "\(years) year\(years == 1 ? "" : "s")"
        } else {
            return "\(years) year\(years == 1 ? "" : "s"), \(months) month\(months == 1 ? "" : "s")"
        }
    }
}

// MARK: - Format Strings

enum Format {
    static let timeWithHours = "%d:%02d:%02d"
    static let timeWithoutHours = "%02d:%02d"
}
