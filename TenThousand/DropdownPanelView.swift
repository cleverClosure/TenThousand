//
//  DropdownPanelView.swift
//  TenThousand
//
//  Main dropdown panel combining all components
//

import SwiftUI
import AppKit

// MARK: - Constants

private enum KeyboardShortcuts {
    static let numberKeys: [KeyEquivalent] = [
        KeyEquivalent("1"), KeyEquivalent("2"), KeyEquivalent("3"),
        KeyEquivalent("4"), KeyEquivalent("5"), KeyEquivalent("6"),
        KeyEquivalent("7"), KeyEquivalent("8"), KeyEquivalent("9")
    ]

    static let addSkill = KeyEquivalent("n")
    static let stopTracking = KeyEquivalent(".")
    static let quit = KeyEquivalent("q")
}

struct DropdownPanelView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @AppStorage("showMenuBarTimer") private var showMenuBarTimer = true
    @State private var selectedSkillIndex: Int? = nil
    @FocusState private var isPanelFocused: Bool
    @State private var skillToDelete: Skill? = nil
    @State private var showingDeleteAlert = false

    var body: some View {
        styledContent
            .withKeyboardHandlers(
                viewModel: viewModel,
                isPanelFocused: $isPanelFocused,
                dismiss: dismiss,
                handleSpaceKey: handleSpaceKey,
                handleReturnKey: handleReturnKey,
                navigateUp: navigateUp,
                navigateDown: navigateDown,
                handleQuickSwitch: handleQuickSwitch
            )
            .alert(isPresented: $showingDeleteAlert) {
                deleteConfirmationAlert
            }
    }

    private var styledContent: some View {
        mainContent
            .frame(width: Dimensions.panelWidth)
            .background(backgroundView)
            .clipShape(RoundedRectangle(cornerRadius: Dimensions.panelCornerRadius))
            .overlay(overlayBorder)
            .shadow(
                color: shadowColor,
                radius: Shadows.floating.radius,
                x: Shadows.floating.x,
                y: Shadows.floating.y
            )
    }

    // MARK: - View Components

    private var mainContent: some View {
        VStack(spacing: 0) {
            // Priority: Detail view > Active session > Skill list
            if let selectedSkill = viewModel.selectedSkillForDetail {
                skillDetailSection(skill: selectedSkill)
            } else {
                activeSessionSection
                skillListSection

                Divider()

                TodaysSummaryView(
                    totalSeconds: viewModel.todaysTotalSeconds(),
                    skillCount: viewModel.todaysSkillCount()
                )

                Divider()

                GoalProgressView(viewModel: viewModel)

                Divider()

                settingsSection

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

    @ViewBuilder
    private var activeSessionSection: some View {
        if let activeSkill = viewModel.activeSkill {
            ActiveSessionView(
                skill: activeSkill,
                timerManager: viewModel.timerManager,
                onPause: {
                    viewModel.pauseTracking()
                },
                onResume: {
                    viewModel.resumeTracking()
                },
                onStop: {
                    withAnimation(.panelTransition) {
                        viewModel.stopTracking()
                    }
                }
            )
            .padding(Spacing.base)
            .transition(.opacity.combined(with: .scale(scale: ScaleValues.dismissScale)))
        }
    }

    @ViewBuilder
    private var skillListSection: some View {
        if viewModel.activeSkill == nil {
            ScrollView {
                VStack(spacing: Spacing.tight) {
                    addSkillSection
                    skillRows
                    addSkillButton
                }
                .padding(Spacing.base)
            }
            .frame(maxHeight: LayoutConstants.maxSkillListHeight)
        }
    }

    @ViewBuilder
    private var addSkillSection: some View {
        if viewModel.isAddingSkill {
            AddSkillView(
                isActive: $viewModel.isAddingSkill,
                existingSkillNames: existingSkillNames,
                onCreate: { name in
                    viewModel.createSkill(name: name)
                }
            )
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    private var skillRows: some View {
        ForEach(Array(viewModel.skills.enumerated()), id: \.element.id) { index, skill in
            SkillRowView(
                skill: skill,
                isSelected: selectedSkillIndex == index,
                isHighlighted: viewModel.justUpdatedSkillId == skill.id,
                canDelete: viewModel.activeSkill?.id != skill.id,
                onTap: {
                    withAnimation(.panelTransition) {
                        viewModel.selectedSkillForDetail = skill
                    }
                },
                onDelete: {
                    handleDeleteSkill(skill)
                },
                onStartTracking: {
                    viewModel.startTracking(skill: skill)
                }
            )
        }
    }

    @ViewBuilder
    private var addSkillButton: some View {
        if !viewModel.isAddingSkill {
            Button(action: {
                withAnimation(.microInteraction) {
                    viewModel.isAddingSkill = true
                }
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                        .font(.system(size: Dimensions.iconSizeSmall))
                        .foregroundColor(.secondary)

                    Text(UIText.addSkillLabel)
                        .font(Typography.body)
                        .foregroundColor(.secondary)

                    Spacer()
                }
                .padding(.horizontal, Dimensions.skillRowPaddingHorizontal)
                .padding(.vertical, Dimensions.skillRowPaddingVertical)
                .frame(height: Dimensions.skillRowHeight)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private var settingsSection: some View {
        VStack(spacing: 0) {
            // Goal Settings
            GoalSettingsView(viewModel: viewModel)

            Divider()

            // Open Heatmap Visualization button
            Button(action: {
                HeatmapWindowController.shared.openHeatmapWindow(viewModel: viewModel)
            }) {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: Dimensions.iconSizeSmall))
                        .foregroundColor(.secondary)

                    Text("Heatmap Visualization")
                        .font(Typography.body)
                        .foregroundColor(.primary)

                    Spacer()

                    Image(systemName: "arrow.up.forward.square")
                        .font(.system(size: Dimensions.iconSizeSmall))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, Spacing.base)
                .padding(.vertical, Spacing.tight)
                .frame(height: Dimensions.skillRowHeight)
            }
            .buttonStyle(PlainButtonStyle())

            Divider()

            // Show Timer in Menu Bar toggle
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: Dimensions.iconSizeSmall))
                    .foregroundColor(.secondary)

                Text("Show Timer in Menu Bar")
                    .font(Typography.body)
                    .foregroundColor(.primary)

                Spacer()

                Toggle("", isOn: $showMenuBarTimer)
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .controlSize(.small)
            }
            .padding(.horizontal, Spacing.base)
            .padding(.vertical, Spacing.tight)
            .frame(height: Dimensions.skillRowHeight)
        }
    }

    private var quitButton: some View {
        Button(action: {
            NSApplication.shared.terminate(nil)
        }) {
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

    private var shadowColor: Color {
        Color.black.opacity(Shadows.floating.opacity)
    }

    private var existingSkillNames: [String] {
        viewModel.skills.compactMap { $0.name }
    }

    // MARK: - Delete Functionality

    private var deleteConfirmationAlert: Alert {
        guard let skill = skillToDelete else {
            return Alert(title: Text("Error"))
        }

        let sessionCount = (skill.sessions as? Set<Session>)?.count ?? 0
        let skillName = skill.name ?? UIText.defaultSkillName

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

    private func handleDeleteSkill(_ skill: Skill) {
        // Protection: Can't delete if currently tracking this skill
        if let activeSkill = viewModel.activeSkill, activeSkill.id == skill.id {
            // Could add a separate alert here, but for now just prevent deletion
            return
        }

        skillToDelete = skill
        showingDeleteAlert = true
    }

    // MARK: - Keyboard Handlers

    @discardableResult
    private func handleSpaceKey() -> Bool {
        if viewModel.activeSkill != nil {
            if viewModel.timerManager.isPaused {
                viewModel.resumeTracking()
            } else {
                viewModel.pauseTracking()
            }
            return true
        }
        return false
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
        if viewModel.activeSkill == nil {
            if let current = selectedSkillIndex {
                if current > 0 {
                    selectedSkillIndex = current - 1
                }
            } else {
                selectedSkillIndex = viewModel.skills.count - 1
            }
        }
    }

    private func navigateDown() {
        if viewModel.activeSkill == nil {
            if let current = selectedSkillIndex {
                if current < viewModel.skills.count - 1 {
                    selectedSkillIndex = current + 1
                }
            } else {
                selectedSkillIndex = 0
            }
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

// MARK: - View Extensions

extension View {
    func withKeyboardHandlers(
        viewModel: AppViewModel,
        isPanelFocused: FocusState<Bool>.Binding,
        dismiss: DismissAction,
        handleSpaceKey: @escaping () -> Bool,
        handleReturnKey: @escaping () -> Bool,
        navigateUp: @escaping () -> Void,
        navigateDown: @escaping () -> Void,
        handleQuickSwitch: @escaping (KeyPress) -> Bool
    ) -> some View {
        self
            .focusable()
            .focused(isPanelFocused)
            .onAppear {
                isPanelFocused.wrappedValue = true
            }
            .withNavigationKeys(
                handleSpaceKey: handleSpaceKey,
                handleReturnKey: handleReturnKey,
                navigateUp: navigateUp,
                navigateDown: navigateDown
            )
            .withNumberKeys(handleQuickSwitch: handleQuickSwitch)
            .withCommandKeys(viewModel: viewModel, dismiss: dismiss)
    }

    private func withNavigationKeys(
        handleSpaceKey: @escaping () -> Bool,
        handleReturnKey: @escaping () -> Bool,
        navigateUp: @escaping () -> Void,
        navigateDown: @escaping () -> Void
    ) -> some View {
        self
            .onKeyPress(.space) {
                return handleSpaceKey() ? .handled : .ignored
            }
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
            .onKeyPress(keys: [KeyboardShortcuts.addSkill], phases: .down) { press in
                if press.modifiers.contains(.command) && viewModel.activeSkill == nil {
                    withAnimation(.microInteraction) {
                        viewModel.isAddingSkill = true
                    }
                    return .handled
                }
                return .ignored
            }
            .onKeyPress(keys: [KeyboardShortcuts.stopTracking], phases: .down) { press in
                if press.modifiers.contains(.command) && viewModel.activeSkill != nil {
                    withAnimation(.panelTransition) {
                        viewModel.stopTracking()
                    }
                    return .handled
                }
                return .ignored
            }
            .onKeyPress(keys: [KeyboardShortcuts.quit], phases: .down) { press in
                if press.modifiers.contains(.command) {
                    NSApplication.shared.terminate(nil)
                    return .handled
                }
                return .ignored
            }
            .onCommand(#selector(NSResponder.cancelOperation(_:)), perform: {
                dismiss()
            })
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
