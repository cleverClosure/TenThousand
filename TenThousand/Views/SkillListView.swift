//
//  SkillListView.swift
//  TenThousand
//
//  Author: Tim Isaev
//
//  Main skill list view with add skill functionality
//

import SwiftUI

// MARK: - SkillListView

struct SkillListView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: AppViewModel

    // MARK: - Private State

    @State private var selectedSkillIndex: Int?
    @State private var skillToDelete: Skill?
    @State private var showingDeleteAlert = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            skillListContent
            Divider()
            quitButton
        }
        .alert(isPresented: $showingDeleteAlert) {
            deleteConfirmationAlert
        }
        .onKeyPress(.return) {
            handleReturnKey() ? .handled : .ignored
        }
        .onKeyPress(.upArrow) {
            navigateUp()
            return .handled
        }
        .onKeyPress(.downArrow) {
            navigateDown()
            return .handled
        }
        .withNumberKeyNavigation(handleQuickSwitch: handleQuickSwitch)
    }

    // MARK: - View Components

    private var skillListContent: some View {
        ScrollView {
            VStack(spacing: Spacing.compact) {
                skillRows
                AddSkillView(existingSkillNames: existingSkillNames) { name in
                    viewModel.createSkill(name: name)
                }
            }
            .padding(.horizontal, Spacing.loose)
            .padding(.vertical, Spacing.section)
        }
        .scrollIndicators(.hidden)
        .frame(maxHeight: LayoutConstants.maxSkillListHeight)
        .focusEffectDisabled()
    }

    private var skillRows: some View {
        ForEach(Array(viewModel.skills.enumerated()), id: \.element.id) { index, skill in
            SkillRowView(
                skill: skill,
                onTap: {
                    withAnimation(.panelTransition) {
                        viewModel.showSkillDetail(skill)
                    }
                },
                isSelected: selectedSkillIndex == index,
                isHighlighted: viewModel.justUpdatedSkillId == skill.id,
                canDelete: viewModel.activeSkill?.id != skill.id,
                onDelete: {
                    handleDeleteSkill(skill)
                },
                onStartTracking: {
                    viewModel.startTracking(skill: skill)
                }
            )
        }
    }

    private var quitButton: some View {
        PanelButton(
            "Quit",
            icon: "xmark.circle",
            alignment: .leading,
            shortcut: "⌘Q"
        ) {
            NSApplication.shared.terminate(nil)
        }
        .padding(.horizontal, Spacing.loose)
        .padding(.vertical, Spacing.tight)
    }

    // MARK: - Private Computed Properties

    private var existingSkillNames: [String] {
        viewModel.skills.compactMap { $0.name }
    }

    private var deleteConfirmationAlert: Alert {
        guard let skill = skillToDelete else {
            return Alert(title: Text("Error"))
        }

        let sessionCount = skill.sessions.count
        let skillName = skill.name

        let message: String
        if sessionCount > 0 {
            message = "'\(skillName)' has \(sessionCount) session\(sessionCount == 1 ? "" : "s"). Deleting will permanently remove all session data."
        } else {
            message = "Are you sure you want to delete '\(skillName)'?"
        }

        return Alert(
            title: Text("Delete Skill?"),
            message: Text(message),
            primaryButton: .destructive(Text("Delete")) {
                if let skillToDelete = skillToDelete {
                    withAnimation(.panelTransition) {
                        viewModel.deleteSkill(skillToDelete)
                    }
                }
            },
            secondaryButton: .cancel()
        )
    }

    // MARK: - Private Methods

    private func handleDeleteSkill(_ skill: Skill) {
        if let activeSkill = viewModel.activeSkill, activeSkill.id == skill.id {
            return
        }
        skillToDelete = skill
        showingDeleteAlert = true
    }

    @discardableResult
    private func handleReturnKey() -> Bool {
        if let index = selectedSkillIndex, index < viewModel.skills.count {
            let skill = viewModel.skills[index]
            withAnimation(.panelTransition) {
                viewModel.showSkillDetail(skill)
            }
            selectedSkillIndex = nil
            return true
        }
        return false
    }

    private func navigateUp() {
        if let current = selectedSkillIndex {
            if current > 0 {
                selectedSkillIndex = current - 1
            }
        } else {
            selectedSkillIndex = viewModel.skills.count - 1
        }
    }

    private func navigateDown() {
        if let current = selectedSkillIndex {
            if current < viewModel.skills.count - 1 {
                selectedSkillIndex = current + 1
            }
        } else {
            selectedSkillIndex = 0
        }
    }

    private func handleQuickSwitch(_ press: KeyPress) -> Bool {
        if let index = SkillListKeyboardShortcuts.numberKeys.firstIndex(of: press.key),
           index < viewModel.skills.count {
            let skill = viewModel.skills[index]
            withAnimation(.panelTransition) {
                viewModel.showSkillDetail(skill)
            }
            return true
        }
        return false
    }
}

// MARK: - Keyboard Shortcuts

private enum SkillListKeyboardShortcuts {
    static let numberKeys: [KeyEquivalent] = [
        KeyEquivalent("1"), KeyEquivalent("2"), KeyEquivalent("3"),
        KeyEquivalent("4"), KeyEquivalent("5"), KeyEquivalent("6"),
        KeyEquivalent("7"), KeyEquivalent("8"), KeyEquivalent("9")
    ]
}

// MARK: - Number Key Navigation Extension

private extension View {
    func withNumberKeyNavigation(
        handleQuickSwitch: @escaping (KeyPress) -> Bool
    ) -> some View {
        var view = AnyView(self)
        for numberKey in SkillListKeyboardShortcuts.numberKeys {
            view = AnyView(
                view.onKeyPress(keys: [numberKey], phases: .down) { press in
                    if press.modifiers.contains(.command) {
                        return handleQuickSwitch(press) ? .handled : .ignored
                    }
                    return .ignored
                }
            )
        }
        return view
    }
}
