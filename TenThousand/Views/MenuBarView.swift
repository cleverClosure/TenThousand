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
    @State private var showEditSkill = false
    @State private var skillToEdit: Skill?

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
        .sheet(isPresented: $showEditSkill) {
            if let skill = skillToEdit {
                EditSkillView(data: data, skill: skill)
            }
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
        VStack(spacing: 16) {
            Image(systemName: "star.fill")
                .font(.system(size: 52))
                .foregroundColor(.orange)
                .padding(.top, 24)
                .symbolEffect(.bounce, value: showAddSkill)

            Text("Master Any Skill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)

            VStack(spacing: 6) {
                Text("Track your path to 10,000 hours")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)

                Text("of deliberate practice.")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .multilineTextAlignment(.center)

            Text("\"Mastery requires 10,000 hours of practice\"")
                .font(.system(size: 11))
                .italic()
                .foregroundColor(.secondary.opacity(0.8))
                .padding(.horizontal, 40)
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            Button(action: { showAddSkill = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 14))
                    Text("Add Your First Skill")
                        .font(.system(size: 13, weight: .medium))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .frame(height: 280)
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
                        },
                        onEdit: {
                            skillToEdit = skill
                            showEditSkill = true
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
