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
        VStack(spacing: 0) {
            // Active Session (when tracking)
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

            // Skill List (when idle or showing alongside active)
            if viewModel.activeSkill == nil {
                ScrollView {
                    VStack(spacing: Spacing.tight) {
                        // Add skill button/field
                        if viewModel.isAddingSkill {
                            AddSkillView(
                                isActive: $viewModel.isAddingSkill,
                                existingSkillNames: viewModel.skills.compactMap { $0.name },
                                onCreate: { name in
                                    viewModel.createSkill(name: name)
                                }
                            )
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        // Skills
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

                        // Add skill button (when not adding)
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
                    .padding(Spacing.base)
                }
                .frame(maxHeight: 200)
            }

            Divider()

            // Today's Summary
            TodaysSummaryView(
                totalSeconds: viewModel.todaysTotalSeconds(),
                skillCount: viewModel.todaysSkillCount()
            )

            Divider()

            // Weekly Heatmap
            HeatmapView(
                data: viewModel.heatmapData(),
                levelForSeconds: viewModel.heatmapLevel
            )
        }
        .frame(width: Dimensions.panelWidth)
        .background(
            VisualEffectBlur(material: .menu, blendingMode: .behindWindow)
        )
        .clipShape(RoundedRectangle(cornerRadius: Dimensions.panelCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Dimensions.panelCornerRadius)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
        .shadow(
            color: Color.black.opacity(Shadows.floating.opacity),
            radius: Shadows.floating.radius,
            x: Shadows.floating.x,
            y: Shadows.floating.y
        )
        .focusable()
        .focused($isPanelFocused)
        .onAppear {
            isPanelFocused = true
        }
        .onKeyPress(.space) { press in
            handleSpaceKey()
            return .handled
        }
        .onKeyPress(.return) { press in
            handleReturnKey()
            return .handled
        }
        .onKeyPress(.upArrow) { press in
            navigateUp()
            return .handled
        }
        .onKeyPress(.downArrow) { press in
            navigateDown()
            return .handled
        }
        .onKeyPress(keys: [.one, .two, .three, .four, .five, .six, .seven, .eight, .nine], modifiers: .command) { press in
            handleQuickSwitch(press)
            return .handled
        }
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
        let numbers: [KeyEquivalent] = [.one, .two, .three, .four, .five, .six, .seven, .eight, .nine]
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
