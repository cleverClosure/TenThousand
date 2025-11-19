//
//  SkillCreationUITests.swift
//  TenThousandUITests
//
//  UI tests for skill creation workflows
//

import XCTest

final class SkillCreationUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = launchAppForTesting()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    // MARK: - Basic Skill Creation

    func testCreateSkillWithButton() throws {
        // Test creating a skill using the "Add skill" button

        // Find and click "Add skill" button
        let addSkillButton = app.buttons["Add skill"]
        XCTAssertTrue(wait(for: addSkillButton), "Add skill button should be visible")
        addSkillButton.click()

        // Text field should appear
        let textField = app.textFields.firstMatch
        XCTAssertTrue(wait(for: textField), "Text field should appear after clicking add skill")

        // Enter skill name
        let skillName = UITestConstants.testSkillName1
        textField.click()
        textField.typeText(skillName)

        // Submit by pressing Return
        textField.typeKey(.return, modifierFlags: [])

        // Verify skill appears in list
        wait(for: app.staticTexts[skillName], timeout: 3)
        verifySkillExists(in: app, named: skillName)

        // Text field should disappear
        XCTAssertTrue(waitForDisappearance(of: textField), "Text field should disappear after creating skill")
    }

    func testCreateSkillWithKeyboardShortcut() throws {
        // Test creating a skill using ⌘N keyboard shortcut

        // Press ⌘N
        app.typeKey("n", modifierFlags: .command)

        // Text field should appear
        let textField = app.textFields.firstMatch
        XCTAssertTrue(wait(for: textField), "Text field should appear after pressing ⌘N")

        // Enter and submit skill name
        let skillName = UITestConstants.testSkillName2
        textField.click()
        textField.typeText(skillName)
        textField.typeKey(.return, modifierFlags: [])

        // Verify skill appears
        verifySkillExists(in: app, named: skillName)
    }

    func testCreateMultipleSkills() throws {
        // Test creating several skills in sequence

        let skills = [
            UITestConstants.testSkillName1,
            UITestConstants.testSkillName2,
            UITestConstants.testSkillName3
        ]

        for skillName in skills {
            createSkill(in: app, named: skillName)
            verifySkillExists(in: app, named: skillName)
        }

        // All skills should be visible
        for skillName in skills {
            XCTAssertTrue(app.staticTexts[skillName].exists, "Skill '\(skillName)' should exist")
        }
    }

    // MARK: - Validation Tests

    func testCreateSkillWithEmptyName() throws {
        // Test that empty skill names are rejected

        let addSkillButton = app.buttons["Add skill"]
        addSkillButton.click()

        let textField = app.textFields.firstMatch
        XCTAssertTrue(wait(for: textField), "Text field should appear")

        // Try to submit without entering text
        textField.click()
        textField.typeKey(.return, modifierFlags: [])

        // Text field should still be visible (submission rejected)
        XCTAssertTrue(textField.exists, "Text field should remain visible when empty")

        // No skill should have been created
        // Note: This assumes we can check skill count or that no blank skill appears
    }

    func testCreateSkillWithWhitespaceOnly() throws {
        // Test that whitespace-only names are rejected

        app.typeKey("n", modifierFlags: .command)

        let textField = app.textFields.firstMatch
        XCTAssertTrue(wait(for: textField), "Text field should appear")

        // Enter only spaces
        textField.click()
        textField.typeText("   ")
        textField.typeKey(.return, modifierFlags: [])

        // Text field should still be visible (submission rejected)
        XCTAssertTrue(textField.exists, "Text field should remain when only whitespace entered")
    }

    func testCreateSkillWithMaxLength() throws {
        // Test creating a skill with exactly 30 characters (maximum length)

        let maxLengthName = String(repeating: "A", count: UITestConstants.maxSkillNameLength)

        createSkill(in: app, named: maxLengthName)

        // Skill should be created successfully
        verifySkillExists(in: app, named: maxLengthName)
    }

    func testCreateSkillExceedingMaxLength() throws {
        // Test that skill names longer than 30 characters are rejected

        app.typeKey("n", modifierFlags: .command)

        let textField = app.textFields.firstMatch
        XCTAssertTrue(wait(for: textField), "Text field should appear")

        // Try to enter 31 characters
        let tooLongName = String(repeating: "A", count: UITestConstants.maxSkillNameLength + 1)
        textField.click()
        textField.typeText(tooLongName)
        textField.typeKey(.return, modifierFlags: [])

        // Either the text field limits input to 30 chars, or submission is rejected
        // Verify no skill with 31 characters was created
        let skillText = app.staticTexts[tooLongName]
        XCTAssertFalse(skillText.exists, "Skill with >30 character name should not be created")
    }

    func testCreateDuplicateSkill() throws {
        // Test that duplicate skill names are rejected

        let skillName = "Duplicate Test"

        // Create first skill
        createSkill(in: app, named: skillName)
        verifySkillExists(in: app, named: skillName)

        // Try to create duplicate
        app.typeKey("n", modifierFlags: .command)
        let textField = app.textFields.firstMatch
        XCTAssertTrue(wait(for: textField), "Text field should appear")

        textField.click()
        textField.typeText(skillName)
        textField.typeKey(.return, modifierFlags: [])

        // Text field should remain (duplicate rejected)
        // Note: Implementation may show error message
        XCTAssertTrue(textField.exists, "Text field should remain when duplicate name entered")

        // Should still only have one instance of the skill
        // Note: May need to verify skill count remains the same
    }

    func testCreateDuplicateSkillWithDifferentWhitespace() throws {
        // Test that duplicates with different whitespace are rejected

        let skillName = "Whitespace Test"

        // Create first skill
        createSkill(in: app, named: skillName)
        verifySkillExists(in: app, named: skillName)

        // Try to create with extra whitespace
        app.typeKey("n", modifierFlags: .command)
        let textField = app.textFields.firstMatch
        XCTAssertTrue(wait(for: textField), "Text field should appear")

        textField.click()
        textField.typeText("  \(skillName)  ")  // Same name with whitespace
        textField.typeKey(.return, modifierFlags: [])

        // Should be rejected as duplicate
        XCTAssertTrue(textField.exists, "Duplicate with whitespace should be rejected")
    }

    // MARK: - UI State Tests

    func testCancelSkillCreation() throws {
        // Test canceling skill creation by pressing Escape

        app.typeKey("n", modifierFlags: .command)

        let textField = app.textFields.firstMatch
        XCTAssertTrue(wait(for: textField), "Text field should appear")

        // Press Escape to cancel
        textField.typeKey(.escape, modifierFlags: [])

        // Text field should disappear
        XCTAssertTrue(waitForDisappearance(of: textField), "Text field should disappear after pressing Escape")
    }

    func testSkillCreationResetsAddingFlag() throws {
        // Test that creating a skill resets the isAddingSkill flag

        // Create a skill
        createSkill(in: app, named: "Test Skill")

        // Add skill button should be visible again
        let addSkillButton = app.buttons["Add skill"]
        XCTAssertTrue(wait(for: addSkillButton), "Add skill button should be visible again after creating skill")

        // Text field should not be visible
        let textField = app.textFields.firstMatch
        XCTAssertFalse(textField.exists, "Text field should not be visible after creating skill")
    }

    // MARK: - Color Assignment

    func testSkillsAssignedDifferentColors() throws {
        // Test that multiple skills get different color indices

        // Create 3 skills
        createSkill(in: app, named: "Skill 1")
        createSkill(in: app, named: "Skill 2")
        createSkill(in: app, named: "Skill 3")

        // Note: Color verification in UI tests is challenging
        // This test verifies the skills are created; actual color testing
        // should be done in unit tests (which we already have)

        verifySkillExists(in: app, named: "Skill 1")
        verifySkillExists(in: app, named: "Skill 2")
        verifySkillExists(in: app, named: "Skill 3")
    }

    // MARK: - Special Characters

    func testCreateSkillWithSpecialCharacters() throws {
        // Test creating skills with various special characters

        let specialNames = [
            "C++",
            "Swift 5.9",
            "UI/UX Design",
            "Node.js"
        ]

        for skillName in specialNames {
            createSkill(in: app, named: skillName)
            verifySkillExists(in: app, named: skillName)
        }
    }

    func testCreateSkillWithUnicodeCharacters() throws {
        // Test creating skills with Unicode/emoji characters

        let unicodeNames = [
            "日本語",
            "Español",
            "Русский"
        ]

        for skillName in unicodeNames {
            createSkill(in: app, named: skillName)
            verifySkillExists(in: app, named: skillName)
        }
    }
}
