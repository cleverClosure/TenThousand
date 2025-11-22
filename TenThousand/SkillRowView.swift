//
//  SkillRowView.swift
//  TenThousand
//
//  Individual skill row in the selector
//

import SwiftUI

struct SkillRowView: View {

    // MARK: - Properties

    let skill: Skill
    let onTap: () -> Void

    var isSelected: Bool = false
    var isHighlighted: Bool = false
    var canDelete: Bool = true
    var onDelete: (() -> Void)? = nil
    var onStartTracking: (() -> Void)? = nil

    // MARK: - Private State

    @State private var isHovered = false
    @State private var isFlashing = false
    @State private var isDotHovered = false

    // MARK: - Body

    var body: some View {
        Button(action: handleTap) {
            rowContent
        }
        .buttonStyle(PlainButtonStyle())
        .focusEffectDisabled()
        .contextMenu { contextMenuContent }
        .onHover { hovering in
            withAnimation(.hoverState) {
                isHovered = hovering
            }
        }
    }

    // MARK: - View Components

    private var rowContent: some View {
        HStack(spacing: Spacing.loose) {
            colorDot
            skillName
            Spacer()
            totalTime
        }
        .padding(.horizontal, Dimensions.skillRowPaddingHorizontal)
        .padding(.vertical, Dimensions.skillRowPaddingVertical)
        .frame(height: Dimensions.skillRowHeight)
        .background(backgroundColor, in: RoundedRectangle(cornerRadius: Dimensions.cornerRadiusSmall))
    }

    private var colorDot: some View {
        ZStack {
            Circle()
                .fill(skill.color)
                .frame(width: Dimensions.colorDotSize, height: Dimensions.colorDotSize)

            if isDotHovered {
                Circle()
                    .fill(Color.black.opacity(0.5))
                    .frame(width: Dimensions.colorDotSize, height: Dimensions.colorDotSize)

                Image(systemName: "play.fill")
                    .font(.system(size: 8))
                    .foregroundColor(.white)
            }
        }
        .onHover { hovering in
            withAnimation(.hoverState) {
                isDotHovered = hovering
            }
        }
        .contentShape(Circle())
        .onTapGesture {
            onStartTracking?()
        }
    }

    private var skillName: some View {
        Text(skill.name)
            .font(Typography.display)
            .kerning(Typography.displayKerning)
            .foregroundColor(.primary)
            .lineLimit(LayoutConstants.skillNameLineLimit)
    }

    private var totalTime: some View {
        Text(skill.totalSeconds.formattedShortTime())
            .font(Typography.caption)
            .foregroundColor(.secondary)
    }

    @ViewBuilder
    private var contextMenuContent: some View {
        if canDelete, let onDelete = onDelete {
            Button(action: onDelete) {
                Label("Delete Skill", systemImage: "trash")
            }
        }
    }

    // MARK: - Private Computed Properties

    private var backgroundColor: Color {
        if isFlashing {
            return Color.trackingBlue.opacity(Opacity.overlayMedium)
        } else if isHighlighted {
            return Color.highlightYellow.opacity(Opacity.overlayStrong)
        } else if isSelected {
            return Color.trackingBlue.opacity(Opacity.overlayLight)
        } else if isHovered {
            return Color.primary.opacity(Opacity.backgroundMedium)
        } else {
            return Color.clear
        }
    }

    // MARK: - Private Methods

    private func handleTap() {
        withAnimation(.linear(duration: AnimationDurations.flash)) {
            isFlashing = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationDurations.flash) {
            withAnimation(.linear(duration: AnimationDurations.flash)) {
                isFlashing = false
            }
        }
        onTap()
    }
}
