//
//  Typography.swift
//  TenThousand
//
//  Font styles and text modifiers
//

import SwiftUI

// MARK: - Typography Definitions

struct Typography {
    // Hero - for main numbers and timers
    static let hero = Font.system(size: 56, weight: .medium, design: .rounded)
    static let heroKerning: CGFloat = -1.5
    static let heroLineHeight: CGFloat = 64

    // Title - skill names in detail/tracking views
    static let title = Font.system(size: 20, weight: .semibold, design: .default)
    static let titleKerning: CGFloat = -0.4
    static let titleLineHeight: CGFloat = 26

    // Display - skill names in rows
    static let display = Font.system(size: 17, weight: .semibold, design: .default)
    static let displayKerning: CGFloat = -0.3
    static let displayLineHeight: CGFloat = 22

    // Body - buttons, labels
    static let body = Font.system(size: 14, weight: .regular, design: .default)
    static let bodyKerning: CGFloat = -0.08
    static let bodyLineHeight: CGFloat = 18

    // Caption - secondary text
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    static let captionKerning: CGFloat = 0
    static let captionLineHeight: CGFloat = 16

    // Label - small uppercase labels
    static let label = Font.system(size: 11, weight: .medium, design: .default)
    static let labelKerning: CGFloat = 1.5
    static let labelLineHeight: CGFloat = 14

    // Time Display - inline times
    static let timeDisplay = Font.system(size: 14, weight: .medium, design: .monospaced)
        .monospacedDigit()
    static let timeDisplayKerning: CGFloat = 0.5
    static let timeDisplayLineHeight: CGFloat = 18

    // Large Time Display - timer in menu bar
    static let largeTimeDisplay = Font.system(size: 22, weight: .medium, design: .monospaced)
        .monospacedDigit()
    static let largeTimeDisplayKerning: CGFloat = 0.5
    static let largeTimeDisplayLineHeight: CGFloat = 28

    // Hero Timer - large timer display in active tracking
    static let heroTimer = Font.system(size: Dimensions.heroTimerSize, weight: .medium, design: .monospaced)
        .monospacedDigit()

    // Menubar Timer - timer in menu bar
    static let menubarTimer = Font.system(size: IconFontSize.menubarTimer, weight: .semibold, design: .monospaced)
        .monospacedDigit()
}

// MARK: - Icon Font Definitions

extension Typography {
    // Icon fonts with various weights
    static func icon(_ size: IconSize, weight: Font.Weight = .medium) -> Font {
        .system(size: size.rawValue, weight: weight)
    }
}

// MARK: - Icon Sizes

enum IconSize: CGFloat {
    case tiny = 9
    case small = 10
    case caption = 11
    case body = 12
    case menubar = 13
    case medium = 14
    case large = 16
    case xl = 20
}

// MARK: - Typography View Modifiers

extension View {
    func heroFont() -> some View {
        self
            .font(Typography.hero)
            .kerning(Typography.heroKerning)
    }

    func titleFont() -> some View {
        self
            .font(Typography.title)
            .kerning(Typography.titleKerning)
    }

    func displayFont() -> some View {
        self
            .font(Typography.display)
            .kerning(Typography.displayKerning)
    }

    func bodyFont() -> some View {
        self
            .font(Typography.body)
            .kerning(Typography.bodyKerning)
    }

    func captionFont() -> some View {
        self
            .font(Typography.caption)
            .kerning(Typography.captionKerning)
    }

    func labelFont() -> some View {
        self
            .font(Typography.label)
            .kerning(Typography.labelKerning)
            .textCase(.uppercase)
    }

    func timeDisplayFont() -> some View {
        self
            .font(Typography.timeDisplay)
            .kerning(Typography.timeDisplayKerning)
            .monospacedDigit()
    }

    func largeTimeDisplayFont() -> some View {
        self
            .font(Typography.largeTimeDisplay)
            .kerning(Typography.largeTimeDisplayKerning)
            .monospacedDigit()
    }

    func heroTimerFont() -> some View {
        self
            .font(Typography.heroTimer)
            .monospacedDigit()
    }

    func menubarTimerFont() -> some View {
        self
            .font(Typography.menubarTimer)
            .monospacedDigit()
    }

    func iconFont(_ size: IconSize, weight: Font.Weight = .medium) -> some View {
        self.font(Typography.icon(size, weight: weight))
    }
}
