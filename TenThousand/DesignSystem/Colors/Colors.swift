//
//  Colors.swift
//  TenThousand
//
//  Color palette and semantic colors
//

import SwiftUI

// MARK: - Color Palette

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
    static let trackingBlue = Color(hex: "A8D5FF")

    // Adaptive Colors
    static let canvasBase = Color(nsColor: .windowBackgroundColor)
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary

    // Highlight Colors
    static let highlightYellow = Color(hex: "FFD60A")
}

// MARK: - Semantic Colors

extension Color {
    // State Colors
    static let stateError = Color.red
    static let stateSuccess = Color.green
    static let stateWarning = Color.orange

    // UI Colors
    static let buttonTextLight = Color.white
    static let overlayDark = Color.black
    static let fallbackColor = Color.gray
    static let transparent = Color.clear

    // Background Opacities (using primary)
    static func backgroundPrimary(_ opacity: BackgroundOpacity) -> Color {
        Color.primary.opacity(opacity.rawValue)
    }

    static func backgroundSecondary(_ opacity: BackgroundOpacity) -> Color {
        Color.secondary.opacity(opacity.rawValue)
    }
}

// MARK: - Background Opacity Levels

enum BackgroundOpacity: Double {
    case ultraLight = 0.02
    case subtle = 0.03
    case light = 0.04
    case medium = 0.05
    case regular = 0.06
    case strong = 0.08
    case intense = 0.10
    case heavy = 0.15
    case overlay = 0.20
    case overlayDark = 0.40
}

// MARK: - Hex Color Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 6:
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}
