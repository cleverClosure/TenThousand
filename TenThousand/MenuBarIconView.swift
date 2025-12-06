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
    @AppStorage("showMenuBarTimer") private var showMenuBarTimer = true

    // MARK: - Body

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(iconColor)

            if showMenuBarTimer && viewModel.isTimerRunning {
                Text(viewModel.elapsedSeconds.formattedTime())
                    .monospacedDigit()
            }
        }
    }

    // MARK: - Private Computed Properties

    private var iconName: String {
        if viewModel.isTimerRunning && !viewModel.isTimerPaused {
            return "circle.circle.fill"
        } else if viewModel.isTimerRunning && viewModel.isTimerPaused {
            return "pause.circle"
        } else {
            return "circle.circle"
        }
    }

    private var iconColor: Color {
        guard let skill = viewModel.activeSkill, viewModel.isTimerRunning else {
            return .primary
        }
        return skill.color
    }
}
