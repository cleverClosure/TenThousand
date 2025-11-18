//
//  ActiveSessionView.swift
//  TenThousand
//
//  Active tracking session display
//

import SwiftUI

struct ActiveSessionView: View {
    let skill: Skill
    @ObservedObject var timerManager: TimerManager
    let onPause: () -> Void
    let onResume: () -> Void
    let onStop: () -> Void

    var body: some View {
        VStack(spacing: Spacing.base) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.tight) {
                    Text(skill.name ?? "Untitled")
                        .font(Typography.display)
                        .foregroundColor(.primary)

                    Text(timerManager.isPaused ? "Paused" : "Currently tracking")
                        .font(Typography.caption)
                        .foregroundColor(.secondary)
                        .opacity(timerManager.isPaused ? 0.6 : 1.0)
                }

                Spacer()

                Text(timerManager.elapsedSeconds.formattedTime())
                    .font(Typography.largeTimeDisplay)
                    .foregroundColor(.primary)
                    .opacity(timerManager.isPaused ? 0.6 : 1.0)
            }

            HStack(spacing: Spacing.base) {
                Spacer()

                // Pause/Resume button
                Button(action: {
                    if timerManager.isPaused {
                        onResume()
                    } else {
                        onPause()
                    }
                }) {
                    Image(systemName: timerManager.isPaused ? "play.fill" : "pause.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(IconButtonStyle())

                // Stop button
                Button(action: onStop) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(IconButtonStyle())
            }
        }
        .padding(Spacing.loose)
        .frame(height: Dimensions.activeSessionHeight)
        .background(
            RoundedRectangle(cornerRadius: Dimensions.cornerRadiusMedium)
                .fill(Color.trackingBlue.opacity(timerManager.isPaused ? 0.03 : 0.05))
        )
    }
}
