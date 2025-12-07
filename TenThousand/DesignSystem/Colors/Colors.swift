//
//  Colors.swift
//  TenThousand
//
//  Created by Tim Isaev
//
//  Color Definitions
//
//  PHILOSOPHY:
//  Use system colors for all UI chrome (backgrounds, text, borders).
//  Only define custom colors for:
//  1. Brand accent (tracking indicator)
//  2. Skill identity colors (defined in ColorPalette.swift)
//
//  This ensures automatic dark mode support and native macOS feel.
//
//  USAGE:
//    DS.DS.Color.accent
//    DS.DS.Color.error
//    DS.Color.background(.subtle)
//

import SwiftUI

// MARK: - DS Color Extension

extension DS {
    enum Color {
        /// Primary accent for active tracking state
        static let accent = SwiftUI.Color(hex: "A8D5FF")

        /// Error states (destructive actions, validation errors)
        static let error = SwiftUI.Color.red

        /// Success states (confirmations, completions)
        static let success = SwiftUI.Color.green

        /// Warning states (cautions, pending actions)
        static let warning = SwiftUI.Color.orange

        /// Primary content background
        static var canvas: SwiftUI.Color {
            SwiftUI.Color(nsColor: .windowBackgroundColor)
        }

        /// Text on colored buttons
        static let onAccent = SwiftUI.Color.white

        /// Background with opacity
        static func background(_ level: BackgroundLevel) -> SwiftUI.Color {
            SwiftUI.Color.primary.opacity(level.opacity)
        }

        enum BackgroundLevel {
            case subtle      // 0.04
            case light       // 0.06
            case medium      // 0.10
            case strong      // 0.15

            var opacity: Double {
                switch self {
                case .subtle: return DS.Opacity.subtle
                case .light: return DS.Opacity.light
                case .medium: return DS.Opacity.medium
                case .strong: return DS.Opacity.strong
                }
            }
        }
    }
}

// MARK: - Hex Color Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let red, green, blue: UInt64
        switch hex.count {
        case 6:
            (red, green, blue) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (red, green, blue) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (red, green, blue) = (128, 128, 128)
        }
        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255
        )
    }
}
