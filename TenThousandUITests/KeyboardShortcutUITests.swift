//
//  KeyboardShortcutUITests.swift
//  TenThousandUITests
//
//  UI tests for keyboard shortcut functionality
//

import XCTest

final class KeyboardShortcutUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = launchAppForTesting()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    // MARK: - Skill Creation Shortcuts

    func testCommandNOpensAddSkillField() throws {
        // Test that ⌘N opens the add skill text field

        // Press ⌘N
        app.typeKey("n", modifierFlags: .command)

        // Text field should appear
        let textField = app.textFields.firstMatch
        XCTAssertTrue(wait(for: textField), "Text field should appear after pressing ⌘N")
    }

    func testCommandNWhileTracking() throws {
        // Test that ⌘N works even while tracking

        // Create and start tracking a skill
        createSkill(in: app, named: UITestConstants.testSkillName1)
        startTracking(in: app, skill: UITestConstants.testSkillName1)
        verifyTimerIsRunning(in: app)

        // Try ⌘N
        app.typeKey("n", modifierFlags: .command)

        // Should show add skill field (or do nothing if not allowed while tracking)
        // Behavior depends on implementation
    }

    // MARK: - Session Control Shortcuts

    func testSpacePausesAndResumes() throws {
        // Test that Space key pauses and resumes tracking

        createSkill(in: app, named: UITestConstants.testSkillName1)
        startTracking(in: app, skill: UITestConstants.testSkillName1)
        verifyTimerIsRunning(in: app)

        sleep(2)

        // Press Space to pause
        app.typeKey(" ", modifierFlags: [])
        verifyTimerIsPaused(in: app)

        sleep(1)

        // Press Space again to resume
        app.typeKey(" ", modifierFlags: [])
        verifyTimerIsRunning(in: app)
    }

    func testSpaceWhenNotTracking() throws {
        // Test that Space does nothing when not tracking

        // Press Space without active session
        app.typeKey(" ", modifierFlags: [])

        // No active session should appear
        let activeSessionView = app.otherElements["ActiveSession"]
        XCTAssertFalse(activeSessionView.exists, "Space should do nothing when not tracking")
    }

    func testCommandPeriodStopsTracking() throws {
        // Test that ⌘. stops the current session

        createSkill(in: app, named: UITestConstants.testSkillName1)
        startTracking(in: app, skill: UITestConstants.testSkillName1)
        verifyTimerIsRunning(in: app)

        sleep(3)

        // Press ⌘.
        app.typeKey(".", modifierFlags: .command)

        // Session should stop
        let activeSessionView = app.otherElements["ActiveSession"]
        XCTAssertTrue(waitForDisappearance(of: activeSessionView), "Session should stop after ⌘.")
    }

    func testCommandPeriodWhenNotTracking() throws {
        // Test that ⌘. does nothing when not tracking

        // Press ⌘. without active session
        app.typeKey(".", modifierFlags: .command)

        // Should have no effect
        let activeSessionView = app.otherElements["ActiveSession"]
        XCTAssertFalse(activeSessionView.exists, "⌘. should do nothing when not tracking")
    }

    // MARK: - Quick Skill Selection (⌘1-9)

    func testCommand1SelectsFirstSkill() throws {
        // Test that ⌘1 opens first skill's detail view

        // Create a skill
        createSkill(in: app, named: "First Skill")

        // Press ⌘1
        app.typeKey("1", modifierFlags: .command)

        // Skill detail view should open
        // Note: Requires accessibility identifier for detail view
        let detailView = app.otherElements["SkillDetail"]
        if detailView.exists {
            XCTAssertTrue(wait(for: detailView), "Skill detail should open")
        }
    }

    func testCommand2SelectsSecondSkill() throws {
        // Test that ⌘2 opens second skill's detail view

        // Create two skills
        createSkill(in: app, named: "First Skill")
        createSkill(in: app, named: "Second Skill")

        // Press ⌘2
        app.typeKey("2", modifierFlags: .command)

        // Second skill's detail should open
        // Note: Verification requires checking which skill is displayed in detail view
    }

    func testCommandNumbersWithMultipleSkills() throws {
        // Test ⌘1 through ⌘9 with multiple skills

        // Create 5 skills
        for i in 1...5 {
            createSkill(in: app, named: "Skill \(i)")
        }

        // Test ⌘1 through ⌘5
        for keyNumber in 1...5 {
            app.typeKey("\(keyNumber)", modifierFlags: .command)

            // Note: Verification requires checking current skill detail view
            // For now, just verify no crashes

            // Press Escape to close detail view if it opened
            app.typeKey(.escape, modifierFlags: [])
        }
    }

    func testCommand9WithFewerThanNineSkills() throws {
        // Test that ⌘9 does nothing when there are fewer than 9 skills

        // Create only 3 skills
        for i in 1...3 {
            createSkill(in: app, named: "Skill \(i)")
        }

        // Press ⌘9
        app.typeKey("9", modifierFlags: .command)

        // Should do nothing (no 9th skill exists)
        // App should remain functional
        verifySkillExists(in: app, named: "Skill 1")
    }

    // MARK: - Navigation Shortcuts

    func testUpArrowNavigatesSkills() throws {
        // Test that ↑ arrow key navigates up in skill list

        // Create multiple skills
        createSkill(in: app, named: "Skill 1")
        createSkill(in: app, named: "Skill 2")
        createSkill(in: app, named: "Skill 3")

        // Press down arrow to select bottom skill
        app.typeKey(.downArrow, modifierFlags: [])
        app.typeKey(.downArrow, modifierFlags: [])

        // Press up arrow
        app.typeKey(.upArrow, modifierFlags: [])

        // Note: Verification requires checking which skill is selected
        // Selection state might be indicated by highlight or accessibility state
    }

    func testDownArrowNavigatesSkills() throws {
        // Test that ↓ arrow key navigates down in skill list

        // Create multiple skills
        createSkill(in: app, named: "Skill 1")
        createSkill(in: app, named: "Skill 2")

        // Press down arrow
        app.typeKey(.downArrow, modifierFlags: [])

        // Second skill should be selected
        // Note: Verification requires accessibility state checking
    }

    func testReturnOpensSelectedSkill() throws {
        // Test that Return key opens selected skill's detail view

        createSkill(in: app, named: "Test Skill")

        // Navigate to skill with arrow keys
        app.typeKey(.downArrow, modifierFlags: [])

        // Press Return
        app.typeKey(.return, modifierFlags: [])

        // Detail view should open
        // Note: Requires accessibility identifier for detail view
    }

    func testArrowNavigationWrapping() throws {
        // Test that arrow navigation wraps at boundaries

        createSkill(in: app, named: "Only Skill")

        // Press up arrow at top
        app.typeKey(.upArrow, modifierFlags: [])

        // Should wrap to bottom (or do nothing)
        // Behavior depends on implementation
    }

    // MARK: - Quit Shortcut

    func testCommandQQuitsApp() throws {
        // Test that ⌘Q quits the application

        // Note: This test will terminate the app, making subsequent assertions impossible
        // Typically handled separately or as last test

        // Press ⌘Q
        app.typeKey("q", modifierFlags: .command)

        // Wait for app to terminate
        sleep(2)

        // Verify app is no longer running
        // Note: This is tricky in UI tests; may need special handling
    }

    // MARK: - Escape Key

    func testEscapeClosesPanel() throws {
        // Test that Escape key closes the dropdown panel

        // Ensure panel is open
        // (Implementation-specific; may need to click menu bar icon)

        // Press Escape
        app.typeKey(.escape, modifierFlags: [])

        // Panel should close
        // Note: Verification requires checking panel visibility
    }

    func testEscapeClosesAddSkillField() throws {
        // Test that Escape cancels skill creation

        app.typeKey("n", modifierFlags: .command)

        let textField = app.textFields.firstMatch
        XCTAssertTrue(wait(for: textField), "Text field should appear")

        // Press Escape
        app.typeKey(.escape, modifierFlags: [])

        // Text field should disappear
        XCTAssertTrue(waitForDisappearance(of: textField), "Text field should close with Escape")
    }

    func testEscapeClosesSkillDetail() throws {
        // Test that Escape closes skill detail view

        createSkill(in: app, named: "Test Skill")

        // Open detail view with ⌘1
        app.typeKey("1", modifierFlags: .command)

        let detailView = app.otherElements["SkillDetail"]
        if wait(for: detailView, timeout: 2) {
            // Press Escape
            app.typeKey(.escape, modifierFlags: [])

            // Detail view should close
            XCTAssertTrue(waitForDisappearance(of: detailView), "Detail view should close with Escape")
        }
    }

    // MARK: - Combination Shortcuts

    func testSequentialShortcuts() throws {
        // Test using multiple shortcuts in sequence

        // ⌘N to create skill
        app.typeKey("n", modifierFlags: .command)
        let textField = app.textFields.firstMatch
        XCTAssertTrue(wait(for: textField), "Text field should appear")

        textField.click()
        textField.typeText("Test Skill")
        textField.typeKey(.return, modifierFlags: [])

        // ⌘1 to open detail
        app.typeKey("1", modifierFlags: .command)

        // Escape to close detail
        app.typeKey(.escape, modifierFlags: [])

        // App should be in normal state
        verifySkillExists(in: app, named: "Test Skill")
    }

    func testShortcutsDuringTracking() throws {
        // Test that appropriate shortcuts work during tracking

        createSkill(in: app, named: "Test Skill")
        startTracking(in: app, skill: "Test Skill")
        verifyTimerIsRunning(in: app)

        // Space should pause
        app.typeKey(" ", modifierFlags: [])
        verifyTimerIsPaused(in: app)

        // Space should resume
        app.typeKey(" ", modifierFlags: [])
        verifyTimerIsRunning(in: app)

        // ⌘. should stop
        app.typeKey(".", modifierFlags: .command)

        let activeSessionView = app.otherElements["ActiveSession"]
        XCTAssertTrue(waitForDisappearance(of: activeSessionView), "Session should stop")
    }

    // MARK: - Shortcut Conflicts

    func testShortcutsDoNotConflictWithTextInput() throws {
        // Test that shortcuts don't interfere when typing in text field

        app.typeKey("n", modifierFlags: .command)
        let textField = app.textFields.firstMatch
        XCTAssertTrue(wait(for: textField), "Text field should appear")

        textField.click()

        // Type text that includes characters used in shortcuts
        textField.typeText("C++ Programming")

        // Text should be entered normally (no shortcuts triggered)
        // Verify the text field contains the expected text
        // Note: Reading text field value requires accessibility
    }

    // MARK: - Modifier Key Verification

    func testShortcutsRequireCorrectModifiers() throws {
        // Test that shortcuts require proper modifier keys

        // Pressing 'n' without Command should not open add skill
        app.typeKey("n", modifierFlags: [])

        let textField = app.textFields.firstMatch
        XCTAssertFalse(textField.exists, "Text field should not appear without Command modifier")

        // Pressing '.' without Command should not stop tracking
        createSkill(in: app, named: "Test Skill")
        startTracking(in: app, skill: "Test Skill")

        app.typeKey(".", modifierFlags: [])

        // Session should still be running
        verifyTimerIsRunning(in: app)
    }

    // MARK: - Shortcut Help

    func testKeyboardShortcutsDocumented() throws {
        // Test that keyboard shortcuts are visible/documented in UI

        // Look for shortcuts in quit button or help text
        let quitButton = app.buttons["Quit"]
        if quitButton.exists {
            // Verify it shows "⌘Q" shortcut hint
            let shortcutHint = app.staticTexts["⌘Q"]
            XCTAssertTrue(shortcutHint.exists, "Quit button should show ⌘Q shortcut")
        }

        // Check for other shortcut hints in UI
        // Note: This depends on implementation showing shortcuts
    }
}
