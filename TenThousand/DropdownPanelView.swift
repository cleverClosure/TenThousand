//
//  DropdownPanelView.swift
//  TenThousand
//
//  Main dropdown panel combining all components
//

import SwiftUI
import AppKit

struct DropdownPanelView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSkillIndex: Int? = nil
    @FocusState private var isPanelFocused: Bool

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
            activeSessionSection
            skillListSection

            Divider()

            TodaysSummaryView(
                totalSeconds: viewModel.todaysTotalSeconds(),
                skillCount: viewModel.todaysSkillCount()
            )

            Divider()

            HeatmapView(
                data: viewModel.heatmapData(),
                levelForSeconds: viewModel.heatmapLevel
            )
        }
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
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
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
            .frame(maxHeight: 200)
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
                isHighlighted: viewModel.justUpdatedSkillId == skill.id
            ) {
                withAnimation(.panelTransition) {
                    viewModel.startTracking(skill: skill)
                }
            }
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
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)

                    Text("Add skill")
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

    private var backgroundView: some View {
        VisualEffectBlur(material: .menu, blendingMode: .behindWindow)
    }

    private var overlayBorder: some View {
        RoundedRectangle(cornerRadius: Dimensions.panelCornerRadius)
            .stroke(Color.primary.opacity(0.05), lineWidth: 1)
    }

    private var shadowColor: Color {
        Color.black.opacity(Shadows.floating.opacity)
    }

    private var existingSkillNames: [String] {
        viewModel.skills.compactMap { $0.name }
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
                viewModel.startTracking(skill: skill)
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
        let numbers: [KeyEquivalent] = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
        if let index = numbers.firstIndex(of: press.key), index < viewModel.skills.count {
            let skill = viewModel.skills[index]
            withAnimation(.panelTransition) {
                viewModel.startTracking(skill: skill)
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
                handleSpaceKey()
                return .handled
            }
            .onKeyPress(.return) {
                handleReturnKey()
                return .handled
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
        self
            .onKeyPress("1", modifiers: .command) { press in
                handleQuickSwitch(press)
                return .handled
            }
            .onKeyPress("2", modifiers: .command) { press in
                handleQuickSwitch(press)
                return .handled
            }
            .onKeyPress("3", modifiers: .command) { press in
                handleQuickSwitch(press)
                return .handled
            }
            .onKeyPress("4", modifiers: .command) { press in
                handleQuickSwitch(press)
                return .handled
            }
            .onKeyPress("5", modifiers: .command) { press in
                handleQuickSwitch(press)
                return .handled
            }
            .onKeyPress("6", modifiers: .command) { press in
                handleQuickSwitch(press)
                return .handled
            }
            .onKeyPress("7", modifiers: .command) { press in
                handleQuickSwitch(press)
                return .handled
            }
            .onKeyPress("8", modifiers: .command) { press in
                handleQuickSwitch(press)
                return .handled
            }
            .onKeyPress("9", modifiers: .command) { press in
                handleQuickSwitch(press)
                return .handled
            }
    }

    private func withCommandKeys(
        viewModel: AppViewModel,
        dismiss: DismissAction
    ) -> some View {
        self
            .onKeyPress("n", modifiers: .command) { _ in
                if viewModel.activeSkill == nil {
                    withAnimation(.microInteraction) {
                        viewModel.isAddingSkill = true
                    }
                    return .handled
                }
                return .ignored
            }
            .onKeyPress(".", modifiers: .command) { _ in
                if viewModel.activeSkill != nil {
                    withAnimation(.panelTransition) {
                        viewModel.stopTracking()
                    }
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
