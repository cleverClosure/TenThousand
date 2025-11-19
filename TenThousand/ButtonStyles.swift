//
//  ButtonStyles.swift
//  TenThousand
//
//  Custom button styles with hover effects
//

import SwiftUI

struct IconButtonStyle: ButtonStyle {
    @State private var isHovered = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.hoverState, value: isHovered)
            .animation(.microInteraction, value: configuration.isPressed)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

struct PanelButtonStyle: ButtonStyle {
    @State private var isHovered = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: Dimensions.cornerRadiusSmall)
                    .fill(isHovered ? Color.primary.opacity(Opacity.backgroundMedium) : Color.clear)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.hoverState, value: isHovered)
            .animation(.microInteraction, value: configuration.isPressed)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}
