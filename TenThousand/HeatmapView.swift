//
//  HeatmapView.swift
//  TenThousand
//
//  Weekly activity heatmap
//

import SwiftUI

struct HeatmapView: View {
    let data: [[Int64]]
    let levelForSeconds: (Int64) -> Int

    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]
    @State private var hoveredCell: (week: Int, day: Int)? = nil

    var body: some View {
        VStack(spacing: Spacing.base) {
            // Day labels
            HStack(spacing: Dimensions.heatmapGap) {
                ForEach(0..<7, id: \.self) { dayIndex in
                    Text(dayLabels[dayIndex])
                        .font(.system(size: 9, weight: .regular))
                        .foregroundColor(.secondary)
                        .frame(width: Dimensions.heatmapCellWidth)
                }
            }

            // Heatmap grid
            VStack(spacing: Dimensions.heatmapGap) {
                ForEach(0..<data.count, id: \.self) { weekIndex in
                    HStack(spacing: Dimensions.heatmapGap) {
                        ForEach(0..<7, id: \.self) { dayIndex in
                            let seconds = data[weekIndex][dayIndex]
                            let level = levelForSeconds(seconds)
                            let isHovered = hoveredCell?.week == weekIndex && hoveredCell?.day == dayIndex

                            RoundedRectangle(cornerRadius: Dimensions.heatmapCellRadius)
                                .fill(colorForLevel(level))
                                .frame(width: Dimensions.heatmapCellWidth, height: Dimensions.heatmapCellHeight)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Dimensions.heatmapCellRadius)
                                        .stroke(Color.primary.opacity(0.3), lineWidth: isHovered ? 1 : 0)
                                )
                                .scaleEffect(isHovered ? 1.05 : 1.0)
                                .animation(.hoverState, value: isHovered)
                                .onHover { hovering in
                                    if hovering {
                                        hoveredCell = (week: weekIndex, day: dayIndex)
                                    } else if hoveredCell?.week == weekIndex && hoveredCell?.day == dayIndex {
                                        hoveredCell = nil
                                    }
                                }
                                .help(tooltipText(weekIndex: weekIndex, dayIndex: dayIndex, seconds: seconds))
                        }
                    }
                }
            }
        }
        .padding(Spacing.loose)
        .frame(height: Dimensions.heatmapHeight)
        .background(
            Rectangle()
                .fill(Color.clear)
        )
        .overlay(
            Rectangle()
                .fill(Color.primary.opacity(0.05))
                .frame(height: 1),
            alignment: .top
        )
    }

    private func colorForLevel(_ level: Int) -> Color {
        switch level {
        case 0:
            return Color.primary.opacity(0.05)
        case 1:
            return Color.trackingBlue.opacity(0.10)
        case 2:
            return Color.trackingBlue.opacity(0.25)
        case 3:
            return Color.trackingBlue.opacity(0.40)
        case 4:
            return Color.trackingBlue.opacity(0.60)
        case 5:
            return Color.trackingBlue.opacity(0.80)
        case 6:
            return Color.trackingBlue
        default:
            return Color.clear
        }
    }

    private func tooltipText(weekIndex: Int, dayIndex: Int, seconds: Int64) -> String {
        let calendar = Calendar.current
        let today = Date()

        // Calculate the date for this cell
        // Heatmap shows the last 4 weeks, with most recent at bottom
        let totalDaysBack = (data.count - 1 - weekIndex) * 7 + (6 - dayIndex)
        guard let date = calendar.date(byAdding: .day, value: -totalDaysBack, to: today) else {
            return "No data"
        }

        // Format date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let dateString = formatter.string(from: date)

        // Format duration
        let durationString = seconds.formattedShortTime()

        if seconds == 0 {
            return "\(dateString)\nNo activity"
        } else {
            return "\(dateString)\n\(durationString)"
        }
    }
}
