//
//  GoalProgressView.swift
//  TenThousand
//
//  Goal progress indicator and remaining time display
//

import SwiftUI

struct GoalProgressView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        if let goal = viewModel.goalSettings, goal.isEnabled {
            VStack(spacing: Spacing.tight) {
                HStack {
                    Image(systemName: "target")
                        .font(.system(size: Dimensions.iconSizeSmall))
                        .foregroundColor(goalIconColor)

                    Text(goalTitle)
                        .font(Typography.body)
                        .foregroundColor(.primary)

                    Spacer()

                    if viewModel.isGoalMet() {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: Dimensions.iconSizeSmall))
                            .foregroundColor(.green)
                    }
                }

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.mist.opacity(0.3))
                            .frame(height: 6)

                        // Progress
                        RoundedRectangle(cornerRadius: 4)
                            .fill(progressColor)
                            .frame(width: geometry.size.width * CGFloat(viewModel.goalProgressPercentage()), height: 6)
                            .animation(.easeOut(duration: 0.3), value: viewModel.goalProgressPercentage())
                    }
                }
                .frame(height: 6)

                // Time info
                HStack {
                    Text(progressText)
                        .font(Typography.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(viewModel.formattedRemainingTime())
                        .font(Typography.caption)
                        .foregroundColor(remainingTimeColor)
                }
            }
            .padding(.horizontal, Spacing.base)
            .padding(.vertical, Spacing.tight)
        }
    }

    private var goalTitle: String {
        guard let goal = viewModel.goalSettings else { return "Goal" }
        return "\(goal.isDaily ? "Daily" : "Weekly") Goal"
    }

    private var goalIconColor: Color {
        if viewModel.isGoalMet() {
            return .green
        } else {
            return .trackingBlue
        }
    }

    private var progressColor: Color {
        let percentage = viewModel.goalProgressPercentage()

        if percentage >= 1.0 {
            return .green
        } else if percentage >= 0.75 {
            return .trackingBlue
        } else if percentage >= 0.5 {
            return .orange
        } else {
            return .gray
        }
    }

    private var remainingTimeColor: Color {
        if viewModel.isGoalMet() {
            return .green
        } else {
            return .secondary
        }
    }

    private var progressText: String {
        guard let goal = viewModel.goalSettings else { return "" }

        let currentProgress = goal.isDaily ? viewModel.todaysProgress() : viewModel.thisWeeksProgress()
        let currentMinutes = currentProgress / 60
        let targetMinutes = goal.targetMinutes

        let currentHours = currentMinutes / 60
        let currentRemainingMinutes = currentMinutes % 60

        if currentHours > 0 {
            return "\(currentHours)h \(currentRemainingMinutes)m / \(goal.targetHours)h \(goal.targetRemainingMinutes)m"
        } else {
            return "\(currentRemainingMinutes)m / \(goal.targetHours)h \(goal.targetRemainingMinutes)m"
        }
    }
}
