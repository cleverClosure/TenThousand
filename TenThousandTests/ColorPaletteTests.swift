//
//  ColorPaletteTests.swift
//  TenThousandTests
//
//  Unit tests for ColorPalette and ColorPaletteManager
//

import Testing
import Foundation
@testable import TenThousand

@Suite("ColorPalette Behaviors", .serialized)
struct ColorPaletteTests {

    // MARK: - Palette Definition Tests

    @Test("Summer Ocean Breeze palette has 5 colors")
    func testSummerOceanBreezePaletteCount() {
        #expect(ColorPalette.summerOceanBreeze.colorCount == 5)
    }

    @Test("Ocean Sunset palette has 5 colors")
    func testOceanSunsetPaletteCount() {
        #expect(ColorPalette.oceanSunset.colorCount == 5)
    }

    @Test("Earthy Tones palette has 5 colors")
    func testEarthyTonesPaletteCount() {
        #expect(ColorPalette.earthyTones.colorCount == 5)
    }

    @Test("All palettes are available")
    func testAllPalettesAvailable() {
        #expect(ColorPalette.all.count == 3)
    }

    @Test("Total color count is 15")
    func testTotalColorCount() {
        #expect(ColorPalette.totalColorCount == 15)
    }

    @Test("Each color in palette has a name")
    func testColorsHaveNames() {
        for palette in ColorPalette.all {
            for color in palette.colors {
                #expect(!color.name.isEmpty)
            }
        }
    }

    @Test("Each color in palette has a hex value")
    func testColorsHaveHexValues() {
        for palette in ColorPalette.all {
            for color in palette.colors {
                #expect(color.hex.count == 6)
            }
        }
    }

    @Test("Palette lookup by ID works")
    func testPaletteLookupById() {
        let palette = ColorPalette.palette(withId: "summer_ocean_breeze")
        #expect(palette != nil)
        #expect(palette?.name == "Summer Ocean Breeze")
    }

    @Test("Palette lookup with invalid ID returns nil")
    func testPaletteLookupInvalidId() {
        let palette = ColorPalette.palette(withId: "nonexistent")
        #expect(palette == nil)
    }
}

@Suite("ColorPaletteManager Behaviors", .serialized)
struct ColorPaletteManagerTests {

    // MARK: - Test Helpers

    func makeManager() -> ColorPaletteManager {
        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        return ColorPaletteManager(defaults: defaults)
    }

    // MARK: - Initial State Tests

    @Test("Fresh manager has no current palette")
    func testFreshManagerNoPalette() {
        let manager = makeManager()
        #expect(manager.currentPaletteId == nil)
    }

    @Test("Fresh manager has no exhausted palettes")
    func testFreshManagerNoExhausted() {
        let manager = makeManager()
        #expect(manager.exhaustedPaletteIds.isEmpty)
    }

    // MARK: - Color Assignment Tests

    @Test("First color assignment selects a palette")
    func testFirstColorAssignmentSelectsPalette() {
        let manager = makeManager()

        let color = manager.nextColor(usedColors: [])

        #expect(color != nil)
        #expect(manager.currentPaletteId != nil)
    }

    @Test("First color is always index 0")
    func testFirstColorIsIndexZero() {
        let manager = makeManager()

        let color = manager.nextColor(usedColors: [])

        #expect(color?.colorIndex == 0)
    }

    @Test("Sequential colors are assigned in order")
    func testSequentialColorsInOrder() {
        let manager = makeManager()

        let color1 = manager.nextColor(usedColors: [])!
        let color2 = manager.nextColor(usedColors: [color1])!
        let color3 = manager.nextColor(usedColors: [color1, color2])!

        #expect(color1.colorIndex == 0)
        #expect(color2.colorIndex == 1)
        #expect(color3.colorIndex == 2)
    }

    @Test("All colors in a palette use the same palette ID")
    func testColorsUseSamePalette() {
        let manager = makeManager()

        let color1 = manager.nextColor(usedColors: [])!
        let color2 = manager.nextColor(usedColors: [color1])!
        let color3 = manager.nextColor(usedColors: [color1, color2])!

        #expect(color1.paletteId == color2.paletteId)
        #expect(color2.paletteId == color3.paletteId)
    }

    @Test("Exhausting a palette switches to a new one")
    func testExhaustingPaletteSwitches() {
        let manager = makeManager()
        var usedColors: [ColorAssignment] = []

        // Use all 5 colors from first palette
        for _ in 0..<5 {
            if let color = manager.nextColor(usedColors: usedColors) {
                usedColors.append(color)
            }
        }

        let firstPaletteId = usedColors[0].paletteId

        // Get 6th color - should be from a different palette
        let color6 = manager.nextColor(usedColors: usedColors)

        #expect(color6 != nil)
        #expect(color6?.paletteId != firstPaletteId)
        #expect(color6?.colorIndex == 0) // First color of new palette
    }

