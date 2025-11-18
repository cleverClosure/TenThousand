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

    var body: some View {
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
        ForEach(viewModel.skills) { skill in
            SkillRowView(
                skill: skill,
                isSelected: false,
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
