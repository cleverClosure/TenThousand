//
//  Typography.swift
//  TenThousand
//
//  Created by Tim Isaev
//
//  Typography System
//
//  PHILOSOPHY:
//  Minimal type scale with clear hierarchy:
//  - Hero: Large display numbers (hours, main timer)
//  - Title: Skill names, section headers
//  - Body: Buttons, descriptions, primary content
//  - Caption: Secondary information, metadata
//  - Label: Small uppercase labels
//  - Timer: Monospaced for time displays
//
//  USAGE:
//    DS.Font.title
//    DS.Font.body
//    .font(DS.Font.caption)
//

import SwiftUI

// MARK: - DS Font Extension

extension DS {
    enum Font {
        // Display - Large numbers and timers
        static let hero = SwiftUI.Font.system(size: 56, weight: .medium, design: .rounded)

        // Title - Skill names, headers
        static let title = SwiftUI.Font.system(size: 17, weight: .semibold)

        // Body - Primary content
        static let body = SwiftUI.Font.system(size: 14, weight: .regular)

        // Caption - Secondary content
        static let caption = SwiftUI.Font.system(size: 12, weight: .regular)

        // Label - Small uppercase labels
        static let label = SwiftUI.Font.system(size: 11, weight: .medium)

        // Timer - Monospaced for time displays
        static var timer: SwiftUI.Font {
            SwiftUI.Font.system(size: 14, weight: .medium, design: .monospaced)
                .monospacedDigit()
        }

        // Large timer - Active tracking display
        static var timerLarge: SwiftUI.Font {
            SwiftUI.Font.system(size: 22, weight: .medium, design: .monospaced)
                .monospacedDigit()
        }

        // Hero timer - Full screen timer
        static var timerHero: SwiftUI.Font {
            SwiftUI.Font.system(size: DS.Size.heroTimer, weight: .medium, design: .monospaced)
                .monospacedDigit()
        }

        // Menubar timer
        static var timerMenubar: SwiftUI.Font {
            SwiftUI.Font.system(size: 13, weight: .semibold, design: .monospaced)
                .monospacedDigit()
        }

        // Icon font generator
        static func icon(_ size: IconSize, weight: SwiftUI.Font.Weight = .medium) -> SwiftUI.Font {
            .system(size: size.rawValue, weight: weight)
        }
    }

    // MARK: - Icon Sizes

    enum IconSize: CGFloat {
        case small = 10
        case body = 12
        case medium = 14
        case large = 16
        case xl = 20
    }
}

// MARK: - View Modifiers (for convenience)

extension View {
    func dsFont(_ font: SwiftUI.Font) -> some View {
        self.font(font)
    }

    func heroFont() -> some View {
        self.font(DS.Font.hero)
            .kerning(-1.5)
    }

    func titleFont() -> some View {
        self.font(DS.Font.title)
            .kerning(-0.3)
    }

    func bodyFont() -> some View {
        self.font(DS.Font.body)
    }

    func captionFont() -> some View {
        self.font(DS.Font.caption)
    }

    func labelFont() -> some View {
        self.font(DS.Font.label)
            .kerning(1.2)
            .textCase(.uppercase)
    }

    func timerFont() -> some View {
        self.font(DS.Font.timer)
            .monospacedDigit()
    }

    func timerLargeFont() -> some View {
        self.font(DS.Font.timerLarge)
            .monospacedDigit()
    }

    func timerHeroFont() -> some View {
        self.font(DS.Font.timerHero)
            .monospacedDigit()
    }

    func menubarTimerFont() -> some View {
        self.font(DS.Font.timerMenubar)
            .monospacedDigit()
    }

    func iconFont(_ size: DS.IconSize, weight: Font.Weight = .medium) -> some View {
        self.font(DS.Font.icon(size, weight: weight))
    }
}
