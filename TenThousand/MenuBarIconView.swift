//
//  MenuBarIconView.swift
//  TenThousand
//
//  Author: Tim Isaev
//
//  Custom branded menu bar icon representing the 10,000 hour mastery journey.
//  The menubar is sacred space. Our icon must earn its place through discretion and utility.
//

import SwiftUI

struct MenuBarIconView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: AppViewModel
    @AppStorage("showMenuBarTimer") private var showMenuBarTimer = true

    // MARK: - Constants

    private let iconSize: CGFloat = 20
    private let strokeWidth: CGFloat = 2

    // MARK: - Body

    var body: some View {
        HStack(spacing: 6) {
            masteryIcon
                .frame(width: iconSize, height: iconSize)

            if showMenuBarTimer && viewModel.isTimerRunning {
                timerText
            }
        }
    }

    // MARK: - Icon View

    private var masteryIcon: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(
                    Color.primary.opacity(isTracking ? 0.15 : 0.35),
                    lineWidth: strokeWidth
                )

            // Progress circle (fills when tracking)
            if isTracking {
                Circle()
                    .trim(from: 0, to: progressTrim)
                    .stroke(
                        skillColor,
                        style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: skillColor.opacity(0.5), radius: 2, y: 0)
            }

            // Fire icon with padding
            centerIndicator
                .padding(4)
        }
    }

    @ViewBuilder
    private var centerIndicator: some View {
        if isTracking {
            // Fire icon when tracking
            Image(systemName: isPaused ? "flame" : "flame.fill")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(skillColor)
                .shadow(color: isPaused ? .clear : skillColor.opacity(0.6), radius: 2, y: 0)
        } else {
            // Idle - subtle flame outline
            Image(systemName: "flame")
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(Color.primary.opacity(0.35))
        }
    }

    private var timerText: some View {
        Text(viewModel.elapsedSeconds.formattedTime())
            .font(.system(size: 13, weight: .semibold, design: .monospaced))
            .monospacedDigit()
            .foregroundColor(isPaused ? .secondary : .primary)
    }

    // MARK: - Private Computed Properties

    private var isTracking: Bool {
        viewModel.isTimerRunning
    }

    private var isPaused: Bool {
        viewModel.isTimerRunning && viewModel.isTimerPaused
    }

    private var skillColor: Color {
        viewModel.activeSkill?.color ?? .primary
    }

    private var progressTrim: CGFloat {
        // Show a subtle animated progress based on seconds (completes every minute)
        // This gives visual feedback that tracking is active
        let secondsInMinute = viewModel.elapsedSeconds % 60
        return CGFloat(secondsInMinute) / 60.0
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 20) {
        // Would need mock view model for preview
        Text("Preview requires running app")
    }
    .padding()
}
