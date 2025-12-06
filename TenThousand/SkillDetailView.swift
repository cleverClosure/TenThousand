//
//  SkillDetailView.swift
//  TenThousand
//
//  Author: Tim Isaev
//
//  Detailed view for a skill with mastery progress
//

import SwiftUI

struct SkillDetailView: View {
    // MARK: - Properties

    let skill: Skill
    @ObservedObject var viewModel: AppViewModel

    // MARK: - Private State

    @State private var showingDeleteAlert = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            statsSection
            Spacer()
            footerSection
        }
        .confirmationDialog(
            "Delete Skill?",
            isPresented: $showingDeleteAlert,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                withAnimation(.panelTransition) {
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
        VStack(spacing: Spacing.base) {
            HStack {
                Button {
                    withAnimation(.panelTransition) {
                        viewModel.showSkillList()
                    }
                } label: {
                    HStack(spacing: Spacing.tight) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 11, weight: .medium))
                        Text("Back")
                            .font(Typography.body)
                    }
                    .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()
            }

            HStack(spacing: Spacing.base) {
                Circle()
                    .fill(skill.color)
                    .frame(width: Dimensions.colorDotSize, height: Dimensions.colorDotSize)
                Text(skill.name)
                    .font(Typography.display)
                    .foregroundColor(.primary)
                    .lineLimit(LayoutConstants.skillNameLineLimit)
                Spacer()
            }
        }
        .padding(.horizontal, Spacing.loose)
        .padding(.vertical, Spacing.base)
    }

    private var statsSection: some View {
        VStack(spacing: Spacing.section) {
            // Total hours - the hero metric
            VStack(spacing: Spacing.tight) {
                Text(formattedHours)
                    .font(.system(size: 48, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                Text("of 10,000 hours")
                    .font(Typography.caption)
                    .foregroundColor(.secondary)
            }

            // Progress bar
            VStack(spacing: Spacing.base) {
                ProgressBarView(
                    progress: skill.masteryProgress,
                    color: skill.color,
                    height: 8
                )

                HStack {
                    Text(formattedPercentage)
                        .font(Typography.caption)
                        .foregroundColor(skill.color)
                    Spacer()
                    Text("\(skill.hoursRemaining.formatted()) hours to go")
                        .font(Typography.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, Spacing.loose)

            // Pace projection
            if let projection = skill.projectedTimeToMastery {
                VStack(spacing: Spacing.tight) {
                    Text("At current pace")
                        .font(Typography.caption)
                        .foregroundColor(.secondary)
                    Text(projection.formatted)
                        .font(Typography.body)
                        .foregroundColor(.primary)
                }
                .padding(.top, Spacing.base)
            } else if skill.sessions.isEmpty {
                Text("Start tracking to see your pace")
                    .font(Typography.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, Spacing.base)
            }
        }
        .padding(.vertical, Spacing.base)
    }

    private var footerSection: some View {
        VStack(spacing: 0) {
            // Start tracking button
            PanelButton(
                isSkillActive ? "Currently Tracking" : "Start Tracking",
                icon: isSkillActive ? "checkmark.circle.fill" : "play.fill",
                isDisabled: isSkillActive
            ) {
                viewModel.startTracking(skill: skill)
            }
            .padding(.horizontal, Spacing.base)

            Divider()
                .padding(.vertical, Spacing.base)

            // Delete button
            PanelButton(
                "Delete Skill",
                variant: .destructive,
                isDisabled: isSkillActive
            ) {
                showingDeleteAlert = true
            }
            .padding(.horizontal, Spacing.base)
            .padding(.bottom, Spacing.base)
        }
    }

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
        if skill.masteryPercentage < 0.1 {
            return String(format: "%.2f%%", skill.masteryPercentage)
        } else if skill.masteryPercentage < 1 {
            return String(format: "%.1f%%", skill.masteryPercentage)
        } else {
            return String(format: "%.1f%%", skill.masteryPercentage)
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
}
