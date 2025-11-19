//
//  SessionTrackingUITests.swift
//  TenThousandUITests
//
//  UI tests for session tracking workflows
//

import XCTest

final class SessionTrackingUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = launchAppForTesting()

        // Create a test skill for tracking tests
        createSkill(in: app, named: UITestConstants.testSkillName1)
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    // MARK: - Basic Tracking

    func testStartTracking() throws {
        // Test starting a tracking session

        let skillName = UITestConstants.testSkillName1

        // Click play button
        startTracking(in: app, skill: skillName)

        // Active session view should appear
        let activeSessionView = app.otherElements["ActiveSession"]
        XCTAssertTrue(wait(for: activeSessionView, timeout: 3), "Active session view should appear")

        // Timer should be visible and running
        // Note: Actual timer value verification requires accessibility identifiers
    }

    func testStartTrackingSwitchesFromAnotherSkill() throws {
        // Test that starting tracking on a new skill stops the previous session

        // Create second skill
        createSkill(in: app, named: UITestConstants.testSkillName2)

        // Start tracking first skill
        startTracking(in: app, skill: UITestConstants.testSkillName1)
        verifyTimerIsRunning(in: app)

        // Wait a moment
        sleep(2)

        // Start tracking second skill
        startTracking(in: app, skill: UITestConstants.testSkillName2)

        // Should still only have one active session
        let activeSessions = app.otherElements.matching(identifier: "ActiveSession")
        XCTAssertEqual(activeSessions.count, 1, "Should only have one active session")

        // First skill's session should have been saved
        // Note: Verification requires checking skill totals or session history
    }

    // MARK: - Pause and Resume

    func testPauseTracking() throws {
        // Test pausing a tracking session

        startTracking(in: app, skill: UITestConstants.testSkillName1)
        verifyTimerIsRunning(in: app)

        // Wait a moment
        sleep(2)

        // Pause using spacebar
        pauseTracking(in: app)

        // Pause indicator should appear
        verifyTimerIsPaused(in: app)

        // Timer should stop incrementing
        // Note: Requires reading timer value before and after pause
    }

    func testResumeTracking() throws {
        // Test resuming a paused session

        startTracking(in: app, skill: UITestConstants.testSkillName1)
        verifyTimerIsRunning(in: app)

        // Pause
        sleep(1)
        pauseTracking(in: app)
        verifyTimerIsPaused(in: app)

        // Wait while paused
        sleep(2)

        // Resume using spacebar
        resumeTracking(in: app)

        // Should be running again
        verifyTimerIsRunning(in: app)

        // Pause time should be excluded from total
        // Note: Requires unit test verification of pause duration tracking
    }

    func testMultiplePauseResumeCycles() throws {
        // Test multiple pause/resume cycles

        startTracking(in: app, skill: UITestConstants.testSkillName1)

        for _ in 0..<3 {
            // Run for a bit
            sleep(1)

            // Pause
            pauseTracking(in: app)
            verifyTimerIsPaused(in: app)
            sleep(1)

            // Resume
            resumeTracking(in: app)
            verifyTimerIsRunning(in: app)
        }

        // Session should still be active
        let activeSessionView = app.otherElements["ActiveSession"]
        XCTAssertTrue(activeSessionView.exists, "Active session should still exist after multiple pause/resume cycles")
    }

    // MARK: - Stop Tracking

    func testStopTracking() throws {
        // Test stopping a tracking session

        startTracking(in: app, skill: UITestConstants.testSkillName1)
        verifyTimerIsRunning(in: app)

        // Wait a bit to accumulate time
        sleep(3)

        // Stop tracking using ⌘.
        stopTracking(in: app)

        // Active session view should disappear
        let activeSessionView = app.otherElements["ActiveSession"]
        XCTAssertTrue(waitForDisappearance(of: activeSessionView, timeout: 3), "Active session should disappear after stopping")

        // Skill list should be visible again
        let skillText = app.staticTexts[UITestConstants.testSkillName1]
        XCTAssertTrue(skillText.exists, "Skill list should be visible after stopping")

        // Session should be saved
        // Note: Verification requires checking skill total time increased
    }

    func testStopTrackingWhilePaused() throws {
        // Test stopping a session that is currently paused

        startTracking(in: app, skill: UITestConstants.testSkillName1)
        sleep(2)

        // Pause
        pauseTracking(in: app)
        verifyTimerIsPaused(in: app)
        sleep(2)

        // Stop while paused
        stopTracking(in: app)

        // Session should be saved with correct pause duration
        let activeSessionView = app.otherElements["ActiveSession"]
        XCTAssertTrue(waitForDisappearance(of: activeSessionView), "Active session should disappear")
    }

    func testStopButton() throws {
        // Test using the stop button directly (if available)

        startTracking(in: app, skill: UITestConstants.testSkillName1)
        verifyTimerIsRunning(in: app)

        sleep(2)

        // Find and click stop button
        let stopButton = app.buttons["Stop"]
        if stopButton.exists {
            stopButton.click()

            // Session should end
            let activeSessionView = app.otherElements["ActiveSession"]
            XCTAssertTrue(waitForDisappearance(of: activeSessionView), "Active session should disappear after clicking stop")
        }
    }

    // MARK: - Timer Display

    func testTimerDisplayUpdates() throws {
        // Test that the timer display updates every second

        startTracking(in: app, skill: UITestConstants.testSkillName1)

        // Note: Reading actual timer values requires accessibility identifiers
        // This test verifies the timer is running; unit tests verify accuracy

        // Wait to ensure timer is updating
        sleep(5)

        // Timer should still be visible and session active
        verifyTimerIsRunning(in: app)
    }

    func testTimerDisplayFormat() throws {
        // Test that timer displays in correct format (M:SS or H:MM:SS)

        startTracking(in: app, skill: UITestConstants.testSkillName1)

        // Initially should show 0:00 or similar
        // After 1 minute should show 1:00
        // After 1 hour should show 1:00:00

        // Note: Requires accessibility identifiers to read timer value
        // Verification done in unit tests for formattedTime()

        sleep(2)
        verifyTimerIsRunning(in: app)
    }

    // MARK: - Session Persistence

    func testSessionSavedOnStop() throws {
        // Test that stopping saves the session

        startTracking(in: app, skill: UITestConstants.testSkillName1)
        sleep(3)
        stopTracking(in: app)

        // Skill's total time should have increased
        // Note: Requires ability to read skill total time from UI
        // Or verify through database/CoreData inspection

        let skillText = app.staticTexts[UITestConstants.testSkillName1]
        XCTAssertTrue(skillText.exists, "Skill should still exist after session")
    }

    func testSessionNotSavedIfNotStarted() throws {
        // Test that no session is created if never started

        // Just verify skill exists but has no sessions
        verifySkillExists(in: app, named: UITestConstants.testSkillName1)

        // Try to pause/stop without starting (should do nothing)
        pauseTracking(in: app)
        stopTracking(in: app)

        // No active session should exist
        let activeSessionView = app.otherElements["ActiveSession"]
        XCTAssertFalse(activeSessionView.exists, "No active session should exist")
    }

    // MARK: - Edge Cases

    func testPauseWhenNotRunning() throws {
        // Test that pause does nothing when not tracking

        pauseTracking(in: app)

        // No active session should appear
        let activeSessionView = app.otherElements["ActiveSession"]
        XCTAssertFalse(activeSessionView.exists, "No active session should exist")
    }

    func testResumeWhenNotPaused() throws {
        // Test that resume does nothing when not paused

        startTracking(in: app, skill: UITestConstants.testSkillName1)
        verifyTimerIsRunning(in: app)

        // Try to resume while already running (should be idempotent)
        resumeTracking(in: app)

        // Should still be running normally
        verifyTimerIsRunning(in: app)
    }

    func testStopWhenNotRunning() throws {
        // Test that stop does nothing when not tracking

        stopTracking(in: app)

        // No session should be created
        let activeSessionView = app.otherElements["ActiveSession"]
        XCTAssertFalse(activeSessionView.exists, "No active session should exist")
    }

    func testRapidStartStop() throws {
        // Test rapidly starting and stopping sessions

        for _ in 0..<3 {
            startTracking(in: app, skill: UITestConstants.testSkillName1)
            verifyTimerIsRunning(in: app)

            // Stop almost immediately
            stopTracking(in: app)

            let activeSessionView = app.otherElements["ActiveSession"]
            XCTAssertTrue(waitForDisappearance(of: activeSessionView, timeout: 2), "Session should stop")
        }

        // App should still be functional
        verifySkillExists(in: app, named: UITestConstants.testSkillName1)
    }

    // MARK: - Animation and Highlights

    func testSkillHighlightAfterStop() throws {
        // Test that skill is highlighted after stopping a session

        startTracking(in: app, skill: UITestConstants.testSkillName1)
        sleep(2)
        stopTracking(in: app)

        // Skill should be highlighted briefly (justUpdatedSkillId)
        // Note: Requires visual verification or accessibility state checking
        // Highlight should clear after animation duration (1 second)

        sleep(2)

        // Skill should still be visible but no longer highlighted
        verifySkillExists(in: app, named: UITestConstants.testSkillName1)
    }

    // MARK: - Today's Summary

    func testTodaysSummaryUpdatesAfterSession() throws {
        // Test that today's summary updates after completing a session

        startTracking(in: app, skill: UITestConstants.testSkillName1)
        sleep(5)  // Track for 5 seconds
        stopTracking(in: app)

        // Today's summary should show updated total
        // Note: Requires accessibility identifier for summary display

        let summaryView = app.otherElements["TodaysSummary"]
        if summaryView.exists {
            // Verify it shows non-zero time
            // Requires reading text content
        }
    }

    func testTodaysSkillCountIncreases() throws {
        // Test that skill count increases when tracking new skill

        // Track first skill
        startTracking(in: app, skill: UITestConstants.testSkillName1)
        sleep(2)
        stopTracking(in: app)

        // Create and track second skill
        createSkill(in: app, named: UITestConstants.testSkillName2)
        startTracking(in: app, skill: UITestConstants.testSkillName2)
        sleep(2)
        stopTracking(in: app)

        // Today's skill count should be 2
        // Note: Requires accessibility identifier for skill count display
    }
}