    @Test("Exhausted palette is tracked")
    func testExhaustedPaletteTracked() {
        let manager = makeManager()
        var usedColors: [ColorAssignment] = []

        // Use all 5 colors from first palette
        for _ in 0..<5 {
            if let color = manager.nextColor(usedColors: usedColors) {
                usedColors.append(color)
            }
        }

        let firstPaletteId = usedColors[0].paletteId

        // Request 6th color to trigger exhaustion
        _ = manager.nextColor(usedColors: usedColors)

        #expect(manager.exhaustedPaletteIds.contains(firstPaletteId))
    }

    @Test("Can assign up to 12 colors (skill limit)")
    func testCanAssignMaxSkillColors() {
        let manager = makeManager()
        var usedColors: [ColorAssignment] = []

        for i in 0..<12 {
            let color = manager.nextColor(usedColors: usedColors)
            #expect(color != nil, "Should be able to assign color \(i + 1)")
            if let color = color {
                usedColors.append(color)
            }
        }

        #expect(usedColors.count == 12)
    }

    @Test("Deleted color becomes available again")
    func testDeletedColorBecomesAvailable() {
        let manager = makeManager()

        // Create 3 skills
        let color1 = manager.nextColor(usedColors: [])!
        let color2 = manager.nextColor(usedColors: [color1])!
        let color3 = manager.nextColor(usedColors: [color1, color2])!

        // "Delete" color2 by not including it in used colors
        let color4 = manager.nextColor(usedColors: [color1, color3])!

        // color4 should be color2's slot (index 1)
        #expect(color4.colorIndex == 1)
        #expect(color4.paletteId == color1.paletteId)
    }

    @Test("Stay on current palette after deletion")
    func testStayOnCurrentPaletteAfterDeletion() {
        let manager = makeManager()
        var usedColors: [ColorAssignment] = []

        // Use 4 colors
        for _ in 0..<4 {
            if let color = manager.nextColor(usedColors: usedColors) {
                usedColors.append(color)
            }
        }

        let currentPalette = manager.currentPaletteId

        // "Delete" one color
        usedColors.remove(at: 1)

        // Recalculate state
        manager.recalculateState(usedColors: usedColors)

        // Should stay on current palette
        #expect(manager.currentPaletteId == currentPalette)
    }

    // MARK: - Color Resolution Tests

    @Test("Color resolution returns correct color")
    func testColorResolution() {
        let manager = makeManager()

        let color = manager.color(forPaletteId: ColorPalette.summerOceanBreeze.id, colorIndex: 0)

        // Should not be gray (the fallback)
        #expect(color != .gray)
    }

    @Test("SkillColor resolution returns correct data")
    func testSkillColorResolution() {
        let manager = makeManager()

        let skillColor = manager.skillColor(forPaletteId: ColorPalette.summerOceanBreeze.id, colorIndex: 0)

        #expect(skillColor != nil)
        #expect(skillColor?.name == "Coral Red")
        #expect(skillColor?.hex == "E63946")
    }

    @Test("Invalid palette ID returns gray color")
    func testInvalidPaletteReturnsGray() {
        let manager = makeManager()

        let color = manager.color(forPaletteId: "invalid", colorIndex: 0)

        #expect(color == .gray)
    }

    // MARK: - State Management Tests

    @Test("Reset clears all state")
    func testResetClearsState() {
        let manager = makeManager()

        // Set some state
        _ = manager.nextColor(usedColors: [])

        manager.reset()

        #expect(manager.currentPaletteId == nil)
        #expect(manager.exhaustedPaletteIds.isEmpty)
    }

    @Test("Recalculate state updates exhausted palettes correctly")
    func testRecalculateStateUpdatesExhausted() {
        let manager = makeManager()
        let paletteId = ColorPalette.summerOceanBreeze.id

        // Simulate all colors used from one palette
        let usedColors = (0..<5).map { ColorAssignment(paletteId: paletteId, colorIndex: $0) }

        manager.recalculateState(usedColors: usedColors)

        #expect(manager.exhaustedPaletteIds.contains(paletteId))
    }
}

@Suite("ColorAssignment Behaviors", .serialized)
struct ColorAssignmentTests {

    @Test("ColorAssignment resolves to SkillColor")
    func testColorAssignmentResolvesToSkillColor() {
        let assignment = ColorAssignment(paletteId: ColorPalette.summerOceanBreeze.id, colorIndex: 0)

        let skillColor = assignment.skillColor

        #expect(skillColor != nil)
        #expect(skillColor?.name == "Coral Red")
    }

    @Test("ColorAssignment resolves to SwiftUI Color")
    func testColorAssignmentResolvesToColor() {
        let assignment = ColorAssignment(paletteId: ColorPalette.summerOceanBreeze.id, colorIndex: 0)

        let color = assignment.color

        #expect(color != .gray)
    }

    @Test("Invalid ColorAssignment returns gray")
    func testInvalidColorAssignmentReturnsGray() {
        let assignment = ColorAssignment(paletteId: "invalid", colorIndex: 0)

        let color = assignment.color

        #expect(color == .gray)
    }
}
