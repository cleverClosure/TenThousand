//
//  MenuBarIconView.swift
//  TenThousand
//
//  Menubar icon with idle/active states
//  The menubar is sacred space. Our icon must earn its place through discretion and utility.
//

import SwiftUI

struct MenuBarIconView: View {
    // MARK: - Properties

    @ObservedObject var timerManager: TimerManager
    @AppStorage("showMenuBarTimer") private var showMenuBarTimer = true

    // MARK: - Body

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .symbolRenderingMode(.hierarchical)

            if showMenuBarTimer && timerManager.isRunning {
                Text(timerManager.elapsedSeconds.formattedTime())
                    .monospacedDigit()
                    .frame(width: Dimensions.menubarTimerWidth, alignment: .leading)
            }
        }
    }

    // MARK: - Private Computed Properties

    private var iconName: String {
        if timerManager.isRunning && !timerManager.isPaused {
            return "circle.circle.fill"
        } else if timerManager.isRunning && timerManager.isPaused {
            return "pause.circle"
        } else {
            return "circle.circle"
        }
    }
}
