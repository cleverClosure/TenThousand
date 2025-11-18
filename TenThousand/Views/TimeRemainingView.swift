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
        VStack(alignment: .leading, spacing: Constants.spacing_md) {
            // Section title with clock icon
            HStack(spacing: 6) {
                Text("⏰")
                    .font(.system(size: 14))
                Text("Time Remaining")
                    .font(.system(size: Constants.fontSize_body, weight: .semibold))
                    .foregroundColor(.primary)
            }

            // Time display rows in a card-like container
            VStack(alignment: .leading, spacing: Constants.spacing_sm) {
                timeRemainingRow(
                    label: "Today",
                    time: timeLeftToday()
                )

                Divider()
                    .padding(.vertical, 2)

                timeRemainingRow(
                    label: "This Week",
                    time: timeLeftThisWeek()
                )

                Divider()
                    .padding(.vertical, 2)

                timeRemainingRow(
                    label: "This Month",
                    time: timeLeftThisMonth()
                )

                Divider()
                    .padding(.vertical, 2)

                timeRemainingRow(
                    label: "This Year",
                    time: timeLeftThisYear()
                )
            }
            .padding(Constants.spacing_lg)
            .background(
                RoundedRectangle(cornerRadius: Constants.radius_md)
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(0.5))
            )
        }
        .padding(.vertical, Constants.spacing_sm)
        .onReceive(timer) { _ in
            currentDate = Date()
        }
    }

    private func timeRemainingRow(label: String, time: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: Constants.fontSize_callout))
                .foregroundColor(.secondary)

            Spacer()

            Text(time)
                .font(.system(size: Constants.fontSize_callout, weight: .medium))
                .foregroundColor(.primary)
                .monospacedDigit()
        }
    }

    // MARK: - Time Calculations

    private func timeLeftToday() -> String {
        let endOfDay = currentDate.endOfDay
        return currentDate.timeRemaining(until: endOfDay)
    }

    private func timeLeftThisWeek() -> String {
        let endOfWeek = currentDate.endOfWeek
        let days = Calendar.current.dateComponents([.day], from: currentDate, to: endOfWeek).day ?? 0
        let hours = Calendar.current.dateComponents([.hour], from: currentDate, to: endOfWeek).hour ?? 0
        let remainingHours = hours % 24
        return "\(days)d \(remainingHours)h"
    }

    private func timeLeftThisMonth() -> String {
        let endOfMonth = currentDate.endOfMonth
        let days = Calendar.current.dateComponents([.day], from: currentDate, to: endOfMonth).day ?? 0
        return "\(days)d"
    }

    private func timeLeftThisYear() -> String {
        let endOfYear = currentDate.endOfYear
        let days = Calendar.current.dateComponents([.day], from: currentDate, to: endOfYear).day ?? 0
        return "\(days)d"
    }
}

#Preview {
    TimeRemainingView()
        .frame(width: 320)
        .padding()
}
