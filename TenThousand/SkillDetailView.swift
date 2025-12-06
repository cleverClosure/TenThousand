//
//  SkillDetailView.swift
//  TenThousand
//
//  Detailed view for a skill
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
            Spacer()
            deleteButton
        }
        .frame(width: Dimensions.panelWidth)
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
                        .font(.system(size: 11, weight: .medium))
                    Text("Back")
                        .font(Typography.body)
                }
                .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()
        }
        .padding(.horizontal, Spacing.loose)
        .padding(.vertical, Spacing.base)
    }

    private var deleteButton: some View {
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

    // MARK: - Private Computed Properties

    private var isSkillActive: Bool {
        viewModel.activeSkill?.id == skill.id
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
