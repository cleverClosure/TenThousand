//
//  TimerManager.swift
//  TenThousand
//
//  Timer system using Combine
//

import Combine
import Foundation

/// A Combine-based timer manager that tracks elapsed time with pause/resume support.
///
/// TimerManager uses Combine's Timer.publish to update elapsed time every second.
/// It accurately tracks pause duration to exclude paused time from the final count.
///
/// ## State Machine
/// ```
/// stopped → start() → running
/// running → pause() → paused
/// paused → resume() → running
/// running/paused → stop() → stopped
/// ```
///
/// ## Usage Example
/// ```swift
/// let timer = TimerManager()
/// timer.start()                    // Starts counting
/// // ... wait 10 seconds ...
/// timer.pause()                    // Pauses at 10 seconds
/// // ... wait 5 seconds ...
/// timer.resume()                   // Resumes counting
/// // ... wait 5 seconds ...
/// let total = timer.stop()         // Returns 15 (10 + 5, pause time excluded)
/// ```
class TimerManager: ObservableObject {
    // MARK: - Published Properties

    /// Current elapsed seconds (excluding paused time).
    /// Updates every second while timer is running.
    @Published var elapsedSeconds: Int64 = 0

    /// Whether the timer is currently running (true) or stopped (false).
    @Published var isRunning = false

    /// Whether the timer is currently paused.
    /// Only true when running and paused; false when stopped or actively running.
    @Published var isPaused = false

    // MARK: - Private State

    private var startTime: Date?
    private var pauseStartTime: Date?
    private var totalPausedDuration: TimeInterval = 0
    private var timerCancellable: AnyCancellable?

    // MARK: - Public Methods

    /// Starts the timer from zero.
    ///
    /// Resets all state and begins counting. If the timer is already running,
    /// this method does nothing (idempotent).
    ///
    /// - Postconditions:
    ///   - `isRunning` = true
    ///   - `isPaused` = false
    ///   - `elapsedSeconds` = 0
    ///   - Timer updates every second
    func start() {
        guard !isRunning else { return }

        startTime = Date()
        totalPausedDuration = 0
        elapsedSeconds = 0
        isRunning = true
        isPaused = false

        startTimer()
    }

    /// Pauses the timer without stopping it.
    ///
    /// The timer remains in running state but `elapsedSeconds` stops updating.
    /// Pause duration is tracked and excluded from elapsed time. If the timer
    /// is not running or already paused, this method does nothing (idempotent).
    ///
    /// - Postconditions:
    ///   - `isPaused` = true
    ///   - `isRunning` = true (still running, just paused)
    ///   - `elapsedSeconds` stops incrementing
    ///
    /// - Note: Call `resume()` to continue timing, or `stop()` to end the session.
    func pause() {
        guard isRunning, !isPaused else { return }

        isPaused = true
        pauseStartTime = Date()
        stopTimer()
    }

    /// Resumes a paused timer.
    ///
    /// Continues counting from where the timer was paused. The time spent paused
    /// is added to `totalPausedDuration` and excluded from `elapsedSeconds`.
    /// If the timer is not paused, this method does nothing (idempotent).
    ///
    /// - Postconditions:
    ///   - `isPaused` = false
    ///   - `elapsedSeconds` starts incrementing again
    ///   - Pause duration added to total
    func resume() {
        guard isRunning, isPaused else { return }

        if let pauseStart = pauseStartTime {
            totalPausedDuration += Date().timeIntervalSince(pauseStart)
        }

        isPaused = false
        pauseStartTime = nil
        startTimer()
    }

