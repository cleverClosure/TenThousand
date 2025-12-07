//
//  ColorPaletteManager.swift
//  TenThousand
//
//  Manages color palette state and color assignment for skills
//

import Foundation
import SwiftUI

// MARK: - Color Assignment Result

/// Represents a color assignment for a new skill.
struct ColorAssignment: Equatable, Hashable {
    let paletteId: String
    let colorIndex: Int

    /// Resolves to the actual SkillColor
    var skillColor: SkillColor? {
        guard let palette = ColorPalette.palette(withId: paletteId),
              colorIndex >= 0,
              colorIndex < palette.colors.count else { return nil }
        return palette.colors[colorIndex]
    }

    /// Resolves to the SwiftUI Color
    var color: Color {
        skillColor?.color ?? Color.gray
    }
}

// MARK: - Color Palette Manager

/// Manages palette selection and color assignment for skills.
///
/// Color assignment rules:
/// 1. When creating the first skill, randomly choose a palette and use its first color
/// 2. Subsequent skills use the next color in order from the current palette
/// 3. When a palette is exhausted, randomly choose a different palette (not yet exhausted)
/// 4. No two skills can have the same color
/// 5. Maximum 12 skills (with 3 palettes × 5 colors = 15 total colors)
/// 6. When a skill is deleted, its color becomes available but we stay on the current palette
final class ColorPaletteManager {
    // MARK: - Singleton

    static let shared = ColorPaletteManager()

    // MARK: - Constants

    private enum Keys {
        static let currentPaletteId = "ColorPaletteManager.currentPaletteId"
        static let exhaustedPaletteIds = "ColorPaletteManager.exhaustedPaletteIds"
    }

    // MARK: - Properties

    private let defaults: UserDefaults

    // MARK: - Initialization

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - State Access

    /// The currently active palette ID, if any.
    var currentPaletteId: String? {
        get { defaults.string(forKey: Keys.currentPaletteId) }
        set { defaults.set(newValue, forKey: Keys.currentPaletteId) }
    }

    /// Set of palette IDs that have been fully exhausted.
    var exhaustedPaletteIds: Set<String> {
        get {
            let array = defaults.stringArray(forKey: Keys.exhaustedPaletteIds) ?? []
            return Set(array)
        }
        set {
            defaults.set(Array(newValue), forKey: Keys.exhaustedPaletteIds)
        }
    }

    // MARK: - Color Assignment

    /// Gets the next available color for a new skill.
    ///
    /// - Parameter usedColors: Set of color assignments currently in use by existing skills.
    /// - Returns: A ColorAssignment for the new skill, or nil if no colors are available.
    func nextColor(usedColors: [ColorAssignment]) -> ColorAssignment? {
        let usedSet = Set(usedColors)

        // If no current palette, select one randomly
        if currentPaletteId == nil {
            selectRandomPalette(excluding: exhaustedPaletteIds)
        }

        guard let paletteId = currentPaletteId,
              let palette = ColorPalette.palette(withId: paletteId) else {
            return nil
        }

        // Find the next available color in the current palette (in order)
        for index in 0..<palette.colorCount {
            let assignment = ColorAssignment(paletteId: paletteId, colorIndex: index)
            if !usedSet.contains(assignment) {
                return assignment
            }
        }

        // Current palette is exhausted - mark it and try another
        var exhausted = exhaustedPaletteIds
        exhausted.insert(paletteId)
        exhaustedPaletteIds = exhausted

        // Try to select a new palette
        if selectRandomPalette(excluding: exhausted) {
            // Recursively get color from new palette
            return nextColor(usedColors: usedColors)
        }

        // No palettes available
        return nil
    }

    /// Resolves a color assignment to a SwiftUI Color.
    ///
    /// - Parameters:
    ///   - paletteId: The palette identifier.
    ///   - colorIndex: The color index within the palette.
    /// - Returns: The resolved Color, or gray if not found.
    func color(forPaletteId paletteId: String, colorIndex: Int) -> Color {
        guard let palette = ColorPalette.palette(withId: paletteId),
              colorIndex >= 0,
              colorIndex < palette.colors.count else {
            return Color.gray
        }
        return palette.colors[colorIndex].color
    }

    /// Gets the SkillColor for a given assignment.
    ///
    /// - Parameters:
    ///   - paletteId: The palette identifier.
    ///   - colorIndex: The color index within the palette.
    /// - Returns: The SkillColor, or nil if not found.
    func skillColor(forPaletteId paletteId: String, colorIndex: Int) -> SkillColor? {
        guard let palette = ColorPalette.palette(withId: paletteId),
              colorIndex >= 0,
              colorIndex < palette.colors.count else {
            return nil
        }
        return palette.colors[colorIndex]
    }

    /// Recalculates palette state based on current skill colors.
    /// Call this after deleting skills or loading from persistence.
    ///
    /// - Parameter usedColors: Currently used color assignments.
    func recalculateState(usedColors: [ColorAssignment]) {
        let usedSet = Set(usedColors)

        // If there's no current palette but there are used colors,
        // set current palette to the palette of the most recent skill
        if currentPaletteId == nil && !usedColors.isEmpty {
            currentPaletteId = usedColors.last?.paletteId
        }

        // Recalculate which palettes are actually exhausted
        var newExhausted = Set<String>()
        for palette in ColorPalette.all {
            let allUsed = (0..<palette.colorCount).allSatisfy { index in
                usedSet.contains(ColorAssignment(paletteId: palette.id, colorIndex: index))
            }
            if allUsed {
                newExhausted.insert(palette.id)
            }
        }
        exhaustedPaletteIds = newExhausted

        // If current palette is exhausted, select a new one
        if let current = currentPaletteId, newExhausted.contains(current) {
            _ = selectRandomPalette(excluding: newExhausted)
        }
    }

    /// Resets all palette state. Useful for testing.
    func reset() {
        currentPaletteId = nil
        exhaustedPaletteIds = []
    }

    // MARK: - Private Methods

    /// Selects a random palette, excluding specified ones.
    @discardableResult
    private func selectRandomPalette(excluding excludedIds: Set<String>) -> Bool {
        let availablePalettes = ColorPalette.all.filter { !excludedIds.contains($0.id) }
        guard let selected = availablePalettes.randomElement() else {
            currentPaletteId = nil
            return false
        }
        currentPaletteId = selected.id
        return true
    }
}

// MARK: - Skill Extension for Color Assignment

extension Skill {
    /// Creates a ColorAssignment from this skill's stored palette and color data.
    var colorAssignment: ColorAssignment {
        ColorAssignment(paletteId: paletteId, colorIndex: Int(colorIndex))
    }
}
