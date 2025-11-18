//
//  OverallProgressView.swift
//  TenThousand
//
//  Created by Tim Isaev on 18.11.2025.
//

import SwiftUI

/// Displays aggregate progress across all skills with cool visualizations
struct OverallProgressView: View {
    @ObservedObject var data: SkillTrackerData

    private var totalHours: Double {
        data.skills.reduce(0) { $0 + $1.totalHours }
    }

    private var totalGoalHours: Double {
        data.skills.reduce(0) { $0 + $1.goalHours }
    }

    private var averageProgress: Double {
        guard !data.skills.isEmpty else { return 0 }
        return data.skills.reduce(0) { $0 + $1.percentComplete } / Double(data.skills.count)
    }

    private var activeSkillsCount: Int {
        data.skills.filter { $0.isTracking }.count
    }

    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 11))
                    .foregroundColor(.blue)

                Text("Overall Progress")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                if activeSkillsCount > 0 {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(.orange)
                            .frame(width: 6, height: 6)
                            .symbolEffect(.pulse)

                        Text("\(activeSkillsCount) tracking")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.orange)
                    }
                }
            }

            // Main progress bar
            AnimatedTextProgressBar(
                progress: averageProgress,
                totalBlocks: 25,
                showPercentage: true,
                accentColor: .blue
            )

            // Stats row
            HStack(spacing: 16) {
                // Total hours
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)

                    Text(String(format: "%.0fh total", totalHours))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }

                Divider()
                    .frame(height: 12)

                // Skills count
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)

                    Text("\(data.skills.count) skill\(data.skills.count == 1 ? "" : "s")")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Average progress badge
                Text(String(format: "Avg: %.1f%%", averageProgress))
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(averageProgress >= 50 ? Color.green : averageProgress >= 20 ? Color.orange : Color.red)
                    )
            }
        }
        .padding(12)
        .background(Color.blue.opacity(0.08))
        .cornerRadius(8)
    }
}

/// Compact version for tighter spaces
struct CompactOverallProgressView: View {
    @ObservedObject var data: SkillTrackerData

    private var averageProgress: Double {
        guard !data.skills.isEmpty else { return 0 }
        return data.skills.reduce(0) { $0 + $1.percentComplete } / Double(data.skills.count)
    }

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Overall")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(data.skills.count) skill\(data.skills.count == 1 ? "" : "s")")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            MiniTextProgressBar(
                progress: averageProgress,
                totalBlocks: 15,
                color: .blue
            )
        }
        .padding(8)
        .background(Color.secondary.opacity(0.06))
        .cornerRadius(6)
    }
}

/// Top 3 skills preview with mini progress bars
struct TopSkillsPreview: View {
    @ObservedObject var data: SkillTrackerData

    private var topSkills: [Skill] {
        Array(data.skills.sorted { $0.percentComplete > $1.percentComplete }.prefix(3))
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.yellow)

                Text("Top Progress")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(.bottom, 8)

            VStack(spacing: 6) {
                ForEach(Array(topSkills.enumerated()), id: \.element.id) { index, skill in
                    HStack(spacing: 6) {
                        // Rank badge
                        Text("\(index + 1)")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 16, height: 16)
                            .background(
                                Circle()
                                    .fill(index == 0 ? Color.yellow : index == 1 ? Color.gray : Color.brown)
                            )

                        // Color indicator
                        Circle()
                            .fill(skill.color)
                            .frame(width: 8, height: 8)

                        // Skill name
                        Text(skill.name)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .frame(width: 90, alignment: .leading)

                        Spacer()

                        // Mini progress
                        MiniTextProgressBar(
                            progress: skill.percentComplete,
                            totalBlocks: 8,
                            color: skill.color
                        )
                    }
                }
            }
        }
        .padding(10)
        .background(Color.yellow.opacity(0.06))
        .cornerRadius(8)
    }
}

// MARK: - Preview

#Preview("Overall Progress Views") {
    let sampleData = {
        let data = SkillTrackerData()
        data.addSkill(name: "Python", goalHours: 10000)
        data.addSkill(name: "Guitar", goalHours: 10000)
        data.addSkill(name: "Japanese", goalHours: 10000)

        // Simulate some progress
        if let python = data.skills.first(where: { $0.name == "Python" }) {
            data.updateSkillHours(skill: python, totalSeconds: 123000) // ~34 hours
        }
        if let guitar = data.skills.first(where: { $0.name == "Guitar" }) {
            data.updateSkillHours(skill: guitar, totalSeconds: 456000) // ~126 hours
        }
        if let japanese = data.skills.first(where: { $0.name == "Japanese" }) {
            data.updateSkillHours(skill: japanese, totalSeconds: 72000) // ~20 hours
        }

        return data
    }()

    VStack(spacing: 16) {
        Text("Overall Progress Styles")
            .font(.headline)

        Divider()

        OverallProgressView(data: sampleData)

        CompactOverallProgressView(data: sampleData)

        TopSkillsPreview(data: sampleData)
    }
    .padding()
    .frame(width: 320)
}
