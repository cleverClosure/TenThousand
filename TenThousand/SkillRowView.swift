//
//  SkillRowView.swift
//  TenThousand
//
//  Individual skill row in the selector
//

import SwiftUI

struct SkillRowView: View {
    let skill: Skill
    let onTap: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.loose) {
                // Color dot
                Circle()
                    .fill(colorForIndex(skill.colorIndex))
                    .frame(width: Dimensions.colorDotSize, height: Dimensions.colorDotSize)

                // Skill name
                Text(skill.name ?? "Untitled")
                    .font(Typography.display)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Spacer()

                // Total time
                Text(skill.totalSeconds.formattedShortTime())
                    .font(Typography.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, Dimensions.skillRowPaddingHorizontal)
            .padding(.vertical, Dimensions.skillRowPaddingVertical)
            .frame(height: Dimensions.skillRowHeight)
            .background(
                RoundedRectangle(cornerRadius: Dimensions.cornerRadiusSmall)
                    .fill(isHovered ? Color.primary.opacity(0.05) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.hoverState) {
                isHovered = hovering
            }
        }
    }

    private func colorForIndex(_ index: Int16) -> Color {
        let colors: [Color] = [
            Color.trackingBlue,
            Color(hex: "FF3B30"),
            Color(hex: "FF9500"),
            Color(hex: "FFCC00"),
            Color(hex: "34C759"),
            Color(hex: "00C7BE"),
            Color(hex: "AF52DE"),
            Color(hex: "FF2D55")
        ]
        return colors[Int(index) % colors.count]
    }
}
