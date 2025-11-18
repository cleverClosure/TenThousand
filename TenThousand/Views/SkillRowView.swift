//
//  SkillRowView.swift
//  TenThousand
//
//  Created by Tim Isaev on 18.11.2025.
//

import SwiftUI

struct SkillRowView: View {
    let skill: Skill
    let onPlayPause: () -> Void
    let onDelete: () -> Void

    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with name and play/pause button
            HStack {
                // Color indicator
                Circle()
                    .fill(skill.color)
                    .frame(width: 12, height: 12)

                Text(skill.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Spacer()

                // Play/Pause button
                Button(action: onPlayPause) {
                    Image(systemName: skill.isTracking ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(skill.isTracking ? .orange : .green)
                }
                .buttonStyle(.plain)
                .help(skill.isTracking ? "Pause tracking" : "Start tracking")

                // Delete button
                Button(action: { showDeleteConfirmation = true }) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .help("Delete skill")
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(skill.color)
                        .frame(width: geometry.size.width * CGFloat(min(skill.percentComplete / 100.0, 1.0)), height: 8)
                }
            }
            .frame(height: 8)

            // Stats row
            HStack {
                Text(skill.formattedPercentage())
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(skill.formattedTotalTime()) / \(skill.formattedGoal())")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            // Projected completion date
            if let completionDate = skill.projectedCompletionDate() {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)

                    Text("Complete: \(completionDate, style: .date)")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            } else {
                HStack {
                    Image(systemName: "hourglass")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)

                    Text("Start tracking to see projection")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
        .alert("Delete Skill?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure? This cannot be undone.")
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        SkillRowView(
            skill: Skill(
                name: "Python Programming",
                totalSeconds: 44280, // 12.3 hours
                goalHours: 10000,
                colorHex: "#FF6B6B"
            ),
            onPlayPause: {},
            onDelete: {}
        )

        SkillRowView(
            skill: Skill(
                name: "Guitar",
                totalSeconds: 20412, // 5.67 hours
                goalHours: 10000,
                colorHex: "#4ECDC4"
            ),
            onPlayPause: {},
            onDelete: {}
        )
    }
    .frame(width: 320)
    .padding()
}
