//
//  TimeRemainingView.swift
//  TenThousand
//
//  Created by Tim Isaev on 18.11.2025.
//

import SwiftUI

struct TimeRemainingView: View {
    @State private var currentDate = Date()

    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Time Remaining")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 4) {
                timeRemainingRow(
                    icon: "sun.max.fill",
                    text: timeLeftToday(),
                    color: .orange
                )

                timeRemainingRow(
                    icon: "calendar",
                    text: timeLeftThisWeek(),
                    color: .blue
                )

                timeRemainingRow(
                    icon: "calendar.badge.clock",
                    text: timeLeftThisMonth(),
                    color: .purple
                )

                timeRemainingRow(
                    icon: "calendar.circle.fill",
                    text: timeLeftThisYear(),
                    color: .green
                )
            }
        }
        .padding(.vertical, 8)
        .onReceive(timer) { _ in
            currentDate = Date()
        }
    }

    private func timeRemainingRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(color)
                .frame(width: 16)

            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Time Calculations

    private func timeLeftToday() -> String {
        let endOfDay = currentDate.endOfDay
        return currentDate.timeRemaining(until: endOfDay) + " left today"
    }

    private func timeLeftThisWeek() -> String {
        let endOfWeek = currentDate.endOfWeek
        return currentDate.timeRemaining(until: endOfWeek) + " left this week"
    }

    private func timeLeftThisMonth() -> String {
        let endOfMonth = currentDate.endOfMonth
        let days = Calendar.current.dateComponents([.day], from: currentDate, to: endOfMonth).day ?? 0
        return "\(days)d left this month"
    }

    private func timeLeftThisYear() -> String {
        let endOfYear = currentDate.endOfYear
        let days = Calendar.current.dateComponents([.day], from: currentDate, to: endOfYear).day ?? 0
        return "\(days)d left this year"
    }
}

#Preview {
    TimeRemainingView()
        .frame(width: 320)
        .padding()
}
