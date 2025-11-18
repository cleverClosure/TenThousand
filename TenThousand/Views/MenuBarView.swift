//
//  MenuBarView.swift
//  TenThousand
//
//  Created by Tim Isaev on 18.11.2025.
//

import SwiftUI

struct MenuBarView: View {
    @ObservedObject var data: SkillTrackerData
    @State private var showAddSkill = false
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header

            Divider()

            // Time Remaining Section
            TimeRemainingView()
                .padding(.horizontal, Constants.panelPadding)

            Divider()

            // Skills List
            if data.skills.isEmpty {
                emptyState
            } else {
                skillsList
            }

            Divider()

            // Footer
            footer
        }
        .frame(width: Constants.panelWidth)
        .background(Color(nsColor: .windowBackgroundColor))
        .sheet(isPresented: $showAddSkill) {
            AddSkillView(data: data)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Skill Tracker")
                .font(.system(size: 17, weight: .semibold))

            Spacer()

            Button(action: { showSettings = true }) {
                Image(systemName: "gear")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("Settings")
        }
        .padding(.horizontal, Constants.panelPadding)
        .padding(.vertical, 12)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
                .padding(.top, 30)

            Text("No skills yet.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)

            Text("Click \"+ Add Skill\" to get started!")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(height: 200)
    }

    // MARK: - Skills List

    private var skillsList: some View {
        ScrollView {
            VStack(spacing: Constants.rowSpacing) {
                ForEach(data.skills) { skill in
                    SkillRowView(
                        skill: skill,
                        onPlayPause: {
                            toggleTracking(for: skill)
                        },
                        onDelete: {
                            data.deleteSkill(skill)
                        }
                    )
                }
            }
            .padding(Constants.panelPadding)
        }
        .frame(maxHeight: 400)
    }

    // MARK: - Footer

    private var footer: some View {
        HStack(spacing: 12) {
            Button(action: { showAddSkill = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Add Skill")
                        .font(.system(size: 13, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .help("Add a new skill")

            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Text("Quit")
                    .font(.system(size: 13, weight: .medium))
                    .frame(width: 60)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.bordered)
            .help("Quit application")
        }
        .padding(Constants.panelPadding)
    }

    // MARK: - Actions

    private func toggleTracking(for skill: Skill) {
        if skill.isTracking {
            data.pauseTracking(skill: skill)
        } else {
            data.startTracking(skill: skill)
        }
    }
}

#Preview {
    MenuBarView(data: {
        let data = SkillTrackerData()
        data.addSkill(name: "Python Programming", goalHours: 10000)
        data.addSkill(name: "Guitar", goalHours: 10000)
        return data
    }())
}
