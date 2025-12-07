//
//  ActiveTrackingView.swift
//  TenThousand
//
//  Author: Tim Isaev
//
//  View displayed when a skill is actively being tracked - bold timer display
//

import SwiftUI

// MARK: - ActiveTrackingView

struct ActiveTrackingView: View {
    // MARK: - Properties

    let skill: Skill
    @ObservedObject var viewModel: AppViewModel

    // MARK: - Private State

    @State private var pulseOpacity: Double = 0.3

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            Spacer()
            timerSection
            Spacer()
            controlsSection
            footerSection
        }
        .padding(.vertical, Spacing.section)
        .onAppear {
            startPulseAnimation()
        }
    }

    // MARK: - View Components

    private var headerSection: some View {
        HStack(spacing: Spacing.compact) {
            Circle()
                .fill(skill.color)
                .frame(width: Dimensions.colorDotSizeSmall, height: Dimensions.colorDotSizeSmall)
                .shadow(color: skill.color.opacity(Shadows.small.opacity), radius: Shadows.small.radius, y: Shadows.small.yOffset)

            Text(skill.name)
                .titleFont()
                .foregroundColor(.primary)
                .lineLimit(LayoutConstants.skillNameLineLimit)

            Spacer()
        }
        .padding(.horizontal, Spacing.section)
    }

    private var timerSection: some View {
        VStack(spacing: Spacing.loose) {
            // Large timer with skill color glow when active
            Text(viewModel.elapsedSeconds.formattedTime())
                .heroTimerFont()
                .foregroundColor(viewModel.isTimerPaused ? .secondary : .primary)
                .contentTransition(.numericText())
                .animation(.microInteraction, value: viewModel.elapsedSeconds)
                .shadow(
                    color: viewModel.isTimerPaused ? .transparent : skill.color.opacity(pulseOpacity),
                    radius: Shadows.timerGlow.radius,
                    y: Shadows.timerGlow.yOffset
                )

            // Status pill
            statusPill
        }
        .padding(.horizontal, Spacing.section)
    }

    private var statusPill: some View {
        HStack(spacing: Spacing.tight) {
            if !viewModel.isTimerPaused {
                Circle()
                    .fill(skill.color)
                    .frame(width: Dimensions.pulseIndicatorSize, height: Dimensions.pulseIndicatorSize)
                    .opacity(pulseOpacity + 0.5)
            }

            Text(viewModel.isTimerPaused ? "Paused" : "Tracking")
                .font(Typography.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(viewModel.isTimerPaused ? .secondary : skill.color)
        .padding(.horizontal, Spacing.loose)
        .padding(.vertical, Spacing.tight)
        .background(
            Capsule()
                .fill(viewModel.isTimerPaused
                    ? Color.backgroundSecondary(.intense)
                    : skill.color.opacity(0.1))
        )
    }

    private var controlsSection: some View {
        HStack(spacing: Spacing.loose) {
            // Pause/Resume button
            Button {
                if viewModel.isTimerPaused {
                    viewModel.resumeTracking()
                } else {
                    viewModel.pauseTracking()
                }
            } label: {
                HStack(spacing: Spacing.base) {
                    Image(systemName: viewModel.isTimerPaused ? "play.fill" : "pause.fill")
                        .iconFont(.medium, weight: .semibold)
                    Text(viewModel.isTimerPaused ? "Resume" : "Pause")
                        .font(Typography.body)
                        .fontWeight(.medium)
                }
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.loose)
                .background(
                    RoundedRectangle(cornerRadius: Dimensions.cornerRadiusMedium)
                        .fill(Color.backgroundPrimary(.regular))
                )
            }
            .buttonStyle(PlainButtonStyle())

            // Stop button
            Button {
                withAnimation(.panelTransition) {
                    viewModel.stopTracking()
                }
            } label: {
                HStack(spacing: Spacing.base) {
                    Image(systemName: "stop.fill")
                        .iconFont(.medium, weight: .semibold)
                    Text("Stop")
                        .font(Typography.body)
                        .fontWeight(.medium)
                }
                .foregroundColor(.buttonTextLight)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.loose)
                .background(
                    RoundedRectangle(cornerRadius: Dimensions.cornerRadiusMedium)
                        .fill(Color.stateError)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, Spacing.section)
        .padding(.bottom, Spacing.section)
    }

    private var footerSection: some View {
        VStack(spacing: 0) {
            Divider()
            Button {
                withAnimation(.panelTransition) {
                    viewModel.showSkillList()
                }
            } label: {
                HStack(spacing: Spacing.base) {
                    Image(systemName: "list.bullet")
                        .iconFont(.body)
                    Text("View All Skills")
                        .font(Typography.body)
                    Spacer()
                }
                .foregroundColor(.secondary)
                .padding(.horizontal, Spacing.section)
                .padding(.vertical, Spacing.loose)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    // MARK: - Private Methods

    private func startPulseAnimation() {
        guard !viewModel.isTimerPaused else { return }
        withAnimation(
            .easeInOut(duration: AnimationDurations.pulse)
            .repeatForever(autoreverses: true)
        ) {
            pulseOpacity = 0.6
        }
    }
}
