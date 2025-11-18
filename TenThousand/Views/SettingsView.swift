//
//  SettingsView.swift
//  TenThousand
//
//  Created by Tim Isaev on 18.11.2025.
//

import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(Constants.launchAtStartupKey) private var launchAtStartup = false

    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Settings")
                .font(.system(size: 17, weight: .semibold))
                .padding(.top, 20)

            Divider()

            // Launch at startup toggle
            HStack {
                Text("Launch at startup")
                    .font(.system(size: 13))

                Spacer()

                Toggle("", isOn: $launchAtStartup)
                    .labelsHidden()
                    .onChange(of: launchAtStartup) { oldValue, newValue in
                        handleLaunchAtStartupChange(newValue)
                    }
            }
            .padding(.horizontal, 20)

            Spacer()

            // Close button
            Button("Done") {
                dismiss()
            }
            .keyboardShortcut(.defaultAction)
            .padding(.bottom, 20)
        }
        .frame(width: 320, height: 200)
    }

    private func handleLaunchAtStartupChange(_ enabled: Bool) {
        if enabled {
            // Register app to launch at login
            try? SMAppService.mainApp.register()
        } else {
            // Unregister app from launching at login
            try? SMAppService.mainApp.unregister()
        }
    }
}

#Preview {
    SettingsView()
}