    /// Stops the timer and resets all state.
    ///
    /// If the timer is paused when stopped, the final pause duration is included
    /// in the total pause time (and excluded from returned seconds).
    ///
    /// - Returns: Final elapsed seconds (excluding all pause time), or 0 if not running
    ///
    /// - Postconditions:
    ///   - `isRunning` = false
    ///   - `isPaused` = false
    ///   - `elapsedSeconds` = 0
    ///   - All internal state cleared
    ///
    /// ## Example
    /// ```swift
    /// timer.start()
    /// // ... 10 seconds pass ...
    /// timer.pause()
    /// // ... 5 seconds pass (paused) ...
    /// let total = timer.stop()  // Returns 10 (pause time excluded)
    /// ```
    func stop() -> Int64 {
        guard isRunning else { return 0 }

        // If currently paused, add the current pause duration to total
        if isPaused, let pauseStart = pauseStartTime {
            totalPausedDuration += Date().timeIntervalSince(pauseStart)
        }

        let finalSeconds = elapsedSeconds
        isRunning = false
        isPaused = false
        elapsedSeconds = 0
        startTime = nil
        pauseStartTime = nil
        totalPausedDuration = 0
        stopTimer()

        return finalSeconds
    }

    private func startTimer() {
        timerCancellable = Timer.publish(every: TimeConstants.timerUpdateInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateElapsedTime()
            }
    }

    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    private func updateElapsedTime() {
        guard let start = startTime else { return }
        let elapsed = Date().timeIntervalSince(start) - totalPausedDuration
        elapsedSeconds = Int64(elapsed)
    }

    /// Returns the total time spent paused (in seconds).
    ///
    /// This includes all pause periods during the current session.
    /// If the timer is currently paused, the active pause duration is included.
    ///
    /// - Returns: Total paused duration in seconds
    ///
    /// - Note: This is called by AppViewModel when stopping a session to record
    ///   the pause duration in CoreData.
    func getPausedDuration() -> Int64 {
        return Int64(totalPausedDuration)
    }
}

// MARK: - Time Formatting

extension Int64 {
    /// Formats seconds as a time string in H:MM:SS or M:SS format.
    ///
    /// - Returns: Formatted time string
    ///   - If >= 1 hour: "H:MM:SS" (e.g., "2:30:45")
    ///   - If < 1 hour: "M:SS" (e.g., "15:30")
    ///
    /// ## Examples
    /// ```swift
    /// Int64(45).formattedTime()      // "0:45"
    /// Int64(90).formattedTime()      // "1:30"
    /// Int64(3665).formattedTime()    // "1:01:05"
    /// ```
    func formattedTime() -> String {
        let hours = self / TimeConstants.secondsPerHour
        let minutes = (self % TimeConstants.secondsPerHour) / TimeConstants.secondsPerMinute
        let seconds = self % TimeConstants.secondsPerMinute

        if hours > 0 {
            return String(format: FormatStrings.timeWithHours, hours, minutes, seconds)
        } else {
            return String(format: FormatStrings.timeWithoutHours, minutes, seconds)
        }
    }

    /// Formats seconds as a short, human-readable string (e.g., "2h 30m", "45m", "<1m").
    ///
    /// Ideal for displaying in skill lists or summaries where space is limited.
    ///
    /// - Returns: Abbreviated time string
    ///   - If >= 1 hour with minutes: "Hh Mm" (e.g., "2h 30m")
    ///   - If >= 1 hour, no minutes: "Hh" (e.g., "3h")
    ///   - If >= 1 minute: "Mm" (e.g., "45m")
    ///   - If < 1 minute: "<1m"
    ///
    /// ## Examples
    /// ```swift
    /// Int64(30).formattedShortTime()      // "<1m"
    /// Int64(120).formattedShortTime()     // "2m"
    /// Int64(3600).formattedShortTime()    // "1h"
    /// Int64(5430).formattedShortTime()    // "1h 30m"
    /// ```
    func formattedShortTime() -> String {
        let hours = self / TimeConstants.secondsPerHour
        let minutes = (self % TimeConstants.secondsPerHour) / TimeConstants.secondsPerMinute

        if hours > 0 {
            if minutes > 0 {
                return "\(hours)\(UIText.hoursSeparator)\(minutes)\(UIText.minutesSuffix)"
            } else {
                return "\(hours)\(UIText.hoursSuffix)"
            }
        } else if minutes > 0 {
            return "\(minutes)\(UIText.minutesSuffix)"
        } else {
            return UIText.lessThanOneMinute
        }
    }
}
