//
//  Typography.swift
//  TenThousand
//
//  Font styles and text modifiers
//

import SwiftUI

// MARK: - Typography Definitions

struct Typography {
    static let display = Font.system(size: 16, weight: .medium, design: .default)
    static let displayKerning: CGFloat = -0.3
    static let displayLineHeight: CGFloat = 20

    static let body = Font.system(size: 13, weight: .regular, design: .default)
    static let bodyKerning: CGFloat = -0.08
    static let bodyLineHeight: CGFloat = 16

    static let caption = Font.system(size: 11, weight: .regular, design: .default)
    static let captionKerning: CGFloat = 0
    static let captionLineHeight: CGFloat = 13

    static let timeDisplay = Font.system(size: 14, weight: .medium, design: .monospaced)
        .monospacedDigit()
    static let timeDisplayKerning: CGFloat = 0.5
    static let timeDisplayLineHeight: CGFloat = 16

    static let largeTimeDisplay = Font.system(size: 20, weight: .medium, design: .monospaced)
        .monospacedDigit()
    static let largeTimeDisplayKerning: CGFloat = 0.5
    static let largeTimeDisplayLineHeight: CGFloat = 24
}

// MARK: - Typography View Modifiers

extension View {
    func displayFont() -> some View {
        self
            .font(Typography.display)
            .kerning(Typography.displayKerning)
            .lineSpacing(Typography.displayLineHeight - 16)
    }

    func bodyFont() -> some View {
        self
            .font(Typography.body)
            .kerning(Typography.bodyKerning)
            .lineSpacing(Typography.bodyLineHeight - 13)
    }

    func captionFont() -> some View {
        self
            .font(Typography.caption)
            .kerning(Typography.captionKerning)
            .lineSpacing(Typography.captionLineHeight - 11)
    }

    func timeDisplayFont() -> some View {
        self
            .font(Typography.timeDisplay)
            .kerning(Typography.timeDisplayKerning)
            .lineSpacing(Typography.timeDisplayLineHeight - 14)
            .monospacedDigit()
    }

    func largeTimeDisplayFont() -> some View {
        self
            .font(Typography.largeTimeDisplay)
            .kerning(Typography.largeTimeDisplayKerning)
            .lineSpacing(Typography.largeTimeDisplayLineHeight - 20)
            .monospacedDigit()
    }
}
