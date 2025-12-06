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
            Spacer(minLength: Spacing.section)
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
        HStack {
            Button {
                withAnimation(.panelTransition) {
                    viewModel.showSkillList()
                }
            } label: {
                HStack(spacing: Spacing.tight) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Back")
                        .font(Typography.body)
                }
                .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()
        }
        .padding(.horizontal, Spacing.section)
        .padding(.top, Spacing.loose)
        .padding(.bottom, Spacing.base)
    }

    private var heroSection: some View {
        VStack(spacing: Spacing.section) {
            // Skill name with color dot
            HStack(spacing: Spacing.compact) {
                Circle()
                    .fill(skill.color)
                    .frame(width: Dimensions.colorDotSizeSmall, height: Dimensions.colorDotSizeSmall)
                    .shadow(color: skill.color.opacity(0.5), radius: 3, y: 1)

                Text(skill.name)
                    .titleFont()
                    .foregroundColor(.primary)
                    .lineLimit(LayoutConstants.skillNameLineLimit)
            }

            // Circular progress hero
            CircularProgressView(
                progress: skill.masteryProgress,
                color: skill.color,
                valueText: formattedHours,
                labelText: "HOURS"
            )
        }
        .padding(.horizontal, Spacing.section)
    }

    private var statsSection: some View {
        VStack(spacing: Spacing.section) {
            // Progress bar with stats
            VStack(spacing: Spacing.base) {
                ProgressBarView(
                    progress: skill.masteryProgress,
                    color: skill.color,
                    height: Dimensions.progressBarHeightLarge
                )

                HStack {
                    Text(formattedPercentage)
                        .font(Typography.body)
                        .fontWeight(.medium)
                        .foregroundColor(skill.color)

                    Spacer()

                    Text("\(skill.hoursRemaining.formatted()) to go")
                        .font(Typography.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Pace projection
            if let projection = skill.projectedTimeToMastery {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.atomic) {
                        Text("AT CURRENT PACE")
                            .labelFont()
                            .foregroundColor(.secondary)
                        Text(projection.formatted)
                            .font(Typography.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                }
                .padding(Spacing.loose)
                .background(
                    RoundedRectangle(cornerRadius: Dimensions.cornerRadiusMedium)
                        .fill(Color.primary.opacity(0.03))
                )
            } else if skill.sessions.isEmpty {
                HStack {
                    Text("Start tracking to see your pace")
                        .font(Typography.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(Spacing.loose)
                .background(
                    RoundedRectangle(cornerRadius: Dimensions.cornerRadiusMedium)
                        .fill(Color.primary.opacity(0.03))
                )
            }
        }
        .padding(.horizontal, Spacing.section)
        .padding(.top, Spacing.comfortable)
    }

    private var footerSection: some View {
        VStack(spacing: Spacing.base) {
            // Start tracking button - prominent
            Button {
                viewModel.startTracking(skill: skill)
            } label: {
                HStack(spacing: Spacing.base) {
                    Image(systemName: isSkillActive ? "checkmark.circle.fill" : "play.fill")
                        .font(.system(size: 16, weight: .semibold))
                    Text(isSkillActive ? "Currently Tracking" : "Start Tracking")
                        .font(Typography.body)
                        .fontWeight(.semibold)
                }
                .foregroundColor(isSkillActive ? .secondary : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.loose)
                .background(
                    RoundedRectangle(cornerRadius: Dimensions.cornerRadiusMedium)
                        .fill(isSkillActive ? Color.primary.opacity(0.05) : skill.color)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isSkillActive)

            // Delete button - subtle
            Button {
                showingDeleteAlert = true
            } label: {
                Text("Delete Skill")
                    .font(Typography.caption)
                    .foregroundColor(isSkillActive ? .secondary.opacity(0.5) : .red.opacity(0.8))
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isSkillActive)
        }
        .padding(.horizontal, Spacing.section)
        .padding(.bottom, Spacing.section)
    }
}
