//
//  SkillHeatmapView.swift
//  TenThousand
//
//  GitHub-style heatmap showing 365 days of activity for a skill
//

import SwiftUI

struct SkillHeatmapView: View {
    let skill: Skill
    @ObservedObject var viewModel: AppViewModel
    @State private var hoveredDate: Date? = nil

    // GitHub-style layout: 53 weeks × 7 days
    private let weeksToShow = 53
    private let cellSize: CGFloat = 11
    private let cellSpacing: CGFloat = 3
    private let monthLabelHeight: CGFloat = 14

    private var skillColor: Color {
        let colors: [Color] = [
            .skillRed, .skillOrange, .skillYellow, .skillGreen,
            .skillTeal, .trackingBlue, .skillPurple, .skillPink
        ]
        return colors[Int(skill.colorIndex) % colors.count]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.tight) {
            // Get the heatmap data
            let heatmapData = viewModel.heatmapDataForSkill(skill, daysBack: 365)

            VStack(alignment: .leading, spacing: Spacing.tight) {
                // Month labels
                monthLabelsView

                HStack(alignment: .top, spacing: 0) {
                    // Day labels (Mon, Wed, Fri)
                    dayLabelsView

                    // Calendar grid
                    calendarGridView(data: heatmapData)
                }
            }

            // Legend
            legendView
        }
    }

    // MARK: - Month Labels

    private var monthLabelsView: some View {
        HStack(spacing: 0) {
            // Offset for day labels
            Spacer()
                .frame(width: 20)

            let calendar = Calendar.current
            let today = Date()
            let startDate = calendar.date(byAdding: .day, value: -364, to: today) ?? today

            // Calculate month positions
            ForEach(0..<12, id: \.self) { monthIndex in
                if let monthStart = calendar.date(byAdding: .month, value: monthIndex, to: startDate),
                   monthStart <= today {
                    let daysSinceStart = calendar.dateComponents([.day], from: startDate, to: monthStart).day ?? 0
                    let weekPosition = daysSinceStart / 7

                    if weekPosition < weeksToShow {
                        Text(monthStart.formatted(.dateTime.month(.abbreviated)))
                            .font(Typography.caption)
                            .kerning(Typography.captionKerning)
                            .foregroundColor(.secondary)
                            .frame(width: (cellSize + cellSpacing) * 4.35, alignment: .leading)
                            .offset(x: CGFloat(weekPosition) * (cellSize + cellSpacing))
                    }
                }
            }

            Spacer()
        }
        .frame(height: monthLabelHeight)
    }

    // MARK: - Day Labels

    private var dayLabelsView: some View {
        VStack(alignment: .trailing, spacing: cellSpacing) {
            // Empty space for alignment
            Spacer().frame(height: cellSize)

            Text("Mon")
                .font(Typography.caption)
                .kerning(Typography.captionKerning)
                .foregroundColor(.secondary)
                .frame(height: cellSize)

            Spacer().frame(height: cellSize)

            Text("Wed")
                .font(Typography.caption)
                .kerning(Typography.captionKerning)
                .foregroundColor(.secondary)
                .frame(height: cellSize)

            Spacer().frame(height: cellSize)

            Text("Fri")
                .font(Typography.caption)
                .kerning(Typography.captionKerning)
                .foregroundColor(.secondary)
                .frame(height: cellSize)

            Spacer().frame(height: cellSize)
        }
        .frame(width: 20)
    }

    // MARK: - Calendar Grid

    private func calendarGridView(data: [Date: Int64]) -> some View {
        let calendar = Calendar.current
        let today = Date()
        let startDate = calendar.date(byAdding: .day, value: -364, to: today) ?? today

        // Adjust start date to previous Sunday
        let weekdayOfStart = calendar.component(.weekday, from: startDate)
        let adjustedStartDate = calendar.date(byAdding: .day, value: -(weekdayOfStart - 1), to: startDate) ?? startDate

        return HStack(alignment: .top, spacing: cellSpacing) {
            ForEach(0..<weeksToShow, id: \.self) { weekIndex in
                VStack(spacing: cellSpacing) {
                    ForEach(0..<7, id: \.self) { dayIndex in
                        let dayOffset = weekIndex * 7 + dayIndex
                        if let cellDate = calendar.date(byAdding: .day, value: dayOffset, to: adjustedStartDate),
                           cellDate <= today {
                            cellView(for: cellDate, seconds: data[cellDate] ?? 0)
                        } else {
                            // Empty cell for future dates
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Cell View

    private func cellView(for date: Date, seconds: Int64) -> some View {
        let isHovered = hoveredDate == date
        let level = intensityLevel(for: seconds)

        return RoundedRectangle(cornerRadius: 2)
            .fill(skillColor.opacity(level))
            .frame(width: cellSize, height: cellSize)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .strokeBorder(Color.primary.opacity(0.3), lineWidth: isHovered ? 1 : 0)
            )
            .scaleEffect(isHovered ? 1.1 : 1.0)
            .animation(.hoverState, value: isHovered)
            .onHover { hovering in
                hoveredDate = hovering ? date : nil
            }
            .overlay(
                Group {
                    if isHovered {
                        tooltipView(for: date, seconds: seconds)
                    }
                }
            )
    }

    // MARK: - Tooltip

    private func tooltipView(for date: Date, seconds: Int64) -> some View {
        VStack(spacing: Spacing.tight) {
            Text(date.formatted(date: .abbreviated, time: .omitted))
                .font(Typography.caption)
                .kerning(Typography.captionKerning)

            if seconds > 0 {
                let hours = Double(seconds) / 3600.0
                Text(String(format: "%.1f hours", hours))
                    .font(Typography.caption)
                    .kerning(Typography.captionKerning)
                    .fontWeight(.medium)
            } else {
                Text("No activity")
                    .font(Typography.caption)
                    .kerning(Typography.captionKerning)
            }
        }
        .padding(Spacing.base)
        .background(
            RoundedRectangle(cornerRadius: Dimensions.cornerRadiusSmall)
                .fill(Color.primary.opacity(0.95))
        )
        .foregroundColor(Color(nsColor: .controlBackgroundColor))
        .offset(y: -(cellSize + 35))
        .zIndex(100)
    }

    // MARK: - Legend

    private var legendView: some View {
        HStack(spacing: Spacing.base) {
            Text("Less")
                .font(Typography.caption)
                .kerning(Typography.captionKerning)
                .foregroundColor(.secondary)

            ForEach(0..<7, id: \.self) { level in
                RoundedRectangle(cornerRadius: 2)
                    .fill(skillColor.opacity(opacityForLevel(level)))
                    .frame(width: cellSize, height: cellSize)
            }

            Text("More")
                .font(Typography.caption)
                .kerning(Typography.captionKerning)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Helper Functions

    private func intensityLevel(for seconds: Int64) -> Double {
        if seconds == 0 { return 0.05 }

        let hours = Double(seconds) / 3600.0

        // Progressive intensity levels based on hours
        if hours < 0.5 { return 0.15 }      // < 30 min
        if hours < 1.0 { return 0.30 }      // < 1 hour
        if hours < 2.0 { return 0.45 }      // < 2 hours
        if hours < 3.0 { return 0.60 }      // < 3 hours
        if hours < 4.0 { return 0.75 }      // < 4 hours
        return 0.90                          // 4+ hours
    }

    private func opacityForLevel(_ level: Int) -> Double {
        switch level {
        case 0: return 0.05
        case 1: return 0.15
        case 2: return 0.30
        case 3: return 0.45
        case 4: return 0.60
        case 5: return 0.75
        case 6: return 0.90
        default: return 0.05
        }
    }
}
