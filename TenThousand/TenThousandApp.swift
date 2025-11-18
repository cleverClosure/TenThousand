//
//  TenThousandApp.swift
//  TenThousand
//
//  Created by Tim Isaev on 18.11.2025.
//

import SwiftUI

@main
struct TenThousandApp: App {
    @StateObject private var viewModel = AppViewModel()
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        MenuBarExtra {
            DropdownPanelView(viewModel: viewModel)
        } label: {
            MenuBarIconView(timerManager: viewModel.timerManager)
        }
        .menuBarExtraStyle(.window)
    }
}
