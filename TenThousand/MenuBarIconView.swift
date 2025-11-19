//
//  MenuBarIconView.swift
//  TenThousand
//
//  Menubar icon with idle/active states
//  The menubar is sacred space. Our icon must earn its place through discretion and utility.
//

import SwiftUI

struct MenuBarIconView: View {
    @ObservedObject var timerManager: TimerManager
    @ObservedObject var preferences = AppPreferences.shared
    @State private var pulseScale: CGFloat = 0.3
    @State private var pulseOpacity: Double = 0.8

    // Icon dimensions: 18x18 canvas, 14x14 glyph, 2px padding
    private let canvasSize: CGFloat = 18
    private let glyphSize: CGFloat = 14
    private let padding: CGFloat = 2

    var body: some View {
        HStack(spacing: 4) {
            ZStack {
                // Canvas boundary (18x18)
                Color.clear
                    .frame(width: canvasSize, height: canvasSize)

                // Outer circle (14x14 glyph with 2px padding)
                Circle()
                    .strokeBorder(
                        timerManager.isRunning && !timerManager.isPaused
                            ? Color.accentColor
                            : Color.primary,
                        lineWidth: 1.5
                    )
                    .frame(width: glyphSize, height: glyphSize)

                // Center element: dot (idle) or animated ring (active)
                if timerManager.isRunning && !timerManager.isPaused {
                    // Active state: animated ring expands from center
                    Circle()
                        .strokeBorder(Color.accentColor, lineWidth: 1.5)
                        .scaleEffect(pulseScale)
                        .opacity(pulseOpacity)
                        .frame(width: 4, height: 4)
                        .onAppear {
                            startPulseAnimation()
                        }
                } else {
                    // Idle state: solid dot in center
                    Circle()
                        .fill(timerManager.isRunning && timerManager.isPaused ? Color.accentColor : Color.primary)
                        .frame(width: 4, height: 4)
                }
            }

            // Optional timer display (user-controlled)
            if preferences.showMenuBarTimer && timerManager.isRunning {
                Text(timerManager.elapsedSeconds.formattedTime())
                    .font(Typography.timeDisplay)
                    .kerning(Typography.timeDisplayKerning)
                    .monospacedDigit()
            }
        }
        .onChange(of: timerManager.isRunning) { _, isRunning in
            if isRunning && !timerManager.isPaused {
                startPulseAnimation()
            } else {
                resetPulseAnimation()
            }
        }
        .onChange(of: timerManager.isPaused) { _, isPaused in
            if isPaused {
                resetPulseAnimation()
            } else if timerManager.isRunning {
                startPulseAnimation()
            }
        }
    }

    private func startPulseAnimation() {
        pulseScale = 0.3
        pulseOpacity = 0.8

        withAnimation(
            Animation.timingCurve(0.4, 0, 0.2, 1, duration: 2.0)
                .repeatForever(autoreverses: false)
        ) {
            pulseScale = 1.0
            pulseOpacity = 0.0
        }
    }

    private func resetPulseAnimation() {
        withAnimation(.none) {
            pulseScale = 0.3
            pulseOpacity = 0.0
        }
    }
}
