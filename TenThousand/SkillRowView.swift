//
//  SkillRowView.swift
//  TenThousand
//
//  Individual skill row in the selector
//

import SwiftUI

struct SkillRowView: View {
    let skill: Skill
    var isSelected: Bool = false
    var isHighlighted: Bool = false
    let onTap: () -> Void

    @State private var isHovered = false
    @State private var isFlashing = false

    var body: some View {
        Button(action: {
            // Flash animation
            withAnimation(.linear(duration: 0.1)) {
                isFlashing = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.linear(duration: 0.1)) {
                    isFlashing = false
                }
            }
            onTap()
        }) {
            HStack(spacing: Spacing.loose) {
                // Color dot
                Circle()
                    .fill(colorForIndex(skill.colorIndex))
                    .frame(width: Dimensions.colorDotSize, height: Dimensions.colorDotSize)

                // Skill name
                Text(skill.name ?? "Untitled")
                    .font(Typography.display)
                    .kerning(Typography.displayKerning)
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
                ZStack {
                    // Base background
                    RoundedRectangle(cornerRadius: Dimensions.cornerRadiusSmall)
                        .fill(
                            isSelected ? Color.trackingBlue.opacity(Opacity.overlayLight) :
                            isHovered ? Color.primary.opacity(Opacity.backgroundMedium) : Color.clear
                        )

                    // Flash overlay (blue when tapped)
                    if isFlashing {
                        RoundedRectangle(cornerRadius: Dimensions.cornerRadiusSmall)
                            .fill(Color.trackingBlue.opacity(Opacity.overlayMedium))
                    }

                    // Highlight glow (yellow when just updated)
                    if isHighlighted {
                        RoundedRectangle(cornerRadius: Dimensions.cornerRadiusSmall)
                            .fill(Color("FFD60A").opacity(Opacity.overlayStrong))
                            .transition(.opacity)
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.hoverState) {
                isHovered = hovering
            }
        }
        .animation(.countUp, value: isHighlighted)
    }

    private func colorForIndex(_ index: Int16) -> Color {
        let colors: [Color] = [
            Color.trackingBlue,
            Color("FF3B30"),
            Color("FF9500"),
            Color("FFCC00"),
            Color("34C759"),
            Color("00C7BE"),
            Color("AF52DE"),
            Color("FF2D55")
        ]
        return colors[Int(index) % colors.count]
    }
}
