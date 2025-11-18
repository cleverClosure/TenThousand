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
                                onCreate: { name in
                                    viewModel.createSkill(name: name)
                                }
                            )
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        // Skills
                        ForEach(viewModel.skills, id: \.id) { skill in
                            SkillRowView(skill: skill) {
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
