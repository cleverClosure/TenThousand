//
//  TimerManagerTests.swift
//  TenThousandTests
//
//  Unit tests for TimerManager
//  Testing behaviors, not implementations
//

@testable import TenThousand
import Testing

@Suite("TimerManager Behaviors", .serialized)
struct TimerManagerTests {
    // MARK: - Timer State Transition Behaviors

    @Test("Starting a timer transitions to running state")
    func testStartTransitionsToRunning() {
        let timer = TimerManager()

        #expect(!timer.isRunning)
        #expect(!timer.isPaused)

        timer.start()

        #expect(timer.isRunning)
        #expect(!timer.isPaused)
        #expect(timer.elapsedSeconds == 0)
    }

    @Test("Starting an already running timer has no effect")
    func testStartIdempotence() {
        let timer = TimerManager()

        timer.start()
        let firstRunningState = timer.isRunning

        timer.start() // Try to start again

        #expect(timer.isRunning == firstRunningState)
    }

    @Test("Pausing a running timer transitions to paused state")
    func testPauseTransitionsToPaused() {
        let timer = TimerManager()

        timer.start()
        timer.pause()

        #expect(timer.isRunning)
        #expect(timer.isPaused)
    }

    @Test("Pausing a non-running timer has no effect")
    func testPauseNonRunningTimerHasNoEffect() {
        let timer = TimerManager()

        timer.pause()

        #expect(!timer.isRunning)
        #expect(!timer.isPaused)
    }

    @Test("Pausing an already paused timer has no effect")
    func testPauseIdempotence() {
        let timer = TimerManager()

        timer.start()
        timer.pause()
        let firstPausedState = timer.isPaused

        timer.pause() // Try to pause again

        #expect(timer.isPaused == firstPausedState)
    }

    @Test("Resuming a paused timer transitions back to running")
    func testResumeTransitionsToRunning() {
        let timer = TimerManager()

        timer.start()
        timer.pause()
        timer.resume()

        #expect(timer.isRunning)
        #expect(!timer.isPaused)
    }

    @Test("Resuming a non-paused timer has no effect")
    func testResumeNonPausedTimerHasNoEffect() {
        let timer = TimerManager()

        timer.start()
        let wasRunning = timer.isRunning
        let wasPaused = timer.isPaused

        timer.resume() // Try to resume when not paused

        #expect(timer.isRunning == wasRunning)
        #expect(timer.isPaused == wasPaused)
    }

    @Test("Stopping a running timer resets state")
    func testStopResetsState() {
        let timer = TimerManager()

        timer.start()
        let finalSeconds = timer.stop()

        #expect(!timer.isRunning)
        #expect(!timer.isPaused)
        #expect(timer.elapsedSeconds == 0)
        #expect(finalSeconds >= 0)
    }

    @Test("Stopping a non-running timer returns zero")
    func testStopNonRunningTimerReturnsZero() {
        let timer = TimerManager()

        let finalSeconds = timer.stop()

        #expect(finalSeconds == 0)
        #expect(!timer.isRunning)
    }

    @Test("Stopping a paused timer includes elapsed time before pause")
    func testStopPausedTimerReturnsElapsedTime() {
        let timer = TimerManager()

        timer.start()
        timer.pause()
        let finalSeconds = timer.stop()

        #expect(finalSeconds >= 0)
        #expect(!timer.isRunning)
        #expect(!timer.isPaused)
    }

    // MARK: - Pause Duration Tracking Behaviors

    @Test("Paused duration starts at zero")
    func testInitialPausedDurationIsZero() {
        let timer = TimerManager()

        #expect(timer.getPausedDuration() == 0)
    }

    @Test("Paused duration remains zero when not paused")
    func testPausedDurationZeroWhenNotPaused() {
        let timer = TimerManager()

        timer.start()

        #expect(timer.getPausedDuration() == 0)
    }

    // MARK: - Complete Lifecycle Behaviors

    @Test("Complete start-pause-resume-stop lifecycle maintains state correctly")
    func testCompleteLifecycle() {
        let timer = TimerManager()

        // Start
        timer.start()
        #expect(timer.isRunning)
        #expect(!timer.isPaused)

        // Pause
        timer.pause()
        #expect(timer.isRunning)
        #expect(timer.isPaused)

        // Resume
        timer.resume()
        #expect(timer.isRunning)
        #expect(!timer.isPaused)

        // Stop
        let finalSeconds = timer.stop()
        #expect(!timer.isRunning)
        #expect(!timer.isPaused)
        #expect(finalSeconds >= 0)
    }

