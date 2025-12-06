//
//  PanelContainer.swift
//  TenThousand
//
//  Author: Tim Isaev
//
//  Reusable container providing consistent panel styling
//

import AppKit
import SwiftUI

// MARK: - PanelContainer

/// A styled container for panel content with background blur, border, and shadow.
struct PanelContainer<Content: View>: View {
    // MARK: - Properties

    let content: Content

    // MARK: - Initialization

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    // MARK: - Body

    var body: some View {
        content
            .frame(width: Dimensions.panelWidth)
            .background(backgroundView)
            .clipShape(RoundedRectangle(cornerRadius: Dimensions.panelCornerRadius))
            .overlay(overlayBorder)
            .shadow(
                color: shadowColor,
                radius: Shadows.floating.radius,
                x: Shadows.floating.xOffset,
                y: Shadows.floating.yOffset
            )
    }

    // MARK: - Private Views

    private var backgroundView: some View {
        VisualEffectBlur(material: .menu, blendingMode: .behindWindow)
    }

    private var overlayBorder: some View {
        RoundedRectangle(cornerRadius: Dimensions.panelCornerRadius)
            .stroke(Color.primary.opacity(Opacity.backgroundMedium), lineWidth: LayoutConstants.borderWidth)
    }

    private var shadowColor: Color {
        Color.black.opacity(Shadows.floating.opacity)
    }
}

// MARK: - VisualEffectBlur

/// NSVisualEffectView wrapper for SwiftUI
struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
