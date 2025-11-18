//
//  TenThousandApp.swift
//  TenThousand
//
//  Created by Tim Isaev on 18.11.2025.
//

import SwiftUI

@main
struct TenThousandApp: App {
    @StateObject private var data = SkillTrackerData()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(data: data)
        } label: {
            Image(systemName: data.currentlyTrackingSkill != nil ? "timer" : "clock")
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(data.currentlyTrackingSkill != nil ? .green : .primary)
        }
        .menuBarExtraStyle(.window)
    }
}