    @Test("Multiple pause-resume cycles maintain running state")
    func testMultiplePauseResumeCycles() {
        let timer = TimerManager()

        timer.start()

        // First pause-resume cycle
        timer.pause()
        #expect(timer.isPaused)
        timer.resume()
        #expect(!timer.isPaused)

        // Second pause-resume cycle
        timer.pause()
        #expect(timer.isPaused)
        timer.resume()
        #expect(!timer.isPaused)

        #expect(timer.isRunning)
    }

    @Test("Restarting a stopped timer resets all state")
    func testRestartAfterStop() {
        let timer = TimerManager()

        timer.start()
        timer.pause()
        _ = timer.stop()

        // Restart
        timer.start()

        #expect(timer.isRunning)
        #expect(!timer.isPaused)
        #expect(timer.elapsedSeconds == 0)
        #expect(timer.getPausedDuration() == 0)
    }
}

// MARK: - Time Formatting Behaviors

@Suite("Time Formatting Behaviors")
struct TimeFormattingTests {
    @Test("Zero seconds formats as 00:00")
    func testZeroSecondsFormat() {
        let formatted = Int64(0).formattedTime()
        #expect(formatted == "00:00")
    }

    @Test("Seconds only formats as MM:SS")
    func testSecondsOnlyFormat() {
        #expect(Int64(5).formattedTime() == "00:05")
        #expect(Int64(30).formattedTime() == "00:30")
        #expect(Int64(59).formattedTime() == "00:59")
    }

    @Test("Minutes and seconds format as MM:SS")
    func testMinutesAndSecondsFormat() {
        #expect(Int64(60).formattedTime() == "01:00")
        #expect(Int64(90).formattedTime() == "01:30")
        #expect(Int64(600).formattedTime() == "10:00")
        #expect(Int64(3599).formattedTime() == "59:59")
    }

    @Test("Hours format as H:MM:SS")
    func testHoursFormat() {
        #expect(Int64(3600).formattedTime() == "1:00:00")
        #expect(Int64(3661).formattedTime() == "1:01:01")
        #expect(Int64(7200).formattedTime() == "2:00:00")
        #expect(Int64(36000).formattedTime() == "10:00:00")
    }

    @Test("Large hours format correctly")
    func testLargeHoursFormat() {
        #expect(Int64(360000).formattedTime() == "100:00:00")
        #expect(Int64(359999).formattedTime() == "99:59:59")
    }

    // MARK: - Short Time Format Behaviors

    @Test("Zero seconds formats as <1m")
    func testZeroSecondsShortFormat() {
        #expect(Int64(0).formattedShortTime() == "<1m")
    }

    @Test("Less than one minute formats as <1m")
    func testLessThanOneMinuteShortFormat() {
        #expect(Int64(1).formattedShortTime() == "<1m")
        #expect(Int64(30).formattedShortTime() == "<1m")
        #expect(Int64(59).formattedShortTime() == "<1m")
    }

    @Test("Minutes only formats as Nm")
    func testMinutesOnlyShortFormat() {
        #expect(Int64(60).formattedShortTime() == "1m")
        #expect(Int64(120).formattedShortTime() == "2m")
        #expect(Int64(600).formattedShortTime() == "10m")
        #expect(Int64(3540).formattedShortTime() == "59m")
    }

    @Test("Hours only formats as Nh")
    func testHoursOnlyShortFormat() {
        #expect(Int64(3600).formattedShortTime() == "1h")
        #expect(Int64(7200).formattedShortTime() == "2h")
        #expect(Int64(36000).formattedShortTime() == "10h")
    }

    @Test("Hours and minutes format as Nh Nm")
    func testHoursAndMinutesShortFormat() {
        #expect(Int64(3660).formattedShortTime() == "1h 1m")
        #expect(Int64(3720).formattedShortTime() == "1h 2m")
        #expect(Int64(7260).formattedShortTime() == "2h 1m")
        #expect(Int64(9000).formattedShortTime() == "2h 30m")
    }

    @Test("Hours and minutes ignore seconds in short format")
    func testShortFormatIgnoresSeconds() {
        #expect(Int64(3661).formattedShortTime() == "1h 1m")
        #expect(Int64(3719).formattedShortTime() == "1h 1m")
        #expect(Int64(3661).formattedShortTime() == Int64(3719).formattedShortTime())
    }

    @Test("Large hours format correctly in short format")
    func testLargeHoursShortFormat() {
        #expect(Int64(360000).formattedShortTime() == "100h")
        #expect(Int64(360060).formattedShortTime() == "100h 1m")
    }

    // MARK: - Edge Cases

