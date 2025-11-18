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

            // Overall Progress Dashboard (only show if skills exist)
            if !data.skills.isEmpty {
                VStack(spacing: 0) {
                    OverallProgressView(data: data)
                        .padding(.horizontal, Constants.panelPadding)
                        .padding(.vertical, 12)
                }

                Divider()
            }

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
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(Constants.appName)
                    .font(.system(size: Constants.fontSize_title2, weight: .semibold))
                    .foregroundColor(.primary)

                Text(Constants.appTagline)
                    .font(.system(size: Constants.fontSize_caption))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: { showSettings = true }) {
                Image(systemName: "gear")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("Settings")
        }
        .padding(.horizontal, Constants.panelPadding)
        .padding(.vertical, Constants.spacing_lg)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Constants.spacing_lg) {
            // Icon
            Image(systemName: "target")
                .font(.system(size: 56))
                .foregroundColor(Color(hex: Constants.skillColors[0]) ?? .blue)
                .padding(.top, Constants.spacing_xl)
                .symbolEffect(.pulse)

            // Title
            Text("Start Your Journey")
                .font(.system(size: Constants.fontSize_headline, weight: .semibold))
                .foregroundColor(.primary)

            // Description
            VStack(spacing: 4) {
                Text("Add your first skill to begin tracking")
                    .font(.system(size: Constants.fontSize_callout))
                    .foregroundColor(.secondary)
                Text("your path to mastery")
                    .font(.system(size: Constants.fontSize_callout))
                    .foregroundColor(.secondary)
            }
            .multilineTextAlignment(.center)

            // Call to action button
            Button(action: { showAddSkill = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 14))
                    Text("Add Your First Skill")
                        .font(.system(size: Constants.fontSize_callout, weight: .medium))
                }
                .padding(.horizontal, Constants.buttonPaddingHorizontal)
                .padding(.vertical, Constants.buttonPaddingVertical)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, Constants.spacing_sm)
        }
        .frame(height: 280)
        .frame(maxWidth: .infinity)
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
        HStack(spacing: Constants.spacing_md) {
            Button(action: { showAddSkill = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Add Skill")
                        .font(.system(size: Constants.fontSize_callout, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Constants.buttonPaddingVertical)
            }
            .buttonStyle(.borderedProminent)
            .help("Add a new skill")

            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Text("Quit")
                    .font(.system(size: Constants.fontSize_callout, weight: .medium))
                    .frame(width: 70)
                    .padding(.vertical, Constants.buttonPaddingVertical)
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
