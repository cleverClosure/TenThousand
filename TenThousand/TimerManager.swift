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
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
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
        let hours = self / 3600
        let minutes = (self % 3600) / 60
        let seconds = self % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    func formattedShortTime() -> String {
        let hours = self / 3600
        let minutes = (self % 3600) / 60

        if hours > 0 {
            if minutes > 0 {
                return "\(hours)h \(minutes)m"
            } else {
                return "\(hours)h"
            }
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "<1m"
        }
    }
}
