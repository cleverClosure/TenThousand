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

    private let dayLabels = CalendarConstants.dayLabels
    @State private var hoveredCell: (week: Int, day: Int)? = nil

    var body: some View {
        VStack(spacing: Spacing.base) {
            // Day labels
            HStack(spacing: Dimensions.heatmapGap) {
                ForEach(0..<CalendarConstants.daysPerWeek, id: \.self) { dayIndex in
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
                        ForEach(0..<CalendarConstants.daysPerWeek, id: \.self) { dayIndex in
                            let seconds = data[weekIndex][dayIndex]
                            let level = levelForSeconds(seconds)
                            let isHovered = hoveredCell?.week == weekIndex && hoveredCell?.day == dayIndex

                            RoundedRectangle(cornerRadius: Dimensions.heatmapCellRadius)
                                .fill(colorForLevel(level))
                                .frame(width: Dimensions.heatmapCellWidth, height: Dimensions.heatmapCellHeight)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Dimensions.heatmapCellRadius)
                                        .stroke(Color.primary.opacity(Opacity.borderSubtle), lineWidth: isHovered ? LayoutConstants.borderWidth : 0)
                                )
                                .scaleEffect(isHovered ? ScaleValues.hoverGrow : ScaleValues.normal)
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
                .fill(Color.primary.opacity(Opacity.backgroundMedium))
                .frame(height: Dimensions.dividerHeight),
            alignment: .top
        )
    }

    private func colorForLevel(_ level: Int) -> Color {
        switch level {
        case 0:
            return Color.primary.opacity(Opacity.heatmapLevel0)
        case 1:
            return Color.trackingBlue.opacity(Opacity.heatmapLevel1)
        case 2:
            return Color.trackingBlue.opacity(Opacity.heatmapLevel2)
        case 3:
            return Color.trackingBlue.opacity(Opacity.heatmapLevel3)
        case 4:
            return Color.trackingBlue.opacity(Opacity.heatmapLevel4)
        case 5:
            return Color.trackingBlue.opacity(Opacity.heatmapLevel5)
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
        let totalDaysBack = (data.count - 1 - weekIndex) * CalendarConstants.daysPerWeek + (CalendarConstants.daysPerWeek - 1 - dayIndex)
        guard let date = calendar.date(byAdding: .day, value: -totalDaysBack, to: today) else {
            return UIText.noDataText
        }

        // Format date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let dateString = formatter.string(from: date)

        // Format duration
        let durationString = seconds.formattedShortTime()

        if seconds == 0 {
            return "\(dateString)\n\(UIText.noActivityText)"
        } else {
            return "\(dateString)\n\(durationString)"
        }
    }
}
