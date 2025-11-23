//
//  DropdownPanelView.swift
//  TenThousand
//
//  Main dropdown panel combining all components
//

import AppKit
import SwiftUI

// MARK: - DropdownPanelView

struct DropdownPanelView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Private State

    @State private var selectedSkillIndex: Int?
    @State private var skillToDelete: Skill?
    @State private var showingDeleteAlert = false
    @FocusState private var isPanelFocused: Bool

    // MARK: - Body

    var body: some View {
        styledContent
            .withKeyboardHandlers(KeyboardHandlerConfig(
                viewModel: viewModel,
                isPanelFocused: $isPanelFocused,
                dismiss: dismiss,
                handleReturnKey: handleReturnKey,
                navigateUp: navigateUp,
                navigateDown: navigateDown,
                handleQuickSwitch: handleQuickSwitch
            ))
            .alert(isPresented: $showingDeleteAlert) {
                deleteConfirmationAlert
            }
    }

    // MARK: - View Components

    private var styledContent: some View {
        mainContent
            .frame(width: Dimensions.panelWidth)
            .background(backgroundView)
            .clipShape(RoundedRectangle(cornerRadius: Dimensions.panelCornerRadius))
            .overlay(overlayBorder)
            .shadow(
                color: shadowColor,
                radius: Shadows.floating.radius,
                x: Shadows.floating.xOffset,
                y: Shadows.floating.yOffset
            )
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            if let selectedSkill = viewModel.selectedSkillForDetail {
                skillDetailSection(skill: selectedSkill)
            } else {
                skillListSection
                Divider()
                quitButton
            }
        }
    }

    @ViewBuilder
    private func skillDetailSection(skill: Skill) -> some View {
        SkillDetailView(skill: skill, viewModel: viewModel)
            .transition(.opacity.combined(with: .move(edge: .trailing)))
    }

    private var skillListSection: some View {
        ScrollView {
            VStack(spacing: Spacing.tight) {
                skillRows
                AddSkillView(existingSkillNames: existingSkillNames) { name in
                    viewModel.createSkill(name: name)
                }
            }
            .padding(Spacing.base)
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
                        viewModel.selectedSkillForDetail = skill
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
        Button {
            NSApplication.shared.terminate(nil)
        } label: {
            HStack {
                Image(systemName: "xmark.circle")
                    .font(.system(size: Dimensions.iconSizeSmall))
                    .foregroundColor(.secondary)

                Text("Quit")
                    .font(Typography.body)
                    .foregroundColor(.secondary)

                Spacer()

                Text("⌘Q")
                    .font(Typography.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, Spacing.base)
            .padding(.vertical, Spacing.tight)
            .frame(height: Dimensions.skillRowHeight)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var backgroundView: some View {
        VisualEffectBlur(material: .menu, blendingMode: .behindWindow)
    }

    private var overlayBorder: some View {
        RoundedRectangle(cornerRadius: Dimensions.panelCornerRadius)
            .stroke(Color.primary.opacity(Opacity.backgroundMedium), lineWidth: LayoutConstants.borderWidth)
    }

    // MARK: - Private Computed Properties

    private var shadowColor: Color {
        Color.black.opacity(Shadows.floating.opacity)
    }

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
                viewModel.selectedSkillForDetail = skill
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
        if let index = KeyboardShortcuts.numberKeys.firstIndex(of: press.key),
           index < viewModel.skills.count {
            let skill = viewModel.skills[index]
            withAnimation(.panelTransition) {
                viewModel.selectedSkillForDetail = skill
            }
            return true
        }
        return false
    }
}

// MARK: - Keyboard Shortcuts

private enum KeyboardShortcuts {
    static let numberKeys: [KeyEquivalent] = [
        KeyEquivalent("1"), KeyEquivalent("2"), KeyEquivalent("3"),
        KeyEquivalent("4"), KeyEquivalent("5"), KeyEquivalent("6"),
        KeyEquivalent("7"), KeyEquivalent("8"), KeyEquivalent("9")
    ]
    static let quit = KeyEquivalent("q")
}

// MARK: - Keyboard Handler Configuration

private struct KeyboardHandlerConfig {
    let viewModel: AppViewModel
    let isPanelFocused: FocusState<Bool>.Binding
    let dismiss: DismissAction
    let handleReturnKey: () -> Bool
    let navigateUp: () -> Void
    let navigateDown: () -> Void
    let handleQuickSwitch: (KeyPress) -> Bool
}

// MARK: - Keyboard Handlers Extension

private extension View {
    func withKeyboardHandlers(_ config: KeyboardHandlerConfig) -> some View {
        self
            .focusable()
            .focusEffectDisabled()
            .focused(config.isPanelFocused)
            .onAppear {
                config.isPanelFocused.wrappedValue = true
            }
            .withNavigationKeys(
                handleReturnKey: config.handleReturnKey,
                navigateUp: config.navigateUp,
                navigateDown: config.navigateDown
            )
            .withNumberKeys(handleQuickSwitch: config.handleQuickSwitch)
            .withCommandKeys(viewModel: config.viewModel, dismiss: config.dismiss)
    }

    private func withNavigationKeys(
        handleReturnKey: @escaping () -> Bool,
        navigateUp: @escaping () -> Void,
        navigateDown: @escaping () -> Void
    ) -> some View {
        self
            .onKeyPress(.return) {
                return handleReturnKey() ? .handled : .ignored
            }
            .onKeyPress(.upArrow) {
                navigateUp()
                return .handled
            }
            .onKeyPress(.downArrow) {
                navigateDown()
                return .handled
            }
    }

    private func withNumberKeys(
        handleQuickSwitch: @escaping (KeyPress) -> Bool
    ) -> some View {
        var view = AnyView(self)
        for numberKey in KeyboardShortcuts.numberKeys {
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

    private func withCommandKeys(
        viewModel: AppViewModel,
        dismiss: DismissAction
    ) -> some View {
        self
            .onKeyPress(keys: [KeyboardShortcuts.quit], phases: .down) { press in
                if press.modifiers.contains(.command) {
                    NSApplication.shared.terminate(nil)
                    return .handled
                }
                return .ignored
            }
            .onCommand(#selector(NSResponder.cancelOperation(_:))) {
                dismiss()
            }
    }
}

// MARK: - Visual Effect Blur

struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
