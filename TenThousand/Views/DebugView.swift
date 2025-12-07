//
//  DebugView.swift
//  TenThousand
//
//  Author: Tim Isaev
//
//  Developer debug screen (DEBUG builds only)
//

#if DEBUG
import SwiftUI

// MARK: - DebugView

struct DebugView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: AppViewModel

    // MARK: - Private State

    @State private var showingResetAlert = false
    @State private var showingSeededAlert = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            ScrollView {
                VStack(spacing: DS.Spacing.lg) {
                    appInfoSection
                    dataInspectorSection
                    if viewModel.isTimerRunning {
                        timerStateSection
                    }
                    quickActionsSection
                }
                .padding(DS.Spacing.md)
            }
            .scrollIndicators(.hidden)
            Divider()
            backButton
        }
        .alert("Reset All Data?", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                resetAllData()
            }
        } message: {
            Text("This will permanently delete all skills and sessions.")
        }
        .alert("Test Data Added", isPresented: $showingSeededAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Created 3 test skills with sample sessions.")
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Image(systemName: "hammer.fill")
                .foregroundColor(.orange)
            Text("Developer Debug")
                .font(DS.Font.title)
            Spacer()
            debugBadge
        }
        .padding(.horizontal, DS.Spacing.md)
        .padding(.vertical, DS.Spacing.sm)
    }

    private var debugBadge: some View {
        Text("DEBUG")
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundColor(.white)
            .padding(.horizontal, DS.Spacing.sm)
            .padding(.vertical, DS.Spacing.xs)
            .background(Color.orange, in: RoundedRectangle(cornerRadius: DS.Radius.small))
    }

    // MARK: - App Info Section

    private var appInfoSection: some View {
        DebugSection(title: "App Info") {
            DebugRow(label: "Version", value: appVersion)
            DebugRow(label: "Build", value: buildNumber)
            DebugRow(label: "Store", value: storeLocation)
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }

    private var storeLocation: String {
        if let container = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            return container.lastPathComponent
        }
        return "Unknown"
    }

    // MARK: - Data Inspector Section

    private var dataInspectorSection: some View {
        DebugSection(title: "Data Inspector") {
            DebugRow(label: "Skills", value: "\(viewModel.skills.count)")
            DebugRow(label: "Total Sessions", value: "\(totalSessionCount)")

            if !viewModel.skills.isEmpty {
                Divider()
                    .padding(.vertical, DS.Spacing.xs)

                ForEach(viewModel.skills) { skill in
                    skillRow(skill)
                }
            }
        }
    }

    private var totalSessionCount: Int {
        viewModel.skills.reduce(0) { $0 + $1.sessions.count }
    }

    private func skillRow(_ skill: Skill) -> some View {
        HStack(spacing: DS.Spacing.sm) {
            Circle()
                .fill(skill.color)
                .frame(width: 8, height: 8)

            Text(skill.name)
                .font(DS.Font.caption)
                .lineLimit(1)

            Spacer()

            Text("\(String(format: "%.1f", skill.totalHours))h")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.secondary)

            Text("(\(skill.sessions.count))")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.secondary.opacity(0.6))
        }
    }

    // MARK: - Timer State Section

    private var timerStateSection: some View {
        DebugSection(title: "Timer State") {
            DebugRow(label: "Running", value: viewModel.isTimerRunning ? "Yes" : "No")
            DebugRow(label: "Paused", value: viewModel.isTimerPaused ? "Yes" : "No")
            DebugRow(label: "Elapsed", value: formatSeconds(viewModel.elapsedSeconds))

            if let skill = viewModel.activeSkill {
                DebugRow(label: "Active Skill", value: skill.name)
            }

            if let session = viewModel.currentSession {
                DebugRow(label: "Session Start", value: formatDate(session.startTime))
            }
        }
    }

    private func formatSeconds(_ seconds: Int64) -> String {
        let hours = seconds / Time.secondsPerHour
        let minutes = (seconds % Time.secondsPerHour) / Time.secondsPerMinute
        let secs = seconds % Time.secondsPerMinute
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }

    // MARK: - Quick Actions Section

    private var quickActionsSection: some View {
        DebugSection(title: "Quick Actions") {
            VStack(spacing: DS.Spacing.sm) {
                actionButton(
                    title: "Seed Test Data",
                    icon: "plus.circle.fill",
                    color: .blue
                ) {
                    seedTestData()
                }

                actionButton(
                    title: "Add 1h to First Skill",
                    icon: "clock.badge.fill",
                    color: .green,
                    isDisabled: viewModel.skills.isEmpty
                ) {
                    addHourToFirstSkill()
                }

                actionButton(
                    title: "Reset All Data",
                    icon: "trash.fill",
                    color: .red
                ) {
                    showingResetAlert = true
                }
            }
        }
    }

    private func actionButton(
        title: String,
        icon: String,
        color: Color,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.sm) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(DS.Font.caption)
                Spacer()
            }
            .padding(.horizontal, DS.Spacing.sm)
            .padding(.vertical, DS.Spacing.sm)
            .background(DS.Color.background(.subtle), in: RoundedRectangle(cornerRadius: DS.Radius.small))
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }

    // MARK: - Back Button

    private var backButton: some View {
        PanelButton(
            "Back",
            icon: "chevron.left",
            alignment: .leading,
            shortcut: "Esc",
            isCompact: true
        ) {
            withAnimation(.dsStandard) {
                viewModel.showSkillList()
            }
        }
        .padding(.horizontal, DS.Spacing.md)
        .padding(.vertical, DS.Spacing.xs)
    }

    // MARK: - Actions

    private func seedTestData() {
        let testSkills = ["Piano", "Drawing", "Chess"]

        for (index, name) in testSkills.enumerated() {
            // Skip if skill already exists
            guard !viewModel.skills.contains(where: { $0.name == name }) else { continue }

            viewModel.createSkill(name: name)

            // Add some varied sessions to each skill
            if let skill = viewModel.skills.first(where: { $0.name == name }) {
                addTestSessions(to: skill, count: index + 2)
            }
        }

        showingSeededAlert = true
    }

    private func addTestSessions(to skill: Skill, count: Int) {
        for i in 0..<count {
            let session = viewModel.dataStore.createSession(for: skill)
            let hoursAgo = Double((count - i) * 24 + Int.random(in: 1...12))
            let startTime = Date().addingTimeInterval(-hoursAgo * 3600)
            let duration = Int64.random(in: 1800...7200) // 30min to 2hrs

            session.startTime = startTime
            session.endTime = startTime.addingTimeInterval(Double(duration))
            session.pausedDuration = 0
        }
        viewModel.dataStore.save()
        viewModel.fetchSkills()
    }

    private func addHourToFirstSkill() {
        guard let skill = viewModel.skills.first else { return }

        let session = viewModel.dataStore.createSession(for: skill)
        let duration: Int64 = Time.secondsPerHour
        session.endTime = Date()
        session.startTime = Date().addingTimeInterval(-Double(duration))
        session.pausedDuration = 0

        viewModel.dataStore.save()
        viewModel.fetchSkills()
    }

    private func resetAllData() {
        // Stop any active tracking first
        if viewModel.isTimerRunning {
            viewModel.stopTracking()
        }

        // Delete all skills (sessions cascade delete)
        for skill in viewModel.skills {
            viewModel.deleteSkill(skill)
        }

        viewModel.fetchSkills()
    }
}

// MARK: - Debug Section

private struct DebugSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text(title)
                .font(DS.Font.label)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                content()
            }
            .padding(DS.Spacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DS.Color.background(.subtle), in: RoundedRectangle(cornerRadius: DS.Radius.small))
        }
    }
}

// MARK: - Debug Row

private struct DebugRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(DS.Font.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.primary)
                .lineLimit(1)
        }
    }
}

#endif
