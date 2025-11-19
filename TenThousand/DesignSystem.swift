//
//  DesignSystem.swift
//  TenThousand
//
//  Complete design system following MVP specification
//

import SwiftUI

// MARK: - Colors

extension Color {
    // Light Mode Neutrals
    static let pureWhite = Color(hex: "FFFFFF")
    static let softWhite = Color(hex: "FAFAFA")
    static let whisper = Color(hex: "F5F5F5")
    static let mist = Color(hex: "E8E8E8")
    static let stone = Color(hex: "B8B8B8")
    static let graphite = Color(hex: "6B6B6B")
    static let ink = Color(hex: "1C1C1C")
    static let pureBlack = Color(hex: "000000")

    // Dark Mode Neutrals
    static let trueBlack = Color(hex: "000000")
    static let richBlack = Color(hex: "0A0A0A")
    static let coal = Color(hex: "141414")
    static let charcoal = Color(hex: "2A2A2A")
    static let ash = Color(hex: "6B6B6B")
    static let silver = Color(hex: "9B9B9B")
    static let pearl = Color(hex: "E8E8E8")

    // Accent Colors
    static let trackingBlue = Color(hex: "A8D5FF")    // Sky Whisper

    // Adaptive Colors
    static let canvasBase = Color(nsColor: .windowBackgroundColor)
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary

    // Helper initializer for hex color strings
    fileprivate init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Typography

struct Typography {
    // Display (Skill Names, Large Numbers)
    // Letter Spacing: -0.3px, Line Height: 20px
    static let display = Font.system(size: 16, weight: .medium, design: .default)
    static let displayKerning: CGFloat = -0.3
    static let displayLineHeight: CGFloat = 20

    // Body (General Text)
    // Letter Spacing: -0.08px, Line Height: 16px
    static let body = Font.system(size: 13, weight: .regular, design: .default)
    static let bodyKerning: CGFloat = -0.08
    static let bodyLineHeight: CGFloat = 16

    // Caption (Secondary Information)
    // Letter Spacing: 0px, Line Height: 13px
    static let caption = Font.system(size: 11, weight: .regular, design: .default)
    static let captionKerning: CGFloat = 0
    static let captionLineHeight: CGFloat = 13

    // Time Display (Active Timer)
    // Letter Spacing: 0.5px, Line Height: 16px
    static let timeDisplay = Font.system(size: 14, weight: .medium, design: .monospaced)
        .monospacedDigit()
    static let timeDisplayKerning: CGFloat = 0.5
    static let timeDisplayLineHeight: CGFloat = 16

    // Large Time Display
    static let largeTimeDisplay = Font.system(size: 20, weight: .medium, design: .monospaced)
        .monospacedDigit()
    static let largeTimeDisplayKerning: CGFloat = 0.5
    static let largeTimeDisplayLineHeight: CGFloat = 24
}

// MARK: - Typography View Modifiers

extension View {
    func displayFont() -> some View {
        self
            .font(Typography.display)
            .kerning(Typography.displayKerning)
            .lineSpacing(Typography.displayLineHeight - 16)
    }

    func bodyFont() -> some View {
        self
            .font(Typography.body)
            .kerning(Typography.bodyKerning)
            .lineSpacing(Typography.bodyLineHeight - 13)
    }

    func captionFont() -> some View {
        self
            .font(Typography.caption)
            .kerning(Typography.captionKerning)
            .lineSpacing(Typography.captionLineHeight - 11)
    }

    func timeDisplayFont() -> some View {
        self
            .font(Typography.timeDisplay)
            .kerning(Typography.timeDisplayKerning)
            .lineSpacing(Typography.timeDisplayLineHeight - 14)
            .monospacedDigit()
    }

    func largeTimeDisplayFont() -> some View {
        self
            .font(Typography.largeTimeDisplay)
            .kerning(Typography.largeTimeDisplayKerning)
            .lineSpacing(Typography.largeTimeDisplayLineHeight - 20)
            .monospacedDigit()
    }
}

// MARK: - Spacing

struct Spacing {
    static let atomic: CGFloat = 2
    static let tight: CGFloat = 4
    static let base: CGFloat = 8
    static let loose: CGFloat = 12
    static let section: CGFloat = 16
    static let chunk: CGFloat = 24
}

// MARK: - Dimensions

struct Dimensions {
    // Panel
    static let panelWidth: CGFloat = 280
    static let panelMinHeight: CGFloat = 120
    static let panelMaxHeight: CGFloat = 400
    static let panelCornerRadius: CGFloat = 12

    // Skill Row
    static let skillRowHeight: CGFloat = 36
    static let skillRowPaddingHorizontal: CGFloat = 8
    static let skillRowPaddingVertical: CGFloat = 6
    static let colorDotSize: CGFloat = 20

    // Active Session
    static let activeSessionHeight: CGFloat = 64

    // Today's Summary
    static let todaySummaryHeight: CGFloat = 48

    // Heatmap
    static let heatmapHeight: CGFloat = 88
    static let heatmapCellWidth: CGFloat = 32
    static let heatmapCellHeight: CGFloat = 16
    static let heatmapGap: CGFloat = 2
    static let heatmapCellRadius: CGFloat = 4

