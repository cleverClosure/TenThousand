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
        .padding(.vertical, DS.Spacing.lg)
        .onAppear {
            startPulseAnimation()
        }
    }

    // MARK: - View Components

    private var headerSection: some View {
        HStack(spacing: DS.Spacing.md) {
            Circle()
                .fill(skill.color)
                .frame(width: DS.Size.colorDotSmall, height: DS.Size.colorDotSmall)
                .shadow(color: skill.color.opacity(DS.Shadow.elevated.opacity), radius: DS.Shadow.elevated.radius, y: DS.Shadow.elevated.y)

            Text(skill.name)
                .titleFont()
                .foregroundColor(.primary)
                .lineLimit(1)

            Spacer()
        }
        .padding(.horizontal, DS.Spacing.lg)
    }

    private var timerSection: some View {
        VStack(spacing: DS.Spacing.md) {
            // Large timer with skill color glow when active
            Text(viewModel.elapsedSeconds.formattedTime())
                .timerHeroFont()
                .foregroundColor(viewModel.isTimerPaused ? .secondary : .primary)
                .contentTransition(.numericText())
                .animation(.dsQuick, value: viewModel.elapsedSeconds)
                .shadow(
                    color: viewModel.isTimerPaused ? .clear : skill.color.opacity(pulseOpacity),
                    radius: 20,
                    y: 0
                )

            // Status pill
            statusPill
        }
        .padding(.horizontal, DS.Spacing.lg)
    }

    private var statusPill: some View {
        HStack(spacing: DS.Spacing.xs) {
            if !viewModel.isTimerPaused {
                Circle()
                    .fill(skill.color)
                    .frame(width: DS.Size.pulseIndicator, height: DS.Size.pulseIndicator)
                    .opacity(pulseOpacity + 0.5)
            }

            Text(viewModel.isTimerPaused ? "Paused" : "Tracking")
                .font(DS.Font.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(viewModel.isTimerPaused ? .secondary : skill.color)
        .padding(.horizontal, DS.Spacing.md)
        .padding(.vertical, DS.Spacing.xs)
        .background(
            Capsule()
                .fill(viewModel.isTimerPaused
                    ? Color.primary.opacity(DS.Opacity.medium)
                    : skill.color.opacity(DS.Opacity.medium))
        )
    }

    private var controlsSection: some View {
        HStack(spacing: DS.Spacing.md) {
            // Pause/Resume button
            Button {
                if viewModel.isTimerPaused {
                    viewModel.resumeTracking()
                } else {
                    viewModel.pauseTracking()
                }
            } label: {
                HStack(spacing: DS.Spacing.sm) {
                    Image(systemName: viewModel.isTimerPaused ? "play.fill" : "pause.fill")
                        .iconFont(.medium, weight: .semibold)
                    Text(viewModel.isTimerPaused ? "Resume" : "Pause")
                        .font(DS.Font.body)
                        .fontWeight(.medium)
                }
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DS.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DS.Radius.medium)
                        .fill(Color.primary.opacity(DS.Opacity.medium))
                )
            }
            .buttonStyle(PlainButtonStyle())

            // Stop button
            Button {
                withAnimation(.dsStandard) {
                    viewModel.stopTracking()
                }
            } label: {
                HStack(spacing: DS.Spacing.sm) {
                    Image(systemName: "stop.fill")
                        .iconFont(.medium, weight: .semibold)
                    Text("Stop")
                        .font(DS.Font.body)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DS.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DS.Radius.medium)
                        .fill(DS.Color.error)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, DS.Spacing.lg)
        .padding(.bottom, DS.Spacing.lg)
    }

    private var footerSection: some View {
        VStack(spacing: 0) {
            Divider()
            Button {
                withAnimation(.dsStandard) {
                    viewModel.showSkillList()
                }
            } label: {
                HStack(spacing: DS.Spacing.sm) {
                    Image(systemName: "list.bullet")
                        .iconFont(.body)
                    Text("View All Skills")
                        .font(DS.Font.body)
                    Spacer()
                }
                .foregroundColor(.secondary)
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.vertical, DS.Spacing.md)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    // MARK: - Private Methods

    private func startPulseAnimation() {
        guard !viewModel.isTimerPaused else { return }
        withAnimation(
            .easeInOut(duration: DS.Duration.pulse)
            .repeatForever(autoreverses: true)
        ) {
            pulseOpacity = 0.6
        }
    }
}
