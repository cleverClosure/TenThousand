//
//  CircularProgressView.swift
//  TenThousand
//
//  Author: Tim Isaev
//
//  Circular progress ring for hero mastery display - refined aesthetic
//

import SwiftUI

struct CircularProgressView: View {
    // MARK: - Properties

    let progress: Double
    let color: Color
    var size: CGFloat = Dimensions.circularProgressSize
    var strokeWidth: CGFloat = Dimensions.circularProgressStroke
    var showValue: Bool = true
    var valueText: String = ""
    var labelText: String = ""

    // MARK: - Private State

    @State private var animatedProgress: Double = 0

    // MARK: - Private Computed Properties

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    private var trackWidth: CGFloat {
        strokeWidth + Dimensions.circularProgressTrackOffset
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Outer subtle shadow ring (depth)
            Circle()
                .stroke(Color.overlayDark.opacity(0.05), lineWidth: trackWidth + Dimensions.circularProgressShadowOffset)
                .blur(radius: Shadows.subtle.radius)

            // Background track - inset style
            Circle()
                .stroke(Color.backgroundPrimary(.regular), lineWidth: trackWidth)

            // Inner shadow on track
            Circle()
                .stroke(Color.overlayDark.opacity(0.08), lineWidth: trackWidth)
                .blur(radius: 1)
                .mask(
                    Circle()
                        .stroke(lineWidth: trackWidth)
                )

            // Progress arc - clean gradient
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
                    .shadow(color: color.opacity(Shadows.progressGlow.opacity), radius: Shadows.progressGlow.radius, y: Shadows.progressGlow.yOffset)
            }

            // Center content
            if showValue {
                VStack(spacing: Spacing.tight) {
                    Text(valueText)
                        .font(.system(size: size * CircularProgressSizing.valueFontRatio, weight: .medium, design: .rounded))
                        .foregroundColor(.primary)
                        .contentTransition(.numericText())

                    if !labelText.isEmpty {
                        Text(labelText)
                            .font(.system(size: size * CircularProgressSizing.labelFontRatio, weight: .semibold))
                            .tracking(2)
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                }
                .offset(y: labelText.isEmpty ? 0 : Dimensions.circularProgressTrackOffset)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeOut(duration: AnimationDurations.circularAppear)) {
                animatedProgress = clampedProgress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeOut(duration: AnimationDurations.circularUpdate)) {
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
