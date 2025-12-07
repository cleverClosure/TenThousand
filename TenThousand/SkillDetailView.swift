//
//  SkillDetailView.swift
//  TenThousand
//
//  Author: Tim Isaev
//
//  Detailed view for a skill with mastery progress - featuring circular hero
//

import SwiftUI

struct SkillDetailView: View {
    // MARK: - Properties

    let skill: Skill
    @ObservedObject var viewModel: AppViewModel

    // MARK: - Private State

    @State private var showingDeleteAlert = false

    // MARK: - Private Computed Properties

    private var isSkillActive: Bool {
        viewModel.activeSkill?.id == skill.id
    }

    private var formattedHours: String {
        if skill.totalHours < 1 {
            return String(format: "%.1f", skill.totalHours)
        } else if skill.totalHours < 100 {
            return String(format: "%.1f", skill.totalHours)
        } else {
            return "\(Int(skill.totalHours).formatted())"
        }
    }

    private var formattedPercentage: String {
        let percentage = skill.masteryPercentage
        if percentage < 0.1 {
            return String(format: "%.2f%%", percentage)
        } else if percentage < 1 {
            return String(format: "%.1f%%", percentage)
        } else {
            return String(format: "%.1f%%", percentage)
        }
    }

    private var deleteMessage: String {
        let sessionCount = skill.sessions.count
        let skillName = skill.name

        if sessionCount > 0 {
            return "'\(skillName)' has \(sessionCount) session\(sessionCount == 1 ? "" : "s"). Deleting will permanently remove all session data."
        } else {
            return "Are you sure you want to delete '\(skillName)'?"
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            heroSection
            statsSection
            Spacer(minLength: DS.Spacing.lg)
            footerSection
        }
        .confirmationDialog(
            "Delete Skill?",
            isPresented: $showingDeleteAlert,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                withAnimation(.dsStandard) {
                    viewModel.deleteSkill(skill)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(deleteMessage)
        }
    }

    // MARK: - View Components

    private var headerSection: some View {
        HStack {
            Button {
                withAnimation(.dsStandard) {
                    viewModel.showSkillList()
                }
            } label: {
                HStack(spacing: DS.Spacing.xs) {
                    Image(systemName: "chevron.left")
                        .iconFont(.body, weight: .semibold)
                    Text("Back")
                        .font(DS.Font.body)
                }
                .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()
        }
        .padding(.horizontal, DS.Spacing.lg)
        .padding(.top, DS.Spacing.md)
        .padding(.bottom, DS.Spacing.sm)
    }

    private var heroSection: some View {
        VStack(spacing: DS.Spacing.lg) {
            // Skill name with color dot
            HStack(spacing: DS.Spacing.md) {
                Circle()
                    .fill(skill.color)
                    .frame(width: DS.Size.colorDotSmall, height: DS.Size.colorDotSmall)
                    .shadow(color: skill.color.opacity(DS.Shadow.elevated.opacity), radius: DS.Shadow.elevated.radius, y: DS.Shadow.elevated.y)

                Text(skill.name)
                    .titleFont()
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }

            // Circular progress hero
            CircularProgressView(
                progress: skill.masteryProgress,
                color: skill.color,
                valueText: formattedHours,
                labelText: "HOURS"
            )
        }
        .padding(.horizontal, DS.Spacing.lg)
    }

    private var statsSection: some View {
        VStack(spacing: DS.Spacing.lg) {
            // Progress bar with stats
            VStack(spacing: DS.Spacing.sm) {
                ProgressBarView(
                    progress: skill.masteryProgress,
                    color: skill.color,
                    height: 10
                )

                HStack {
                    Text(formattedPercentage)
                        .font(DS.Font.body)
                        .fontWeight(.medium)
                        .foregroundColor(skill.color)

                    Spacer()

                    Text("\(skill.hoursRemaining.formatted()) to go")
                        .font(DS.Font.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Pace projection
            paceProjectionSection
        }
        .padding(.horizontal, DS.Spacing.lg)
        .padding(.top, DS.Spacing.xl)
    }

    @ViewBuilder
    private var paceProjectionSection: some View {
        let projection = skill.smartProjection

        switch projection.confidence {
        case .insufficient:
            if skill.sessions.isEmpty {
                paceCard {
                    Text("Start tracking to see your pace")
                        .font(DS.Font.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                paceCard {
                    Text("Keep practicing to see projection")
                        .font(DS.Font.caption)
                        .foregroundColor(.secondary)
                }
            }

        case .low, .medium, .high:
            paceCard {
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    // Header with mode indicator
                    HStack {
                        Text(projection.mode == .targetBased ? "AT TARGET PACE" : "AT CURRENT PACE")
                            .labelFont()
                            .foregroundColor(.secondary)

                        Spacer()

                        // Trend indicator
                        if !projection.trendArrow.isEmpty {
                            HStack(spacing: DS.Spacing.xs) {
                                Text(projection.trendArrow)
                                    .font(DS.Font.caption)
                                Text(projection.trendDescription)
                                    .font(DS.Font.caption)
                            }
                            .foregroundColor(trendColor(for: projection.trend))
                        }
                    }

                    // Projection value
                    Text(projection.formatted)
                        .font(DS.Font.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    // Show actual vs target for target mode
                    if projection.mode == .targetBased, let gap = skill.targetPaceGap {
                        let actualPace = skill.actualRecentPace
                        HStack(spacing: DS.Spacing.xs) {
                            Text("Actual:")
                                .font(DS.Font.caption)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.1f hrs/week", actualPace))
                                .font(DS.Font.caption)
                                .fontWeight(.medium)
                                .foregroundColor(gap >= 0 ? .green : DS.Color.error)
                            Text(gap >= 0 ? "(ahead)" : "(behind)")
                                .font(DS.Font.caption)
                                .foregroundColor(gap >= 0 ? .green : DS.Color.error)
                        }
                    }
                }
            }
        }
    }

    private func paceCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack {
            content()
            Spacer()
        }
        .padding(DS.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.medium)
                .fill(DS.Color.background(.subtle))
        )
    }

    private func trendColor(for trend: PaceTrend) -> Color {
        switch trend {
        case .increasing: return .green
        case .steady: return .secondary
        case .decreasing: return DS.Color.error
        case .unknown: return .secondary
        }
    }

    private var footerSection: some View {
        VStack(spacing: DS.Spacing.sm) {
            // Start tracking button - prominent
            Button {
                viewModel.startTracking(skill: skill)
            } label: {
                HStack(spacing: DS.Spacing.sm) {
                    Image(systemName: isSkillActive ? "checkmark.circle.fill" : "play.fill")
                        .iconFont(.large, weight: .semibold)
                    Text(isSkillActive ? "Currently Tracking" : "Start Tracking")
                        .font(DS.Font.body)
                        .fontWeight(.semibold)
                }
                .foregroundColor(isSkillActive ? .secondary : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DS.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DS.Radius.medium)
                        .fill(isSkillActive ? DS.Color.background(.medium) : skill.color)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isSkillActive)

            // Delete button - subtle
            Button {
                showingDeleteAlert = true
            } label: {
                Text("Delete Skill")
                    .font(DS.Font.caption)
                    .foregroundColor(isSkillActive ? .secondary.opacity(DS.Opacity.muted) : DS.Color.error.opacity(DS.Opacity.accent))
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isSkillActive)
        }
        .padding(.horizontal, DS.Spacing.lg)
        .padding(.bottom, DS.Spacing.lg)
    }
}
