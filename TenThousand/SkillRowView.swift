//
//  SkillRowView.swift
//  TenThousand
//
//  Author: Tim Isaev
//
//  Individual skill row in the selector - two-line layout with prominent progress
//

import SwiftUI

struct SkillRowView: View {
    // MARK: - Properties

    let skill: Skill
    let onTap: () -> Void

    var isSelected: Bool = false
    var isHighlighted: Bool = false
    var canDelete: Bool = true
    var onDelete: (() -> Void)?
    var onEdit: (() -> Void)?
    var onStartTracking: (() -> Void)?

    // MARK: - Private State

    @State private var isHovered = false
    @State private var isFlashing = false
    @State private var isDotHovered = false

    // MARK: - Private Computed Properties

    private var percentageText: String {
        let percentage = skill.masteryPercentage
        if percentage < 0.1 {
            return String(format: "%.2f%%", percentage)
        } else if percentage < 1 {
            return String(format: "%.1f%%", percentage)
        } else {
            return String(format: "%.1f%%", percentage)
        }
    }

    private var backgroundColor: Color {
        if isFlashing {
            return skill.color.opacity(0.15)
        } else if isHighlighted {
            return Color.highlightYellow.opacity(0.2)
        } else if isSelected {
            return skill.color.opacity(0.1)
        } else if isHovered {
            return skill.color.opacity(0.06)
        } else {
            return Color.primary.opacity(0.02)
        }
    }

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
        VStack(alignment: .leading, spacing: Spacing.base) {
            // Top row: color dot, name, time
            HStack(spacing: Spacing.loose) {
                colorDot
                VStack(alignment: .leading, spacing: Spacing.atomic) {
                    skillName
                    timeLabel
                }
                Spacer()
                if isHovered {
                    editButton
                }
                chevron
            }

            // Bottom: progress bar with percentage
            HStack(spacing: Spacing.base) {
                ProgressBarView(
                    progress: skill.masteryProgress,
                    color: skill.color,
                    height: Dimensions.progressBarHeightSmall,
                    animated: false
                )

                Text(percentageText)
                    .font(Typography.caption)
                    .foregroundColor(skill.color)
                    .frame(width: Dimensions.percentageFrameWidth, alignment: .trailing)
            }
        }
        .padding(.horizontal, Dimensions.skillRowPaddingHorizontal)
        .padding(.vertical, Dimensions.skillRowPaddingVertical)
        .background(
            RoundedRectangle(cornerRadius: Dimensions.cornerRadiusMedium)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Dimensions.cornerRadiusMedium)
                .stroke(isSelected ? skill.color.opacity(0.3) : Color.clear, lineWidth: LayoutConstants.borderWidth)
        )
    }

    private var colorDot: some View {
        ZStack {
            Circle()
                .fill(skill.color)
                .frame(width: Dimensions.colorDotSize, height: Dimensions.colorDotSize)
                .shadow(color: skill.color.opacity(Shadows.medium.opacity), radius: Shadows.medium.radius, y: Shadows.medium.yOffset)

            if isDotHovered {
                Circle()
                    .fill(Color.black.opacity(0.4))
                    .frame(width: Dimensions.colorDotSize, height: Dimensions.colorDotSize)

                Image(systemName: "play.fill")
                    .font(.system(size: IconFontSize.small, weight: .bold))
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
            .displayFont()
            .foregroundColor(.primary)
            .lineLimit(LayoutConstants.skillNameLineLimit)
    }

    private var timeLabel: some View {
        Text("\(skill.totalSeconds.formattedShortTime()) tracked")
            .font(Typography.caption)
            .foregroundColor(.secondary)
    }

    private var editButton: some View {
        Button {
            onEdit?()
        } label: {
            Image(systemName: "pencil")
                .font(.system(size: IconFontSize.body, weight: .medium))
                .foregroundColor(.secondary)
                .padding(Spacing.base)
                .background(
                    Circle()
                        .fill(Color.primary.opacity(0.08))
                )
        }
        .buttonStyle(PlainButtonStyle())
        .transition(.scale.combined(with: .opacity))
        .onTapGesture {} // Prevent tap from propagating to row
    }

    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: IconFontSize.body, weight: .semibold))
            .foregroundColor(.secondary.opacity(isHovered ? 1 : 0.5))
    }

    @ViewBuilder
    private var contextMenuContent: some View {
        if let onEdit = onEdit {
            Button(action: onEdit) {
                Label("Edit Skill", systemImage: "pencil")
            }
        }
        if canDelete, let onDelete = onDelete {
            Button(action: onDelete) {
                Label("Delete Skill", systemImage: "trash")
            }
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
