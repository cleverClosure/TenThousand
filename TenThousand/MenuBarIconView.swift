//
//  MenuBarIconView.swift
//  TenThousand
//
//  Menubar icon with idle/active states
//  The menubar is sacred space. Our icon must earn its place through discretion and utility.
//

import SwiftUI

struct MenuBarIconView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: AppViewModel
    @ObservedObject private var timerManager: TimerManager
    @AppStorage("showMenuBarTimer") private var showMenuBarTimer = true

    init(viewModel: AppViewModel) {
        self.viewModel = viewModel
        self.timerManager = viewModel.timerManager
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(iconColor)

            if showMenuBarTimer && timerManager.isRunning {
                Text(timerManager.elapsedSeconds.formattedTime())
                    .monospacedDigit()
            }
        }
    }

    // MARK: - Private Computed Properties

    private var iconName: String {
        if timerManager.isRunning && !timerManager.isPaused {
            return "circle.circle.fill"
        } else if timerManager.isRunning && timerManager.isPaused {
            return "pause.circle"
        } else {
            return "circle.circle"
        }
    }

    private var iconColor: Color {
        guard let skill = viewModel.activeSkill, timerManager.isRunning else {
            return .primary
        }
        return ColorPaletteManager.shared.color(
            forPaletteId: skill.paletteId,
            colorIndex: Int(skill.colorIndex)
        )
    }
}
