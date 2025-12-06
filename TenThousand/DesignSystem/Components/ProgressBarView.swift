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
    var height: CGFloat = 4
    var showPercentage: Bool = false

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.primary.opacity(Opacity.backgroundMedium))
                    .frame(height: height)

                // Filled progress
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(color)
                    .frame(width: progressWidth(in: geometry), height: height)
            }
        }
        .frame(height: height)
    }

    // MARK: - Private Methods

    private func progressWidth(in geometry: GeometryProxy) -> CGFloat {
        let clampedProgress = min(max(progress, 0), 1)
        return geometry.size.width * clampedProgress
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        ProgressBarView(progress: 0.05, color: .blue)
        ProgressBarView(progress: 0.25, color: .green, height: 6)
        ProgressBarView(progress: 0.75, color: .orange, height: 8)
        ProgressBarView(progress: 1.0, color: .red)
    }
    .padding()
    .frame(width: 280)
}