    // Corner Radii
    static let cornerRadiusSmall: CGFloat = 4
    static let cornerRadiusMedium: CGFloat = 8
    static let cornerRadiusLarge: CGFloat = 12

    // Icon Sizes
    static let iconSizeSmall: CGFloat = 14
    static let iconSizeMedium: CGFloat = 24

    // Dividers
    static let dividerHeight: CGFloat = 1
}

// MARK: - Animations

extension Animation {
    static let microInteraction = Animation.timingCurve(0.4, 0, 0.2, 1, duration: 0.2)
    static let panelTransition = Animation.timingCurve(0.4, 0, 0.2, 1, duration: 0.3)
    static let countUp = Animation.timingCurve(0.4, 0, 0.2, 1, duration: 0.4)
    static let hoverState = Animation.timingCurve(0.4, 0, 0.2, 1, duration: 0.15)
}

// MARK: - Opacity

struct Opacity {
    // Backgrounds
    static let backgroundSubtle: Double = 0.02
    static let backgroundLight: Double = 0.03
    static let backgroundMedium: Double = 0.05
    static let backgroundDark: Double = 0.08

    // Overlays & Highlights
    static let overlayLight: Double = 0.10
    static let overlayMedium: Double = 0.20
    static let overlayStrong: Double = 0.30

    // Heatmap levels
    static let heatmapLevel0: Double = 0.05
    static let heatmapLevel1: Double = 0.10
    static let heatmapLevel2: Double = 0.25
    static let heatmapLevel3: Double = 0.40
    static let heatmapLevel4: Double = 0.60
    static let heatmapLevel5: Double = 0.80

    // Borders & Strokes
    static let borderSubtle: Double = 0.30
}

// MARK: - Shadows

struct Shadow {
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    let opacity: Double
}

struct Shadows {
    static let floating = Shadow(
        radius: 24,
        x: 0,
        y: 8,
        opacity: 0.12
    )
}

// MARK: - Scale Values

struct ScaleValues {
    static let normal: CGFloat = 1.0
    static let hoverGrow: CGFloat = 1.05
    static let pressedShrink: CGFloat = 0.98
    static let dismissScale: CGFloat = 0.95
}

// MARK: - Time Constants

struct TimeConstants {
    static let secondsPerMinute: Int64 = 60
    static let secondsPerHour: Int64 = 3600
    static let timerUpdateInterval: TimeInterval = 1.0
}

// MARK: - Validation Limits

struct ValidationLimits {
    static let maxSkillNameLength = 30
    static let colorPaletteSize = 8
}

// MARK: - UI Text

struct UIText {
    // Placeholders
    static let skillNamePlaceholder = "Skill name..."
    static let defaultSkillName = "Untitled"

    // Labels
    static let todayLabel = "Today"
    static let addSkillLabel = "Add skill"

    // Error Messages
    static let errorEmptySkillName = "Skill name cannot be empty"
    static let errorDuplicateSkillName = "A skill with this name already exists"

    // Status Text
    static let noDataText = "No data"
    static let lessThanOneMinute = "<1m"
    static let noActivityText = "No activity"
    static let skillTrackedSingular = "skill tracked"
    static let skillTrackedPlural = "skills tracked"

    // Time Units
    static let hoursSuffix = "h"
    static let minutesSuffix = "m"
    static let hoursSeparator = "h "
    static let minutesSeparator = "m"
}

// MARK: - Format Strings

struct FormatStrings {
    static let timeWithHours = "%d:%02d:%02d"
    static let timeWithoutHours = "%d:%02d"
}

// MARK: - Additional Colors

extension Color {
    // Highlight Colors
    static let highlightYellow = Color(hex: "FFD60A")

    // Skill Color Palette - Pastel Dreams
    static let skillRed = Color(hex: "FFB3B0")        // Rose Petal
    static let skillOrange = Color(hex: "FFD4A3")     // Peach Sorbet
    static let skillYellow = Color(hex: "FFF4B3")     // Honey Glow
    static let skillGreen = Color(hex: "B3E6C5")      // Mint Meadow
    static let skillTeal = Color(hex: "A3E8E5")       // Ocean Mist
    static let skillPurple = Color(hex: "E0C3FF")     // Lavender Haze
    static let skillPink = Color(hex: "FFBDD1")       // Cherry Blossom
}

// MARK: - Animation Durations

struct AnimationDurations {
    static let flash: Double = 0.1
    static let updateHighlight: Double = 1.0
}

// MARK: - Calendar Constants

struct CalendarConstants {
    static let daysPerWeek = 7
    static let defaultWeeksBack = 4
    static let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]
}

// MARK: - Heatmap Thresholds (in minutes)

struct HeatmapThresholds {
    static let level1 = 15
    static let level2 = 30
    static let level3 = 60
    static let level4 = 120
    static let level5 = 180
}

// MARK: - Layout Constants

struct LayoutConstants {
    static let maxSkillListHeight: CGFloat = 200
    static let skillNameLineLimit = 1
    static let borderWidth: CGFloat = 1
}
