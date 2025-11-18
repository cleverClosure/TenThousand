//
//  DesignSystem.swift
//  TenThousand
//
//  Complete design system following MVP specification
//

import SwiftUI

// MARK: - Colors

enum ColorConstants {
    // Private initializer to prevent instantiation
    private init() {}
}

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
    static let trackingBlue = Color(hex: "0071E3")

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
    static let colorDotSize: CGFloat = 8

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
}

// MARK: - Animations

extension Animation {
    static let microInteraction = Animation.timingCurve(0.4, 0, 0.2, 1, duration: 0.2)
    static let panelTransition = Animation.timingCurve(0.4, 0, 0.2, 1, duration: 0.3)
    static let countUp = Animation.timingCurve(0.4, 0, 0.2, 1, duration: 0.4)
    static let hoverState = Animation.timingCurve(0.4, 0, 0.2, 1, duration: 0.15)
}

// MARK: - Shadows

struct Shadows {
    static let floating: (radius: CGFloat, x: CGFloat, y: CGFloat, opacity: Double) = (
        radius: 24,
        x: 0,
        y: 8,
        opacity: 0.12
    )
}