    @Test("Boundary values format correctly")
    func testBoundaryValues() {
        // Just under one minute
        #expect(Int64(59).formattedTime() == "00:59")
        #expect(Int64(59).formattedShortTime() == "<1m")

        // Exactly one minute
        #expect(Int64(60).formattedTime() == "01:00")
        #expect(Int64(60).formattedShortTime() == "1m")

        // Just under one hour
        #expect(Int64(3599).formattedTime() == "59:59")
        #expect(Int64(3599).formattedShortTime() == "59m")

        // Exactly one hour
        #expect(Int64(3600).formattedTime() == "1:00:00")
        #expect(Int64(3600).formattedShortTime() == "1h")
    }

    @Test("Negative values are handled gracefully")
    func testNegativeValues() {
        // Behavior: Negative values should be treated as edge cases
        // The implementation may vary, but it should not crash
        let negativeFormatted = Int64(-1).formattedTime()
        let negativeShortFormatted = Int64(-1).formattedShortTime()

        // Just verify it doesn't crash and returns a string
        #expect(!negativeFormatted.isEmpty)
        #expect(!negativeShortFormatted.isEmpty)
    }
}

// MARK: - Pause Tracking Precision Behaviors

@Suite("Pause Tracking Precision Behaviors", .serialized)
struct PauseTrackingPrecisionTests {
    // MARK: - Multiple Pause Cycle Tests

    @Test("Multiple pause-resume cycles maintain state correctly")
    func testMultiplePauseResumeCyclesMaintainState() {
        let timer = TimerManager()

        timer.start()

        // Cycle 1
        timer.pause()
        #expect(timer.isPaused)
        #expect(timer.isRunning)
        timer.resume()
        #expect(!timer.isPaused)
        #expect(timer.isRunning)

        // Cycle 2
        timer.pause()
        #expect(timer.isPaused)
        timer.resume()
        #expect(!timer.isPaused)

        // Cycle 3
        timer.pause()
        #expect(timer.isPaused)
        timer.resume()
        #expect(!timer.isPaused)

        // Cycle 4
        timer.pause()
        #expect(timer.isPaused)
        timer.resume()
        #expect(!timer.isPaused)

        // Cycle 5
        timer.pause()
        #expect(timer.isPaused)
        timer.resume()
        #expect(!timer.isPaused)

        #expect(timer.isRunning)
    }

    @Test("Pause duration is zero immediately after start")
    func testPauseDurationZeroAfterStart() {
        let timer = TimerManager()

        timer.start()

        #expect(timer.getPausedDuration() == 0)
    }

    @Test("Paused duration accessible after resume")
    func testPausedDurationAccessibleAfterResume() {
        let timer = TimerManager()

        timer.start()
        timer.pause()
        timer.resume()

        // Paused duration should be >= 0 (could be 0 if paused very briefly)
        #expect(timer.getPausedDuration() >= 0)
    }

    @Test("Stop while running returns elapsed time")
    func testStopWhileRunningReturnsElapsedTime() {
        let timer = TimerManager()

        timer.start()
        let finalSeconds = timer.stop()

        #expect(finalSeconds >= 0)
        #expect(!timer.isRunning)
        #expect(!timer.isPaused)
    }

    @Test("Stop while paused returns elapsed time before pause")
    func testStopWhilePausedReturnsElapsedTime() {
        let timer = TimerManager()

        timer.start()
        timer.pause()
        let finalSeconds = timer.stop()

        #expect(finalSeconds >= 0)
        #expect(!timer.isRunning)
        #expect(!timer.isPaused)
    }

    @Test("Paused duration resets after stop")
    func testPausedDurationResetsAfterStop() {
        let timer = TimerManager()

        timer.start()
        timer.pause()
        timer.resume()
        _ = timer.stop()

        #expect(timer.getPausedDuration() == 0)
    }

    @Test("Paused duration resets after restart")
    func testPausedDurationResetsAfterRestart() {
        let timer = TimerManager()

        timer.start()
        timer.pause()
        timer.resume()
        _ = timer.stop()

        timer.start()

        #expect(timer.getPausedDuration() == 0)
    }

    // MARK: - Idempotence Tests

    @Test("Multiple resume calls while not paused are idempotent")
    func testMultipleResumeCallsIdempotent() {
        let timer = TimerManager()

        timer.start()

        // Call resume multiple times without pausing
        timer.resume()
        timer.resume()
        timer.resume()

        #expect(timer.isRunning)
        #expect(!timer.isPaused)
    }

