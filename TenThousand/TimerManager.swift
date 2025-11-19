//
//  TimerManager.swift
//  TenThousand
//
//  Timer system using Combine
//

import Foundation
import Combine

class TimerManager: ObservableObject {
    @Published var elapsedSeconds: Int64 = 0
    @Published var isRunning = false
    @Published var isPaused = false

    private var startTime: Date?
    private var pauseStartTime: Date?
    private var totalPausedDuration: TimeInterval = 0
    private var timerCancellable: AnyCancellable?

    func start() {
        guard !isRunning else { return }

        startTime = Date()
        totalPausedDuration = 0
        elapsedSeconds = 0
        isRunning = true
        isPaused = false

        startTimer()
    }

    func pause() {
        guard isRunning, !isPaused else { return }

        isPaused = true
        pauseStartTime = Date()
        stopTimer()
    }

    func resume() {
        guard isRunning, isPaused else { return }

        if let pauseStart = pauseStartTime {
            totalPausedDuration += Date().timeIntervalSince(pauseStart)
        }

        isPaused = false
        pauseStartTime = nil
        startTimer()
    }

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

    func getPausedDuration() -> Int64 {
        return Int64(totalPausedDuration)
    }
}

// MARK: - Time Formatting

extension Int64 {
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
