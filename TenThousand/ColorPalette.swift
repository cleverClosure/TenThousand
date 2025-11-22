//
//  ColorPalette.swift
//  TenThousand
//
//  Color palette system for skill colors
//

import SwiftUI

// MARK: - Skill Color

/// Represents an individual color within a palette.
struct SkillColor: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let hex: String

    var color: Color {
        Color(skillHex: hex)
    }
}

// MARK: - Color Palette

/// Represents a collection of themed colors for skills.
struct ColorPalette: Identifiable, Equatable {
    let id: String
    let name: String
    let colors: [SkillColor]

    var colorCount: Int { colors.count }
}

// MARK: - Predefined Palettes

extension ColorPalette {

    /// Summer Ocean Breeze palette - warm and cool coastal tones
    static let summerOceanBreeze = ColorPalette(
        id: "summer_ocean_breeze",
        name: "Summer Ocean Breeze",
        colors: [
            SkillColor(id: "summer_ocean_breeze_0", name: "Coral Red", hex: "E63946"),
            SkillColor(id: "summer_ocean_breeze_1", name: "Honeydew", hex: "F1FAEE"),
            SkillColor(id: "summer_ocean_breeze_2", name: "Powder Blue", hex: "A8DADC"),
            SkillColor(id: "summer_ocean_breeze_3", name: "Steel Blue", hex: "457B9D"),
            SkillColor(id: "summer_ocean_breeze_4", name: "Prussian Blue", hex: "1D3557")
        ]
    )

    /// Ocean Sunset palette - warm sunset gradients
    static let oceanSunset = ColorPalette(
        id: "ocean_sunset",
        name: "Ocean Sunset",
        colors: [
            SkillColor(id: "ocean_sunset_0", name: "Dark Slate Blue", hex: "355070"),
            SkillColor(id: "ocean_sunset_1", name: "Old Lavender", hex: "6D597A"),
            SkillColor(id: "ocean_sunset_2", name: "Turkish Rose", hex: "B56576"),
            SkillColor(id: "ocean_sunset_3", name: "Light Coral", hex: "E56B6F"),
            SkillColor(id: "ocean_sunset_4", name: "Peach", hex: "EAAC8B")
        ]
    )

    /// Earthy Tones palette - natural, muted earth tones
    static let earthyTones = ColorPalette(
        id: "earthy_tones",
        name: "Earthy Tones",
        colors: [
            SkillColor(id: "earthy_tones_0", name: "Orchid Pink", hex: "EDAFB8"),
            SkillColor(id: "earthy_tones_1", name: "Champagne", hex: "F7E1D7"),
            SkillColor(id: "earthy_tones_2", name: "Timberwolf", hex: "DEDBD2"),
            SkillColor(id: "earthy_tones_3", name: "Laurel Green", hex: "B0C4B1"),
            SkillColor(id: "earthy_tones_4", name: "Davys Grey", hex: "4A5759")
        ]
    )

    /// All available palettes
    static let all: [ColorPalette] = [
        .summerOceanBreeze,
        .oceanSunset,
        .earthyTones
    ]

    /// Total number of colors across all palettes
    static var totalColorCount: Int {
        all.reduce(0) { $0 + $1.colorCount }
    }

    /// Find a palette by ID
    static func palette(withId id: String) -> ColorPalette? {
        all.first { $0.id == id }
    }
}

// MARK: - Color Extension for Skill Hex

extension Color {
    /// Creates a Color from a hex string for skill colors.
    /// This is internal to the palette system.
    init(skillHex hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
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
