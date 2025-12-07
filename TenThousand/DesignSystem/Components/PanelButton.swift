//
//  PanelButton.swift
//  TenThousand
//
//  Author: Tim Isaev
//
//  Reusable button component for panel actions
//

import SwiftUI

// MARK: - Button Variant

enum ButtonVariant {
    case secondary
    case destructive

    var foregroundColor: Color {
        switch self {
        case .secondary:
            return .secondary
        case .destructive:
            return DS.Color.error
        }
    }

    var restingBackgroundColor: Color {
        switch self {
        case .secondary:
            return .clear
        case .destructive:
            return DS.Color.error.opacity(DS.Opacity.subtle)
        }
    }

    var hoverBackgroundColor: Color {
        switch self {
        case .secondary:
            return DS.Color.background(.medium)
        case .destructive:
            return DS.Color.error.opacity(DS.Opacity.medium)
        }
    }
}

// MARK: - Panel Button

enum ButtonAlignment {
    case leading
    case center
}

struct PanelButton: View {
    let title: String
    let icon: String?
    let variant: ButtonVariant
    let alignment: ButtonAlignment
    let shortcut: String?
    let isDisabled: Bool
    let isCompact: Bool
    let action: () -> Void

    @State private var isHovered = false

    init(
        _ title: String,
        icon: String? = nil,
        variant: ButtonVariant = .secondary,
        alignment: ButtonAlignment = .center,
        shortcut: String? = nil,
        isDisabled: Bool = false,
        isCompact: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.variant = variant
        self.alignment = alignment
        self.shortcut = shortcut
        self.isDisabled = isDisabled
        self.isCompact = isCompact
        self.action = action
    }

    private var buttonHeight: CGFloat {
        isCompact ? DS.Size.buttonHeight : DS.Size.skillRowHeight
    }

    var body: some View {
        Button(action: action) {
            buttonContent
                .frame(maxWidth: .infinity)
                .padding(.horizontal, DS.Spacing.md)
                .padding(.vertical, isCompact ? DS.Spacing.xs : DS.Spacing.sm)
                .frame(height: buttonHeight)
                .background(backgroundColor, in: RoundedRectangle(cornerRadius: DS.Radius.small))
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
        .opacity(isDisabled ? DS.Opacity.muted : 1.0)
        .onHover { hovering in
            withAnimation(.dsQuick) {
                isHovered = hovering
            }
        }
    }

    @ViewBuilder
    private var buttonContent: some View {
        switch alignment {
        case .leading:
            leadingContent
        case .center:
            centeredContent
        }
    }

    private var leadingContent: some View {
        HStack(spacing: DS.Spacing.xs) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: DS.Size.iconSmall))
                    .foregroundColor(variant.foregroundColor)
            }

            Text(title)
                .font(DS.Font.body)
                .foregroundColor(variant.foregroundColor)

            Spacer()

            if let shortcut = shortcut {
                Text(shortcut)
                    .font(DS.Font.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var centeredContent: some View {
        ZStack {
            HStack(spacing: DS.Spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: DS.Size.iconSmall))
                        .foregroundColor(variant.foregroundColor)
                }

                Text(title)
                    .font(DS.Font.body)
                    .foregroundColor(variant.foregroundColor)
            }

            if let shortcut = shortcut {
                HStack {
                    Spacer()
                    Text(shortcut)
                        .font(DS.Font.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private var backgroundColor: Color {
        guard !isDisabled else { return variant.restingBackgroundColor.opacity(DS.Opacity.muted) }
        return isHovered ? variant.hoverBackgroundColor : variant.restingBackgroundColor
    }
}
