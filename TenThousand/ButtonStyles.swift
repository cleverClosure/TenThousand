//
//  ButtonStyles.swift
//  TenThousand
//
//  Author: Tim Isaev
//
//  Custom button styles with hover effects
//

import SwiftUI

// MARK: - IconButtonStyle

struct IconButtonStyle: ButtonStyle {
    @State private var isHovered = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(isHovered ? DS.Scale.hover : 1.0)
            .scaleEffect(configuration.isPressed ? DS.Scale.pressed : 1.0)
            .animation(.dsQuick, value: isHovered)
            .animation(.dsQuick, value: configuration.isPressed)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

// MARK: - PanelButtonStyle

struct PanelButtonStyle: ButtonStyle {
    @State private var isHovered = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.small)
                    .fill(isHovered ? DS.Color.background(.medium) : .clear)
            )
            .scaleEffect(configuration.isPressed ? DS.Scale.pressed : 1.0)
            .animation(.dsQuick, value: isHovered)
            .animation(.dsQuick, value: configuration.isPressed)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}
