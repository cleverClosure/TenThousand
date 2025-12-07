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
            if let projection = skill.projectedTimeToMastery {
                HStack {
                    VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                        Text("AT CURRENT PACE")
                            .labelFont()
                            .foregroundColor(.secondary)
                        Text(projection.formatted)
                            .font(DS.Font.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                }
                .padding(DS.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DS.Radius.medium)
                        .fill(DS.Color.background(.subtle))
                )
            } else if skill.sessions.isEmpty {
                HStack {
                    Text("Start tracking to see your pace")
                        .font(DS.Font.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(DS.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DS.Radius.medium)
                        .fill(DS.Color.background(.subtle))
                )
            }
        }
        .padding(.horizontal, DS.Spacing.lg)
        .padding(.top, DS.Spacing.xl)
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
