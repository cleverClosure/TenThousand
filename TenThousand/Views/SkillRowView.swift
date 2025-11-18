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
    var onEdit: (() -> Void)? = nil

    @State private var showDeleteConfirmation = false
    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.spacing_sm) {
            // Header Row: Color dot, skill name, play/pause button
            HStack(spacing: Constants.spacing_sm) {
                // Color indicator
                Circle()
                    .fill(skill.color)
                    .frame(width: 10, height: 10)

                Text(skill.name)
                    .font(.system(size: Constants.fontSize_body, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Spacer()

                // Edit and Delete buttons (visible on hover)
                if isHovered {
                    HStack(spacing: 4) {
                        if let editAction = onEdit {
                            Button(action: editAction) {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(.plain)
                            .help("Edit skill")
                        }

                        Button(action: { showDeleteConfirmation = true }) {
                            Image(systemName: "trash.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                        .help("Delete skill")
                    }
                    .transition(.opacity)
                }

                // Play/Pause button (always visible)
                Button(action: onPlayPause) {
                    Image(systemName: skill.isTracking ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(
                            skill.isTracking
                                ? Color(hex: Constants.color_paused) ?? .orange
                                : Color(hex: Constants.color_active) ?? .green
                        )
                        .symbolEffect(.pulse, isActive: skill.isTracking)
                }
                .buttonStyle(.plain)
                .help(skill.isTracking ? "Pause tracking" : "Start tracking")
            }

            // Progress Bar
            ModernProgressBar(
                progress: skill.percentComplete,
                accentColor: skill.color,
                showPercentage: true,
                isActive: skill.isTracking
            )

            // Stats Row
            HStack(spacing: 4) {
                Text("\(skill.formattedTotalTime()) / \(skill.formattedGoal())")
                    .font(.system(size: Constants.fontSize_caption, weight: .medium))
                    .foregroundColor(.secondary)

                Text("•")
                    .font(.system(size: Constants.fontSize_caption))
                    .foregroundColor(.secondary)

                if let completionDate = skill.projectedCompletionDate() {
                    Text("Est: \(completionDate, style: .date)")
                        .font(.system(size: Constants.fontSize_caption))
                        .foregroundColor(.secondary)
                } else {
                    Text("Est: Start tracking")
                        .font(.system(size: Constants.fontSize_caption))
                        .foregroundColor(.secondary)
                }
            }

            // Current session timer (if tracking)
            if let currentSessionTime = skill.formattedCurrentSession() {
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: Constants.color_paused) ?? .orange)

                    Text("+\(currentSessionTime)")
                        .font(.system(size: Constants.fontSize_caption, weight: .medium))
                        .foregroundColor(Color(hex: Constants.color_paused) ?? .orange)
                        .monospacedDigit()
                }
            }
        }
        .padding(Constants.spacing_md)
        .background(
            RoundedRectangle(cornerRadius: Constants.radius_md)
                .fill(
                    skill.isTracking
                        ? skill.color.opacity(0.08)
                        : (isHovered ? Color(nsColor: .controlBackgroundColor).opacity(0.6) : Color.clear)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: Constants.radius_md)
                .strokeBorder(
                    skill.isTracking ? skill.color.opacity(0.3) : Color.clear,
                    lineWidth: 1
                )
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
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
