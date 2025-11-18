//
//  ModernProgressBar.swift
//  TenThousand
//
//  Created by Tim Isaev on 18.11.2025.
//

import SwiftUI

struct ModernProgressBar: View {
    let progress: Double  // 0.0 to 100.0
    let accentColor: Color
    let showPercentage: Bool
    let isActive: Bool  // For tracking state animation

    init(
        progress: Double,
        accentColor: Color,
        showPercentage: Bool = true,
        isActive: Bool = false
    ) {
        self.progress = progress
        self.accentColor = accentColor
        self.showPercentage = showPercentage
        self.isActive = isActive
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: Constants.progressBarRadius)
                        .fill(Color(nsColor: .separatorColor).opacity(0.3))
                        .frame(height: Constants.progressBarHeight)

                    // Fill
                    RoundedRectangle(cornerRadius: Constants.progressBarRadius)
                        .fill(accentColor)
                        .frame(
                            width: geometry.size.width * min(progress / 100.0, 1.0),
                            height: Constants.progressBarHeight
                        )
                        .animation(.easeOut(duration: 0.5), value: progress)
                        .opacity(isActive ? 0.9 : 1.0)
                        .animation(
                            isActive ? .easeInOut(duration: 2.0).repeatForever(autoreverses: true) : .default,
                            value: isActive
                        )
                }
            }
            .frame(height: Constants.progressBarHeight)

            // Percentage text
            if showPercentage {
                HStack {
                    Spacer()
                    Text(String(format: "%.1f%%", min(progress, 100.0)))
                        .font(.system(size: Constants.fontSize_caption))
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ModernProgressBar(
            progress: 12.3,
            accentColor: Color(hex: "#6366F1") ?? .blue,
            showPercentage: true
        )

        ModernProgressBar(
            progress: 45.7,
            accentColor: Color(hex: "#10B981") ?? .green,
            showPercentage: true,
            isActive: true
        )

        ModernProgressBar(
            progress: 89.2,
            accentColor: Color(hex: "#F59E0B") ?? .orange,
            showPercentage: true
        )
    }
    .frame(width: 320)
    .padding()
}
