//
//  TenThousandApp.swift
//  TenThousand
//
//  Created by Tim Isaev on 18.11.2025.
//

import SwiftUI

@main
struct TenThousandApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController?
    private let viewModel = AppViewModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarController = StatusBarController(viewModel: viewModel)
    }
}