    @Test("Multiple pause calls while paused are idempotent")
    func testMultiplePauseCallsIdempotent() {
        let timer = TimerManager()

        timer.start()
        timer.pause()

        let pausedDuration1 = timer.getPausedDuration()

        timer.pause()
        timer.pause()
        timer.pause()

        // Paused duration should not dramatically increase from extra pause calls
        let pausedDuration2 = timer.getPausedDuration()

        #expect(timer.isPaused)
        #expect(pausedDuration2 >= pausedDuration1)
    }

    @Test("Multiple stop calls are idempotent")
    func testMultipleStopCallsIdempotent() {
        let timer = TimerManager()

        timer.start()
        let firstStop = timer.stop()
        let secondStop = timer.stop()
        let thirdStop = timer.stop()

        #expect(secondStop == 0)
        #expect(thirdStop == 0)
        #expect(!timer.isRunning)
    }

    // MARK: - State Consistency Tests

    @Test("Timer state is consistent after rapid pause-resume cycles")
    func testStateConsistencyAfterRapidCycles() {
        let timer = TimerManager()

        timer.start()

        // Rapid pause-resume cycles
        for _ in 0..<10 {
            timer.pause()
            timer.resume()
        }

        #expect(timer.isRunning)
        #expect(!timer.isPaused)
        #expect(timer.elapsedSeconds >= 0)
    }

    @Test("Timer can be stopped from any state")
    func testTimerCanBeStoppedFromAnyState() {
        // Test stopping from stopped state
        let timer1 = TimerManager()
        let result1 = timer1.stop()
        #expect(result1 == 0)

        // Test stopping from running state
        let timer2 = TimerManager()
        timer2.start()
        let result2 = timer2.stop()
        #expect(result2 >= 0)

        // Test stopping from paused state
        let timer3 = TimerManager()
        timer3.start()
        timer3.pause()
        let result3 = timer3.stop()
        #expect(result3 >= 0)
    }

    @Test("Elapsed seconds is always non-negative")
    func testElapsedSecondsNonNegative() {
        let timer = TimerManager()

        #expect(timer.elapsedSeconds >= 0)

        timer.start()
        #expect(timer.elapsedSeconds >= 0)

        timer.pause()
        #expect(timer.elapsedSeconds >= 0)

        timer.resume()
        #expect(timer.elapsedSeconds >= 0)

        _ = timer.stop()
        #expect(timer.elapsedSeconds >= 0)
    }

    @Test("Paused duration is always non-negative")
    func testPausedDurationNonNegative() {
        let timer = TimerManager()

        #expect(timer.getPausedDuration() >= 0)

        timer.start()
        #expect(timer.getPausedDuration() >= 0)

        timer.pause()
        #expect(timer.getPausedDuration() >= 0)

        timer.resume()
        #expect(timer.getPausedDuration() >= 0)

        _ = timer.stop()
        #expect(timer.getPausedDuration() >= 0)
    }

    // MARK: - Edge Case Tests

    @Test("Timer handles start after being stopped")
    func testStartAfterStop() {
        let timer = TimerManager()

        timer.start()
        _ = timer.stop()

        timer.start()

        #expect(timer.isRunning)
        #expect(!timer.isPaused)
        #expect(timer.elapsedSeconds == 0)
        #expect(timer.getPausedDuration() == 0)
    }

    @Test("Timer handles pause-stop-start sequence")
    func testPauseStopStartSequence() {
        let timer = TimerManager()

        timer.start()
        timer.pause()
        _ = timer.stop()
        timer.start()

        #expect(timer.isRunning)
        #expect(!timer.isPaused)
        #expect(timer.elapsedSeconds == 0)
    }

    @Test("Timer handles start-stop-start-stop sequence")
    func testStartStopStartStopSequence() {
        let timer = TimerManager()

        timer.start()
        let result1 = timer.stop()
        #expect(result1 >= 0)

        timer.start()
        let result2 = timer.stop()
        #expect(result2 >= 0)

        #expect(!timer.isRunning)
    }

    @Test("Pausing immediately after start works correctly")
    func testPauseImmediatelyAfterStart() {
        let timer = TimerManager()

        timer.start()
        timer.pause()

        #expect(timer.isRunning)
        #expect(timer.isPaused)
        #expect(timer.elapsedSeconds == 0)
    }

    @Test("Stopping immediately after start returns zero or near-zero")
    func testStopImmediatelyAfterStart() {
        let timer = TimerManager()

        timer.start()
        let result = timer.stop()

        // Should be 0 since no time has passed
        #expect(result >= 0)
        #expect(result < 2) // Allow for small timing variations
    }
}
