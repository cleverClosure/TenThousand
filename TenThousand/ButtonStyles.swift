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
            .scaleEffect(isHovered ? ScaleValues.hoverGrow : ScaleValues.normal)
            .scaleEffect(configuration.isPressed ? ScaleValues.pressedShrink : ScaleValues.normal)
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
            .scaleEffect(configuration.isPressed ? ScaleValues.pressedShrink : ScaleValues.normal)
            .animation(.hoverState, value: isHovered)
            .animation(.microInteraction, value: configuration.isPressed)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}
