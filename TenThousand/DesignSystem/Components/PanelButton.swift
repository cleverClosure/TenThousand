//
//  PanelButton.swift
//  TenThousand
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
            return .red
        }
    }

    var restingBackgroundColor: Color {
        switch self {
        case .secondary:
            return Color.clear
        case .destructive:
            return Color.red.opacity(Opacity.backgroundMedium)
        }
    }

    var hoverBackgroundColor: Color {
        switch self {
        case .secondary:
            return Color.primary.opacity(Opacity.backgroundMedium)
        case .destructive:
            return Color.red.opacity(Opacity.overlayLight)
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
        isCompact ? Dimensions.compactButtonHeight : Dimensions.skillRowHeight
    }

    var body: some View {
        Button(action: action) {
            buttonContent
                .frame(maxWidth: .infinity)
                .padding(.horizontal, Dimensions.skillRowPaddingHorizontal)
                .padding(.vertical, isCompact ? Spacing.tight : Dimensions.skillRowPaddingVertical)
                .frame(height: buttonHeight)
                .background(backgroundColor, in: RoundedRectangle(cornerRadius: Dimensions.cornerRadiusSmall))
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
        .opacity(isDisabled ? Opacity.disabled : 1.0)
        .onHover { hovering in
            withAnimation(.hoverState) {
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
        HStack(spacing: Spacing.tight) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: Dimensions.iconSizeSmall))
                    .foregroundColor(variant.foregroundColor)
            }

            Text(title)
                .font(Typography.body)
                .foregroundColor(variant.foregroundColor)

            Spacer()

            if let shortcut = shortcut {
                Text(shortcut)
                    .font(Typography.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var centeredContent: some View {
        ZStack {
            HStack(spacing: Spacing.tight) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: Dimensions.iconSizeSmall))
                        .foregroundColor(variant.foregroundColor)
                }

                Text(title)
                    .font(Typography.body)
                    .foregroundColor(variant.foregroundColor)
            }

            if let shortcut = shortcut {
                HStack {
                    Spacer()
                    Text(shortcut)
                        .font(Typography.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private var backgroundColor: Color {
        guard !isDisabled else { return variant.restingBackgroundColor.opacity(Opacity.disabled) }
        return isHovered ? variant.hoverBackgroundColor : variant.restingBackgroundColor
    }
}
