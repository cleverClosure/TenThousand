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

                            RoundedRectangle(cornerRadius: Dimensions.heatmapCellRadius)
                                .fill(colorForLevel(level))
                                .frame(width: Dimensions.heatmapCellWidth, height: Dimensions.heatmapCellHeight)
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
}
