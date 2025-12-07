//
//  CircularProgressView.swift
//  TenThousand
//
//  Author: Tim Isaev
//
//  Circular progress ring for hero mastery display
//

import SwiftUI

struct CircularProgressView: View {
    // MARK: - Properties

    let progress: Double
    let color: Color
    var size: CGFloat = DS.Size.circularProgress
    var strokeWidth: CGFloat = DS.Size.circularStroke
    var showValue: Bool = true
    var valueText: String = ""
    var labelText: String = ""

    // MARK: - Private Constants

    private let trackOffset: CGFloat = 2
    private let shadowOffset: CGFloat = 4
    private let valueFontRatio: CGFloat = 0.32
    private let labelFontRatio: CGFloat = 0.085

    // MARK: - Private State

    @State private var animatedProgress: Double = 0

    // MARK: - Private Computed Properties

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    private var trackWidth: CGFloat {
        strokeWidth + trackOffset
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Outer subtle shadow ring
            Circle()
                .stroke(Color.black.opacity(0.05), lineWidth: trackWidth + shadowOffset)
                .blur(radius: 2)

            // Background track
            Circle()
                .stroke(Color.primary.opacity(DS.Opacity.medium), lineWidth: trackWidth)

            // Inner shadow on track
            Circle()
                .stroke(Color.black.opacity(0.08), lineWidth: trackWidth)
                .blur(radius: 1)
                .mask(
                    Circle()
                        .stroke(lineWidth: trackWidth)
                )

            // Progress arc
            if animatedProgress > 0 {
                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(
                        LinearGradient(
                            colors: [color, color.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: color.opacity(DS.Opacity.strong), radius: DS.Shadow.glow.radius, y: 0)
            }

            // Center content
            if showValue {
                VStack(spacing: DS.Spacing.xs) {
                    Text(valueText)
                        .font(.system(size: size * valueFontRatio, weight: .medium, design: .rounded))
                        .foregroundColor(.primary)
                        .contentTransition(.numericText())

                    if !labelText.isEmpty {
                        Text(labelText)
                            .font(.system(size: size * labelFontRatio, weight: .semibold))
                            .tracking(2)
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                }
                .offset(y: labelText.isEmpty ? 0 : trackOffset)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeOut(duration: DS.Duration.slow + 0.2)) {
                animatedProgress = clampedProgress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeOut(duration: DS.Duration.emphasized)) {
                animatedProgress = min(max(newValue, 0), 1)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        CircularProgressView(
            progress: 0.007,
            color: .red,
            valueText: "25.4",
            labelText: "HOURS"
        )

        CircularProgressView(
            progress: 0.25,
            color: .blue,
            valueText: "2,500",
            labelText: "HOURS"
        )

        CircularProgressView(
            progress: 0.75,
            color: .green,
            size: 120,
            strokeWidth: 8,
            valueText: "75%",
            labelText: ""
        )
    }
    .padding(40)
    .background(Color(.windowBackgroundColor))
}
