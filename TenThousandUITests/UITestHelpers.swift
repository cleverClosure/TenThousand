//
//  UITestHelpers.swift
//  TenThousandUITests
//
//  UI test helpers and utilities
//

import XCTest

/// Helper extensions and utilities for UI testing
extension XCTestCase {

    // MARK: - App Launch

    /// Launches the app with a clean state for testing.
    ///
    /// - Parameter launchArguments: Additional launch arguments to pass
    /// - Returns: The launched XCUIApplication instance
    func launchAppForTesting(launchArguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()

        // Use in-memory persistence for tests
        app.launchArguments = ["--uitesting"] + launchArguments

        app.launch()
        return app
    }

    // MARK: - Wait Helpers

    /// Waits for an element to exist with a timeout.
    ///
    /// - Parameters:
    ///   - element: The element to wait for
    ///   - timeout: Maximum time to wait (default: 5 seconds)
    /// - Returns: True if element exists within timeout, false otherwise
    @discardableResult
    func wait(for element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        let predicate = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)

        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }

    /// Waits for an element to not exist with a timeout.
    ///
    /// - Parameters:
    ///   - element: The element to wait to disappear
    ///   - timeout: Maximum time to wait (default: 5 seconds)
    /// - Returns: True if element doesn't exist within timeout, false otherwise
    @discardableResult
    func waitForDisappearance(of element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)

        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }

    // MARK: - Skill Helpers

    /// Creates a skill with the specified name through the UI.
    ///
    /// - Parameters:
    ///   - app: The XCUIApplication instance
    ///   - skillName: Name of the skill to create
    func createSkill(in app: XCUIApplication, named skillName: String) {
        // Click "Add skill" button or use keyboard shortcut
        let addSkillButton = app.buttons["Add skill"]

        if addSkillButton.exists {
            addSkillButton.click()
        } else {
            // Try keyboard shortcut ⌘N
            app.typeKey("n", modifierFlags: .command)
        }

        // Wait for text field to appear
        let textField = app.textFields.firstMatch
        XCTAssertTrue(wait(for: textField), "Text field should appear")

        // Type skill name and submit
        textField.click()
        textField.typeText(skillName)
        textField.typeKey(.return, modifierFlags: [])
    }

    /// Deletes a skill through the UI.
    ///
    /// - Parameters:
    ///   - app: The XCUIApplication instance
    ///   - skillName: Name of the skill to delete
    func deleteSkill(in app: XCUIApplication, named skillName: String) {
        // Find skill row
        let skillText = app.staticTexts[skillName]
        XCTAssertTrue(skillText.exists, "Skill '\(skillName)' should exist")

        // Hover over skill to reveal delete button
        // Note: Hover interactions are limited in macOS UI testing
        // May need to use accessibility identifiers or alternative approach

        // Find and click delete button
        // This implementation may need adjustment based on actual UI structure
        let deleteButton = app.buttons.matching(identifier: "delete_\(skillName)").firstMatch
        if deleteButton.exists {
            deleteButton.click()

            // Confirm deletion if alert appears
            let deleteConfirmButton = app.sheets.buttons["Delete"]
            if deleteConfirmButton.waitForExistence(timeout: 2) {
                deleteConfirmButton.click()
            }
        }
    }

    /// Starts tracking the specified skill.
    ///
    /// - Parameters:
    ///   - app: The XCUIApplication instance
    ///   - skillName: Name of the skill to start tracking
    func startTracking(in app: XCUIApplication, skill skillName: String) {
        // Find skill row and click play button
        let skillText = app.staticTexts[skillName]
        XCTAssertTrue(skillText.exists, "Skill '\(skillName)' should exist")

        // Find play button associated with this skill
        // May need to use accessibility identifiers
        let playButton = app.buttons.matching(identifier: "play_\(skillName)").firstMatch

        if playButton.exists {
            playButton.click()
        }
    }

    /// Pauses the current tracking session.
    ///
    /// - Parameter app: The XCUIApplication instance
    func pauseTracking(in app: XCUIApplication) {
        // Press spacebar
        app.typeKey(" ", modifierFlags: [])
    }

    /// Resumes a paused tracking session.
    ///
    /// - Parameter app: The XCUIApplication instance
    func resumeTracking(in app: XCUIApplication) {
        // Press spacebar
        app.typeKey(" ", modifierFlags: [])
    }

    /// Stops the current tracking session.
    ///
    /// - Parameter app: The XCUIApplication instance
    func stopTracking(in app: XCUIApplication) {
        // Press ⌘.
        app.typeKey(".", modifierFlags: .command)
    }

    // MARK: - Verification Helpers

    /// Verifies that a skill exists in the list.
    ///
    /// - Parameters:
    ///   - app: The XCUIApplication instance
    ///   - skillName: Name of the skill to verify
    func verifySkillExists(in app: XCUIApplication, named skillName: String) {
        let skillText = app.staticTexts[skillName]
        XCTAssertTrue(skillText.exists, "Skill '\(skillName)' should exist in the list")
    }

    /// Verifies that a skill does not exist in the list.
    ///
    /// - Parameters:
    ///   - app: The XCUIApplication instance
    ///   - skillName: Name of the skill to verify absence
    func verifySkillDoesNotExist(in app: XCUIApplication, named skillName: String) {
        let skillText = app.staticTexts[skillName]
        XCTAssertFalse(skillText.exists, "Skill '\(skillName)' should not exist in the list")
    }

    /// Verifies that a timer is running.
    ///
    /// - Parameter app: The XCUIApplication instance
    func verifyTimerIsRunning(in app: XCUIApplication) {
        // Look for active session indicators
        let activeSessionView = app.otherElements["ActiveSession"]
        XCTAssertTrue(activeSessionView.exists, "Active session view should be visible")

        // Verify timer is updating
        // Note: May need to add accessibility identifiers to timer display
    }

    /// Verifies that a timer is paused.
    ///
    /// - Parameter app: The XCUIApplication instance
    func verifyTimerIsPaused(in app: XCUIApplication) {
        // Look for pause indicator
        let pauseIndicator = app.buttons.matching(identifier: "resume").firstMatch
        XCTAssertTrue(pauseIndicator.exists, "Resume button should be visible when paused")
    }

    // MARK: - Menu Bar Helpers

    /// Clicks the menu bar icon to open/close the panel.
    ///
    /// - Parameter app: The XCUIApplication instance
    func clickMenuBarIcon(in app: XCUIApplication) {
        // Menu bar interactions are limited in UI testing
        // May need to use accessibility API or alternative approach

        // Attempt to find menu bar extra
        let menuBarExtra = app.menuBarItems.firstMatch
        if menuBarExtra.exists {
            menuBarExtra.click()
        }
    }
}

// MARK: - Constants

enum UITestConstants {
    static let defaultTimeout: TimeInterval = 5.0
    static let shortTimeout: TimeInterval = 2.0
    static let longTimeout: TimeInterval = 10.0

    // Test skill names
    static let testSkillName1 = "Swift Programming"
    static let testSkillName2 = "Python Development"
    static let testSkillName3 = "UI Design"

    // Maximum skill name length
    static let maxSkillNameLength = 30
}
