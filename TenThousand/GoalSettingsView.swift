//
//  GoalSettingsView.swift
//  TenThousand
//
//  Goal configuration interface
//

import SwiftUI

struct GoalSettingsView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var isEnabled: Bool = false
    @State private var goalType: String = "daily"
    @State private var hours: Int = 1
    @State private var minutes: Int = 0

    var body: some View {
        VStack(spacing: Spacing.base) {
            // Header
            HStack {
                Image(systemName: "target")
                    .font(.system(size: Dimensions.iconSizeSmall))
                    .foregroundColor(.trackingBlue)

                Text("Goal Settings")
                    .font(Typography.display)
                    .foregroundColor(.primary)

                Spacer()

                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .controlSize(.small)
                    .onChange(of: isEnabled) { _, newValue in
                        saveSettings()
                    }
            }

            if isEnabled {
                Divider()

                // Goal Type Picker
                VStack(alignment: .leading, spacing: Spacing.tight) {
                    Text("Goal Period")
                        .font(Typography.caption)
                        .foregroundColor(.secondary)

                    Picker("", selection: $goalType) {
                        Text("Daily").tag("daily")
                        Text("Weekly").tag("weekly")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: goalType) { _, _ in
                        saveSettings()
                    }
                }

                Divider()

                // Target Time
                VStack(alignment: .leading, spacing: Spacing.tight) {
                    Text("Target Time")
                        .font(Typography.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: Spacing.base) {
                        // Hours picker
                        VStack(spacing: 2) {
                            Stepper("", value: $hours, in: 0...23)
                                .labelsHidden()
                                .onChange(of: hours) { _, _ in
                                    saveSettings()
                                }

                            Text("\(hours)h")
                                .font(Typography.body)
                                .foregroundColor(.primary)
                        }

                        Text(":")
                            .font(Typography.body)
                            .foregroundColor(.secondary)

                        // Minutes picker
                        VStack(spacing: 2) {
                            Stepper("", value: $minutes, in: 0...59, step: 15)
                                .labelsHidden()
                                .onChange(of: minutes) { _, _ in
                                    saveSettings()
                                }

                            Text("\(minutes)m")
                                .font(Typography.body)
                                .foregroundColor(.primary)
                        }
                    }
                }

                Divider()

                // Info text
                Text(infoText)
                    .font(Typography.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, Spacing.base)
        .padding(.vertical, Spacing.tight)
        .onAppear {
            loadSettings()
        }
    }

    private var infoText: String {
        if goalType == "daily" {
            return "Track daily progress and get visual feedback when you meet your daily goal."
        } else {
            return "Track weekly progress across all days. Goal resets each week."
        }
    }

    private func loadSettings() {
        if let goal = viewModel.goalSettings {
            isEnabled = goal.isEnabled
            goalType = goal.goalType ?? "daily"
            let totalMinutes = goal.targetMinutes
            hours = Int(totalMinutes / 60)
            minutes = Int(totalMinutes % 60)
        }
    }

    private func saveSettings() {
        let totalMinutes = Int64(hours * 60 + minutes)
        // Ensure at least 1 minute
        let finalMinutes = max(1, totalMinutes)
        viewModel.updateGoalSettings(
            goalType: goalType,
            targetMinutes: finalMinutes,
            isEnabled: isEnabled
        )
    }
}
