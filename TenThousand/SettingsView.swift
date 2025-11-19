//
//  SettingsView.swift
//  TenThousand
//
//  Settings screen for app preferences
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var preferences: AppPreferences
    @ObservedObject var viewModel: AppViewModel
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            Divider()

            ScrollView {
                VStack(spacing: 0) {
                    launchAtLoginToggle

                    Divider()

                    menuBarTimerToggle

                    Divider()

                    heatmapVisualizationButton
                }
            }

            Divider()

            backButton
        }
        .frame(width: Dimensions.panelWidth)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            Button(action: {
                withAnimation(.panelTransition) {
                    isPresented = false
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: Dimensions.iconSizeSmall, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())

            Text("Settings")
                .font(Typography.display)
                .foregroundColor(.primary)

            Spacer()
        }
        .padding(.horizontal, Spacing.base)
        .padding(.vertical, Spacing.tight)
        .frame(height: Dimensions.skillRowHeight)
    }

    // MARK: - Settings Items

    private var launchAtLoginToggle: some View {
        HStack {
            Image(systemName: "power")
                .font(.system(size: Dimensions.iconSizeSmall))
                .foregroundColor(.secondary)

            Text("Launch at Login")
                .font(Typography.body)
                .foregroundColor(.primary)

            Spacer()

            Toggle("", isOn: $preferences.launchAtLogin)
                .labelsHidden()
                .toggleStyle(.switch)
                .controlSize(.small)
        }
        .padding(.horizontal, Spacing.base)
        .padding(.vertical, Spacing.tight)
        .frame(height: Dimensions.skillRowHeight)
    }

    private var menuBarTimerToggle: some View {
        HStack {
            Image(systemName: "clock")
                .font(.system(size: Dimensions.iconSizeSmall))
                .foregroundColor(.secondary)

            Text("Show Timer in Menu Bar")
                .font(Typography.body)
                .foregroundColor(.primary)

            Spacer()

            Toggle("", isOn: $preferences.showMenuBarTimer)
                .labelsHidden()
                .toggleStyle(.switch)
                .controlSize(.small)
        }
        .padding(.horizontal, Spacing.base)
        .padding(.vertical, Spacing.tight)
        .frame(height: Dimensions.skillRowHeight)
    }

    private var heatmapVisualizationButton: some View {
        Button(action: {
            HeatmapWindowController.shared.openHeatmapWindow(viewModel: viewModel)
        }) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: Dimensions.iconSizeSmall))
                    .foregroundColor(.secondary)

                Text("Heatmap Visualization")
                    .font(Typography.body)
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "arrow.up.forward.square")
                    .font(.system(size: Dimensions.iconSizeSmall))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, Spacing.base)
            .padding(.vertical, Spacing.tight)
            .frame(height: Dimensions.skillRowHeight)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Back Button

    private var backButton: some View {
        Button(action: {
            withAnimation(.panelTransition) {
                isPresented = false
            }
        }) {
            HStack {
                Image(systemName: "arrow.left")
                    .font(.system(size: Dimensions.iconSizeSmall))
                    .foregroundColor(.secondary)

                Text("Back")
                    .font(Typography.body)
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding(.horizontal, Spacing.base)
            .padding(.vertical, Spacing.tight)
            .frame(height: Dimensions.skillRowHeight)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
