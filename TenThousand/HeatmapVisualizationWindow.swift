//
//  HeatmapVisualizationWindow.swift
//  TenThousand
//
//  Dedicated resizable window for deep heatmap visualization
//

import SwiftUI

struct HeatmapVisualizationWindow: View {
    @ObservedObject var viewModel: AppViewModel
    @StateObject private var preferences = HeatmapWindowPreferences()

    var body: some View {
        VStack(spacing: 0) {
            // Header with controls
            headerView

            Divider()

            // Main heatmap display
            EnhancedHeatmapView(
                skill: selectedSkill,
                viewMode: preferences.selectedViewMode,
                viewModel: viewModel
            )
            .animation(.panelTransition, value: preferences.selectedViewMode)
            .animation(.panelTransition, value: preferences.selectedSkillId)
        }
        .frame(minWidth: 600, minHeight: 400)
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(spacing: Spacing.section) {
            // Skill selector
            skillSelector

            Spacer()

            // View mode picker
            viewModePicker
        }
        .padding(Spacing.section)
        .background(Color(nsColor: .controlBackgroundColor))
    }

    // MARK: - Skill Selector

    private var skillSelector: some View {
        Menu {
            // "All Skills" option
            Button {
                preferences.selectedSkillId = nil
            } label: {
                HStack {
                    Text("All Skills")
                    if preferences.selectedSkillId == nil {
                        Image(systemName: "checkmark")
                    }
                }
            }

            Divider()

            // Individual skills
            ForEach(viewModel.skills, id: \.id) { skill in
                Button {
                    preferences.selectedSkillId = skill.id
                } label: {
                    HStack {
                        Circle()
                            .fill(skillColor(for: skill))
                            .frame(width: 12, height: 12)

                        Text(skill.name ?? "Untitled")

                        if preferences.selectedSkillId == skill.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: Spacing.base) {
                if let skill = selectedSkill {
                    Circle()
                        .fill(skillColor(for: skill))
                        .frame(width: 16, height: 16)
                    Text(skill.name ?? "Untitled")
                        .font(Typography.display)
                        .kerning(Typography.displayKerning)
                } else {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.trackingBlue)
                    Text("All Skills")
                        .font(Typography.display)
                        .kerning(Typography.displayKerning)
                }
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, Spacing.loose)
            .padding(.vertical, Spacing.base)
            .background(
                RoundedRectangle(cornerRadius: Dimensions.cornerRadiusMedium)
                    .fill(Color.primary.opacity(0.05))
            )
        }
        .menuStyle(.borderlessButton)
    }

    // MARK: - View Mode Picker

    private var viewModePicker: some View {
        Picker("View Mode", selection: $preferences.selectedViewMode) {
            ForEach(HeatmapViewMode.allCases) { mode in
                Text(mode.displayName).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .frame(width: 240)
    }

    // MARK: - Helper Properties

    private var selectedSkill: Skill? {
        guard let skillId = preferences.selectedSkillId else { return nil }
        return viewModel.skills.first { $0.id == skillId }
    }

    private func skillColor(for skill: Skill) -> Color {
        let colors: [Color] = [
            .skillRed, .skillOrange, .skillYellow, .skillGreen,
            .skillTeal, .trackingBlue, .skillPurple, .skillPink
        ]
        return colors[Int(skill.colorIndex) % colors.count]
    }
}

// MARK: - Window Opener Helper

class HeatmapWindowController: NSObject {
    static let shared = HeatmapWindowController()

    private var window: NSWindow?

    func openHeatmapWindow(viewModel: AppViewModel) {
        // If window already exists, bring it to front
        if let existingWindow = window {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        // Create new window
        let contentView = HeatmapVisualizationWindow(viewModel: viewModel)

        let hostingController = NSHostingController(rootView: contentView)

        let newWindow = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 800, height: 600),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        newWindow.contentViewController = hostingController
        newWindow.title = "TenThousand - Activity Heatmap"
        newWindow.center()
        newWindow.setFrameAutosaveName("HeatmapVisualizationWindow")
        newWindow.isReleasedWhenClosed = false

        // Handle window close
        newWindow.delegate = self

        self.window = newWindow
        newWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

// MARK: - Window Delegate

extension HeatmapWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        window = nil
    }
}
