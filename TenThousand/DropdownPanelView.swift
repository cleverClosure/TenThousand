//
//  DropdownPanelView.swift
//  TenThousand
//
//  Author: Tim Isaev
//
//  Main dropdown panel - routes to appropriate view based on navigation state
//

import AppKit
import SwiftUI

// MARK: - DropdownPanelView

struct DropdownPanelView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Private State

    @FocusState private var isPanelFocused: Bool

    // MARK: - Body

    var body: some View {
        PanelContainer {
            routedContent
        }
        .focusable()
        .focusEffectDisabled()
        .focused($isPanelFocused)
        .onAppear {
            isPanelFocused = true
        }
        .onKeyPress(keys: [KeyEquivalent("q")], phases: .down) { press in
            if press.modifiers.contains(.command) {
                NSApplication.shared.terminate(nil)
                return .handled
            }
            return .ignored
        }
        #if DEBUG
        .onKeyPress(keys: [KeyEquivalent("d")], phases: .down) { press in
            if press.modifiers.contains(.command) {
                withAnimation(.dsStandard) {
                    viewModel.panelRoute = .debug
                }
                return .handled
            }
            return .ignored
        }
        #endif
        .onCommand(#selector(NSResponder.cancelOperation(_:))) {
            handleEscape()
        }
    }

    // MARK: - Routed Content

    @ViewBuilder
    private var routedContent: some View {
        switch viewModel.panelRoute {
        case .skillList:
            SkillListView(viewModel: viewModel)
                .transition(.opacity)

        case .skillDetail(let skill):
            SkillDetailView(skill: skill, viewModel: viewModel)
                .transition(.opacity.combined(with: .move(edge: .trailing)))

        case .activeTracking:
            if let skill = viewModel.activeSkill {
                ActiveTrackingView(skill: skill, viewModel: viewModel)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                // Fallback if activeSkill is nil (shouldn't happen normally)
                SkillListView(viewModel: viewModel)
                    .onAppear {
                        viewModel.showSkillList()
                    }
            }

        case .skillEdit(let skill):
            SkillEditView(skill: skill, viewModel: viewModel)
                .transition(.opacity.combined(with: .move(edge: .trailing)))

        #if DEBUG
        case .debug:
            DebugView(viewModel: viewModel)
                .transition(.opacity.combined(with: .move(edge: .trailing)))
        #endif
        }
    }

    // MARK: - Private Methods

    private func handleEscape() {
        switch viewModel.panelRoute {
        case .skillList:
            dismiss()
        case .skillDetail, .activeTracking, .skillEdit:
            withAnimation(.dsStandard) {
                viewModel.showSkillList()
            }
        #if DEBUG
        case .debug:
            withAnimation(.dsStandard) {
                viewModel.showSkillList()
            }
        #endif
        }
    }
}
