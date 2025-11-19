//
//  MenuBarIconView.swift
//  TenThousand
//
//  Menubar icon with idle/active states
//

import SwiftUI

struct MenuBarIconView: View {
    @ObservedObject var timerManager: TimerManager
    @State private var pulseScale: CGFloat = 0.3
    @State private var pulseOpacity: Double = 0.8

    var body: some View {
        HStack(spacing: 4) {
            ZStack {
                // Pulse ring (only when actively tracking)
                if timerManager.isRunning && !timerManager.isPaused {
                    Circle()
                        .stroke(Color.accentColor, lineWidth: 2)
                        .scaleEffect(pulseScale)
                        .opacity(pulseOpacity)
                        .frame(width: Dimensions.iconSizeSmall, height: Dimensions.iconSizeSmall)
                        .onAppear {
                            startPulseAnimation()
                        }
                }

                // Main icon
                Image(systemName: timerManager.isRunning && !timerManager.isPaused ? "circle.fill" : "circle")
                    .font(.system(size: 14, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(timerManager.isRunning && !timerManager.isPaused ? .accentColor : .primary)
            }

            if timerManager.isRunning {
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
