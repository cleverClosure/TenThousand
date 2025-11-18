//
//  MenuBarIconView.swift
//  TenThousand
//
//  Menubar icon with idle/active states
//

import SwiftUI

struct MenuBarIconView: View {
    @ObservedObject var timerManager: TimerManager

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: timerManager.isRunning && !timerManager.isPaused ? "circle.fill" : "circle")
                .font(.system(size: 14, weight: .medium))
                .symbolRenderingMode(.hierarchical)

            if timerManager.isRunning {
                Text(timerManager.elapsedSeconds.formattedTime())
                    .font(Typography.timeDisplay)
                    .monospacedDigit()
            }
        }
    }
}
