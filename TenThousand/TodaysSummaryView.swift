//
//  TodaysSummaryView.swift
//  TenThousand
//
//  Today's tracking summary
//

import SwiftUI

struct TodaysSummaryView: View {
    let totalSeconds: Int64
    let skillCount: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Today")
                    .font(Typography.body)
                    .kerning(Typography.bodyKerning)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Text("\(skillCount) skill\(skillCount == 1 ? "" : "s") tracked")
                    .font(Typography.caption)
                    .kerning(Typography.captionKerning)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(totalSeconds.formattedShortTime())
                .font(Typography.timeDisplay)
                .kerning(Typography.timeDisplayKerning)
                .monospacedDigit()
                .foregroundColor(.primary)
        }
        .padding(Spacing.loose)
        .frame(height: Dimensions.todaySummaryHeight)
        .background(
            Rectangle()
                .fill(Color.primary.opacity(Opacity.backgroundSubtle))
        )
        .overlay(
            Rectangle()
                .fill(Color.primary.opacity(Opacity.backgroundMedium))
                .frame(height: Dimensions.dividerHeight),
            alignment: .top
        )
    }
}
