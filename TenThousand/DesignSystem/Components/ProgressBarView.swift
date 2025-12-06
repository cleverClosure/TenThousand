//
//  ProgressBarView.swift
//  TenThousand
//
//  Author: Tim Isaev
//
//  Progress bar component for mastery tracking
//

import SwiftUI

struct ProgressBarView: View {
    // MARK: - Properties

    let progress: Double
    let color: Color
    var height: CGFloat = Dimensions.progressBarHeightMedium
    var showPercentage: Bool = false
    var animated: Bool = true

    // MARK: - Private State

    @State private var animatedProgress: Double = 0

    // MARK: - Private Computed Properties

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    private var displayProgress: Double {
        animated ? animatedProgress : clampedProgress
    }

    private var percentageText: String {
        let percentage = clampedProgress * 100
        if percentage < 0.1 {
            return String(format: "%.2f%%", percentage)
        } else if percentage < 1 {
            return String(format: "%.1f%%", percentage)
        } else {
            return String(format: "%.1f%%", percentage)
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: Spacing.tight) {
            progressBar

            if showPercentage {
                percentageLabel
            }
        }
        .onAppear {
            if animated {
                withAnimation(.easeOut(duration: 0.6)) {
                    animatedProgress = clampedProgress
                }
            }
        }
        .onChange(of: progress) { _, newValue in
            if animated {
                withAnimation(.easeOut(duration: 0.4)) {
                    animatedProgress = min(max(newValue, 0), 1)
                }
            }
        }
    }

    // MARK: - View Components

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track with subtle depth
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.primary.opacity(0.08))
                    .frame(height: height)
                    .overlay(
                        RoundedRectangle(cornerRadius: height / 2)
                            .stroke(Color.primary.opacity(0.03), lineWidth: 0.5)
                    )

                // Filled progress with gradient
                if displayProgress > 0 {
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.85)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(progressWidth(in: geometry), height), height: height)
                        .shadow(color: color.opacity(0.3), radius: height / 2, y: 0)
                }
            }
        }
        .frame(height: height)
    }

    private var percentageLabel: some View {
        HStack {
            Text(percentageText)
                .font(Typography.caption)
                .foregroundColor(color)
                .contentTransition(.numericText())
            Spacer()
        }
    }

    // MARK: - Private Methods

    private func progressWidth(in geometry: GeometryProxy) -> CGFloat {
        geometry.size.width * displayProgress
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 24) {
        ProgressBarView(progress: 0.005, color: .blue, showPercentage: true)
        ProgressBarView(progress: 0.125, color: .green, height: 8, showPercentage: true)
        ProgressBarView(progress: 0.50, color: .orange, height: 10, showPercentage: true)
        ProgressBarView(progress: 1.0, color: .red, height: 6)
    }
    .padding(24)
    .frame(width: 320)
    .background(Color(.windowBackgroundColor))
}
