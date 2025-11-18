//
//  TextProgressBar.swift
//  TenThousand
//
//  Created by Tim Isaev on 18.11.2025.
//

import SwiftUI

/// A retro-style text-based progress bar using block characters
/// Example: [████░░░░░░░░░░░░░░] 1.2%
struct TextProgressBar: View {
    let progress: Double  // 0-100
    var totalBlocks: Int = 20
    var filledChar: String = "█"
    var emptyChar: String = "░"
    var showPercentage: Bool = true
    var showBrackets: Bool = true
    var color: Color = .primary
    var fontSize: CGFloat = 11

    private var filledBlocks: Int {
        Int((progress / 100.0) * Double(totalBlocks))
    }

    private var emptyBlocks: Int {
        totalBlocks - filledBlocks
    }

    var body: some View {
        HStack(spacing: 4) {
            // Progress bar
            HStack(spacing: 0) {
                if showBrackets {
                    Text("[")
                        .font(.system(size: fontSize, weight: .medium, design: .monospaced))
                        .foregroundColor(color.opacity(0.6))
                }

                // Filled portion
                if filledBlocks > 0 {
                    Text(String(repeating: filledChar, count: filledBlocks))
                        .font(.system(size: fontSize, weight: .bold, design: .monospaced))
                        .foregroundColor(color)
                }

                // Empty portion
                if emptyBlocks > 0 {
                    Text(String(repeating: emptyChar, count: emptyBlocks))
                        .font(.system(size: fontSize, weight: .light, design: .monospaced))
                        .foregroundColor(color.opacity(0.3))
                }

                if showBrackets {
                    Text("]")
                        .font(.system(size: fontSize, weight: .medium, design: .monospaced))
                        .foregroundColor(color.opacity(0.6))
                }
            }

            // Percentage
            if showPercentage {
                Text(String(format: "%.1f%%", min(progress, 100.0)))
                    .font(.system(size: fontSize, weight: .medium, design: .monospaced))
                    .foregroundColor(color.opacity(0.8))
                    .frame(minWidth: 40, alignment: .leading)
            }
        }
    }
}

/// Enhanced version with gradient colors and animations
struct AnimatedTextProgressBar: View {
    let progress: Double
    var totalBlocks: Int = 20
    var showPercentage: Bool = true
    var accentColor: Color

    @State private var animatedProgress: Double = 0

    private var filledBlocks: Int {
        Int((animatedProgress / 100.0) * Double(totalBlocks))
    }

    private var emptyBlocks: Int {
        totalBlocks - filledBlocks
    }

    // Color gradient based on progress
    private var progressColor: Color {
        if progress < 20 {
            return .red
        } else if progress < 50 {
            return .orange
        } else if progress < 80 {
            return .yellow
        } else {
            return .green
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            // Progress bar with gradient effect
            HStack(spacing: 0) {
                Text("[")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)

                // Filled portion with color
                if filledBlocks > 0 {
                    Text(String(repeating: "█", count: filledBlocks))
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(accentColor)
                }

                // Empty portion
                if emptyBlocks > 0 {
                    Text(String(repeating: "░", count: emptyBlocks))
                        .font(.system(size: 11, weight: .light, design: .monospaced))
                        .foregroundColor(Color.secondary.opacity(0.3))
                }

                Text("]")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            // Percentage with color
            if showPercentage {
                Text(String(format: "%.1f%%", min(animatedProgress, 100.0)))
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(accentColor)
                    .frame(minWidth: 45, alignment: .leading)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { oldValue, newValue in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                animatedProgress = newValue
            }
        }
    }
}

/// Compact mini version for tight spaces
struct MiniTextProgressBar: View {
    let progress: Double
    var totalBlocks: Int = 10
    var color: Color = .primary

    private var filledBlocks: Int {
        Int((progress / 100.0) * Double(totalBlocks))
    }

    var body: some View {
        HStack(spacing: 2) {
            Text("[")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(color.opacity(0.5))

            if filledBlocks > 0 {
                Text(String(repeating: "▰", count: filledBlocks))
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(color)
            }

            if totalBlocks - filledBlocks > 0 {
                Text(String(repeating: "▱", count: totalBlocks - filledBlocks))
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(color.opacity(0.2))
            }

            Text("]")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(color.opacity(0.5))

            Text(String(format: "%.0f%%", progress))
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(color.opacity(0.7))
        }
    }
}

// MARK: - Previews

#Preview("Standard Progress Bars") {
    VStack(alignment: .leading, spacing: 16) {
        Text("Text Progress Bars")
            .font(.headline)

        Divider()

        // Various progress levels
        VStack(alignment: .leading, spacing: 8) {
            Text("Standard Style")
                .font(.caption)
                .foregroundColor(.secondary)

            TextProgressBar(progress: 1.2, color: .blue)
            TextProgressBar(progress: 12.3, color: .green)
            TextProgressBar(progress: 45.6, color: .orange)
            TextProgressBar(progress: 78.9, color: .purple)
            TextProgressBar(progress: 99.5, color: .red)
        }

        Divider()

        // Animated versions
        VStack(alignment: .leading, spacing: 8) {
            Text("Animated Style")
                .font(.caption)
                .foregroundColor(.secondary)

            AnimatedTextProgressBar(progress: 5.0, accentColor: .red)
            AnimatedTextProgressBar(progress: 25.0, accentColor: .orange)
            AnimatedTextProgressBar(progress: 50.0, accentColor: .yellow)
            AnimatedTextProgressBar(progress: 85.0, accentColor: .green)
        }

        Divider()

        // Mini versions
        VStack(alignment: .leading, spacing: 8) {
            Text("Mini Style")
                .font(.caption)
                .foregroundColor(.secondary)

            MiniTextProgressBar(progress: 10, color: .cyan)
            MiniTextProgressBar(progress: 40, color: .mint)
            MiniTextProgressBar(progress: 75, color: .indigo)
        }

        Divider()

        // Custom styles
        VStack(alignment: .leading, spacing: 8) {
            Text("Custom Characters")
                .font(.caption)
                .foregroundColor(.secondary)

            TextProgressBar(progress: 33.3, filledChar: "●", emptyChar: "○", color: .pink)
            TextProgressBar(progress: 66.6, filledChar: "■", emptyChar: "□", color: .teal)
            TextProgressBar(progress: 50.0, filledChar: "▓", emptyChar: "░", color: .brown)
        }
    }
    .padding()
    .frame(width: 350)
}

#Preview("Progress Simulation") {
    ProgressSimulationView()
}

// Helper view for testing animations
struct ProgressSimulationView: View {
    @State private var progress: Double = 0
    @State private var isRunning = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Progress Simulation")
                .font(.headline)

            AnimatedTextProgressBar(progress: progress, accentColor: .blue)
            TextProgressBar(progress: progress, color: .green)
            MiniTextProgressBar(progress: progress, color: .orange)

            HStack {
                Button(isRunning ? "Pause" : "Start") {
                    isRunning.toggle()
                }

                Button("Reset") {
                    progress = 0
                    isRunning = false
                }
            }
            .buttonStyle(.borderedProminent)

            Slider(value: $progress, in: 0...100)
        }
        .padding()
        .frame(width: 350)
        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
            if isRunning && progress < 100 {
                progress = min(progress + 0.5, 100)
            }
        }
    }
}
