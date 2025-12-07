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
            return skill.color.opacity(DS.Opacity.strong)
        } else if isHighlighted {
            return DS.Color.accent.opacity(0.2)
        } else if isSelected {
            return skill.color.opacity(DS.Opacity.medium)
        } else if isHovered {
            return skill.color.opacity(DS.Opacity.light)
        } else {
            return DS.Color.background(.subtle)
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
            withAnimation(.dsQuick) {
                isHovered = hovering
            }
        }
    }

    // MARK: - View Components

    private var rowContent: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            // Top row: color dot, name, time
            HStack(spacing: DS.Spacing.md) {
                colorDot
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
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
            HStack(spacing: DS.Spacing.sm) {
                ProgressBarView(
                    progress: skill.masteryProgress,
                    color: skill.color,
                    height: 4,
                    animated: false
                )

                Text(percentageText)
                    .font(DS.Font.caption)
                    .foregroundColor(skill.color)
                    .frame(width: DS.Size.percentageLabel, alignment: .trailing)
            }
        }
        .padding(.horizontal, DS.Spacing.md)
        .padding(.vertical, DS.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.medium)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.medium)
                .stroke(isSelected ? skill.color.opacity(DS.Opacity.overlay) : .clear, lineWidth: 1)
        )
    }

    private var colorDot: some View {
        ZStack {
            Circle()
                .fill(skill.color)
                .frame(width: DS.Size.colorDot, height: DS.Size.colorDot)
                .shadow(color: skill.color.opacity(DS.Shadow.elevated.opacity), radius: DS.Shadow.elevated.radius, y: DS.Shadow.elevated.y)

            if isDotHovered {
                Circle()
                    .fill(Color.black.opacity(DS.Opacity.overlayDark))
                    .frame(width: DS.Size.colorDot, height: DS.Size.colorDot)

                Image(systemName: "play.fill")
                    .iconFont(.small, weight: .bold)
                    .foregroundColor(.white)
            }
        }
        .onHover { hovering in
            withAnimation(.dsQuick) {
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
            .titleFont()
            .foregroundColor(.primary)
            .lineLimit(1)
    }

    private var timeLabel: some View {
        Text("\(skill.totalSeconds.formattedShortTime()) tracked")
            .font(DS.Font.caption)
            .foregroundColor(.secondary)
    }

    private var editButton: some View {
        Button {
            onEdit?()
        } label: {
            Image(systemName: "pencil")
                .iconFont(.body)
                .foregroundColor(.secondary)
                .padding(DS.Spacing.sm)
                .background(
                    Circle()
                        .fill(DS.Color.background(.medium))
                )
        }
        .buttonStyle(PlainButtonStyle())
        .transition(.scale.combined(with: .opacity))
        .onTapGesture {} // Prevent tap from propagating to row
    }

    private var chevron: some View {
        Image(systemName: "chevron.right")
            .iconFont(.body, weight: .semibold)
            .foregroundColor(.secondary.opacity(isHovered ? 1 : DS.Opacity.muted))
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
        withAnimation(.linear(duration: DS.Duration.quick)) {
            isFlashing = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + DS.Duration.quick) {
            withAnimation(.linear(duration: DS.Duration.quick)) {
                isFlashing = false
            }
        }
        onTap()
    }
}
