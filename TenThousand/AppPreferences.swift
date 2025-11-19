//
//  AppPreferences.swift
//  TenThousand
//
//  Manages app-wide settings and preferences
//

import Foundation
import SwiftUI
import ServiceManagement

class AppPreferences: ObservableObject {
    private static let launchAtLoginKey = "launchAtLogin"
    private static let showMenuBarTimerKey = "showMenuBarTimer"

    static let shared = AppPreferences()

    @Published var launchAtLogin: Bool {
        didSet {
            saveLaunchAtLogin()
            updateLaunchAtLoginStatus()
        }
    }

    @Published var showMenuBarTimer: Bool {
        didSet {
            saveShowMenuBarTimer()
        }
    }

    private init() {
        // Load launch at login preference
        self.launchAtLogin = UserDefaults.standard.bool(forKey: Self.launchAtLoginKey)

        // Load menu bar timer preference (default to true)
        if UserDefaults.standard.object(forKey: Self.showMenuBarTimerKey) != nil {
            self.showMenuBarTimer = UserDefaults.standard.bool(forKey: Self.showMenuBarTimerKey)
        } else {
            self.showMenuBarTimer = true
        }

        // Sync the launch at login state on init
        syncLaunchAtLoginState()
    }

    private func saveLaunchAtLogin() {
        UserDefaults.standard.set(launchAtLogin, forKey: Self.launchAtLoginKey)
    }

    private func saveShowMenuBarTimer() {
        UserDefaults.standard.set(showMenuBarTimer, forKey: Self.showMenuBarTimerKey)
    }

    // MARK: - Launch at Login

    private func updateLaunchAtLoginStatus() {
        if #available(macOS 13.0, *) {
            // Use the new ServiceManagement API for macOS 13+
            do {
                if launchAtLogin {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to update launch at login status: \(error.localizedDescription)")
            }
        } else {
            // For older macOS versions, use the legacy API
            SMLoginItemSetEnabled("com.tenthousand.LaunchHelper" as CFString, launchAtLogin)
        }
    }

    private func syncLaunchAtLoginState() {
        if #available(macOS 13.0, *) {
            let currentStatus = SMAppService.mainApp.status
            let isEnabled = currentStatus == .enabled

            // Update the stored preference if it doesn't match the actual state
            if isEnabled != launchAtLogin {
                launchAtLogin = isEnabled
            }
        }
    }
}
