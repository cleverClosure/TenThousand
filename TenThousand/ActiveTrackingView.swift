//
//  ActiveTrackingView.swift
//  TenThousand
//
//  Author: Tim Isaev
//
//  View displayed when a skill is actively being tracked
//

import SwiftUI

// MARK: - ActiveTrackingView

struct ActiveTrackingView: View {
    // MARK: - Properties

    let skill: Skill
    @ObservedObject var viewModel: AppViewModel

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            Spacer()
            timerSection
            Spacer()
            controlsSection
            Divider()
                .padding(.top, Spacing.base)
            footerSection
        }
        .padding(.vertical, Spacing.base)
    }

    // MARK: - View Components

    private var headerSection: some View {
        HStack(spacing: Spacing.base) {
            skillColorDot
            skillNameLabel
            Spacer()
        }
        .padding(.horizontal, Spacing.loose)
        .padding(.vertical, Spacing.base)
    }

    private var skillColorDot: some View {
        Circle()
            .fill(skill.color)
            .frame(width: Dimensions.colorDotSize, height: Dimensions.colorDotSize)
    }

    private var skillNameLabel: some View {
        Text(skill.name)
            .font(Typography.display)
            .foregroundColor(.primary)
            .lineLimit(LayoutConstants.skillNameLineLimit)
    }

    private var timerSection: some View {
        VStack(spacing: Spacing.tight) {
            timerDisplay
            statusLabel
        }
        .padding(.horizontal, Spacing.loose)
    }

    private var timerDisplay: some View {
        Text(viewModel.elapsedSeconds.formattedTime())
            .font(.system(size: 48, weight: .medium, design: .monospaced))
            .monospacedDigit()
            .foregroundColor(.primary)
            .contentTransition(.numericText())
            .animation(.microInteraction, value: viewModel.elapsedSeconds)
    }

    private var statusLabel: some View {
        Group {
            if viewModel.isTimerPaused {
                Text("Paused")
                    .foregroundColor(.secondary)
            } else {
                Text("Tracking")
                    .foregroundColor(skill.color)
            }
        }
        .font(Typography.caption)
    }

    private var controlsSection: some View {
        HStack(spacing: Spacing.base) {
            pauseResumeButton
            stopButton
        }
        .padding(.horizontal, Spacing.loose)
    }

    private var pauseResumeButton: some View {
        Button {
            if viewModel.isTimerPaused {
                viewModel.resumeTracking()
            } else {
                viewModel.pauseTracking()
            }
        } label: {
            HStack(spacing: Spacing.tight) {
                Image(systemName: viewModel.isTimerPaused ? "play.fill" : "pause.fill")
                    .font(.system(size: Dimensions.iconSizeSmall))
                Text(viewModel.isTimerPaused ? "Resume" : "Pause")
                    .font(Typography.body)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.base)
            .background(Color.primary.opacity(Opacity.backgroundMedium))
            .clipShape(RoundedRectangle(cornerRadius: Dimensions.cornerRadiusSmall))
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var stopButton: some View {
        Button {
            withAnimation(.panelTransition) {
                viewModel.stopTracking()
            }
        } label: {
            HStack(spacing: Spacing.tight) {
                Image(systemName: "stop.fill")
                    .font(.system(size: Dimensions.iconSizeSmall))
                Text("Stop")
                    .font(Typography.body)
            }
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.base)
            .background(Color.red.opacity(Opacity.backgroundMedium))
            .clipShape(RoundedRectangle(cornerRadius: Dimensions.cornerRadiusSmall))
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var footerSection: some View {
        PanelButton(
            "View All Skills",
            icon: "list.bullet",
            alignment: .leading
        ) {
            withAnimation(.panelTransition) {
                viewModel.showSkillList()
            }
        }
        .padding(.horizontal, Spacing.base)
    }

}
