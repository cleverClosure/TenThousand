//
//  SkillDetailView.swift
//  TenThousand
//
//  Detailed view for a skill showing stats, sessions, and edit options
//

import SwiftUI

struct SkillDetailView: View {
    let skill: Skill
    @ObservedObject var viewModel: AppViewModel
    @State private var isEditingName = false
    @State private var editedName: String = ""
    @State private var showDeleteConfirmation = false

    private var sessions: [Session] {
        guard let sessionSet = skill.sessions as? Set<Session> else { return [] }
        return sessionSet.sorted { ($0.startTime ?? Date()) > ($1.startTime ?? Date()) }
    }

    private var sessionCount: Int {
        sessions.count
    }

    private var averageSessionLength: Int64 {
        guard sessionCount > 0 else { return 0 }
        return skill.totalSeconds / Int64(sessionCount)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with back button
            headerSection

            Divider()
                .padding(.vertical, Spacing.base)

            // Content
            ScrollView {
                VStack(spacing: Spacing.section) {
                    // Skill info section
                    skillInfoSection

                    // Heatmap section
                    heatmapSection

                    // Progress Charts section
                    progressChartsSection

                    // Statistics section
                    statsSection

                    // Sessions list
                    if !sessions.isEmpty {
                        sessionsSection
                    }

                    // Action buttons
                    actionButtonsSection
                }
                .padding(.horizontal, Spacing.loose)
                .padding(.bottom, Spacing.loose)
            }
            .frame(maxHeight: Dimensions.panelMaxHeight - 100)
        }
        .frame(width: Dimensions.panelWidth)
        .onAppear {
            editedName = skill.name ?? ""
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            Button(action: {
                withAnimation(.panelTransition) {
                    viewModel.selectedSkillForDetail = nil
                }
            }) {
                HStack(spacing: Spacing.tight) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 11, weight: .medium))
                    Text("Back")
                        .font(Typography.body)
                }
                .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()
        }
        .padding(.horizontal, Spacing.loose)
        .padding(.vertical, Spacing.base)
    }

    // MARK: - Skill Info Section

    private var skillInfoSection: some View {
        HStack(spacing: Spacing.loose) {
            // Color indicator
            Circle()
                .fill(skillColor(for: skill.colorIndex))
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: Spacing.tight) {
                if isEditingName {
                    TextField("Skill name", text: $editedName, onCommit: saveSkillName)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(Typography.display)
                        .kerning(Typography.displayKerning)
                } else {
                    Text(skill.name ?? "Untitled")
                        .font(Typography.display)
                        .kerning(Typography.displayKerning)
                        .foregroundColor(.primary)
                }

                if let createdAt = skill.createdAt {
                    Text("Created \(createdAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(Typography.caption)
                        .kerning(Typography.captionKerning)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Edit button
            if !isEditingName {
                Button(action: {
                    isEditingName = true
                }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(Spacing.loose)
        .background(
            RoundedRectangle(cornerRadius: Dimensions.cornerRadiusMedium)
                .fill(Color.primary.opacity(Opacity.backgroundMedium))
        )
    }

    // MARK: - Heatmap Section

    private var heatmapSection: some View {
        VStack(spacing: Spacing.base) {
            HStack {
                Text("Activity")
                    .font(Typography.body)
                    .kerning(Typography.bodyKerning)
                    .foregroundColor(.secondary)

                Spacer()

                // Button to open visualization window
                Button(action: {
                    HeatmapWindowController.shared.openHeatmapWindow(viewModel: viewModel)
                }) {
                    HStack(spacing: Spacing.tight) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 10))
                        Text("Deep View")
                            .font(Typography.caption)
                            .kerning(Typography.captionKerning)
                    }
                    .foregroundColor(.trackingBlue)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            SkillHeatmapView(skill: skill, viewModel: viewModel)
                .padding(Spacing.loose)
                .background(
                    RoundedRectangle(cornerRadius: Dimensions.cornerRadiusMedium)
                        .fill(Color.primary.opacity(Opacity.backgroundMedium))
                )
        }
    }

    // MARK: - Progress Charts Section

    private var progressChartsSection: some View {
        ProgressChartsView(skill: skill, viewModel: viewModel)
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        VStack(spacing: Spacing.base) {
            Text("Statistics")
                .font(Typography.body)
                .kerning(Typography.bodyKerning)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: Spacing.tight) {
                statRow(label: "Total Time", value: skill.totalSeconds.formattedTime())
                statRow(label: "Sessions", value: "\(sessionCount)")
                if sessionCount > 0 {
                    statRow(label: "Avg. Session", value: averageSessionLength.formattedTime())
                }
            }
            .padding(Spacing.loose)
            .background(
                RoundedRectangle(cornerRadius: Dimensions.cornerRadiusMedium)
                    .fill(Color.primary.opacity(Opacity.backgroundMedium))
            )
        }
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(Typography.body)
                .kerning(Typography.bodyKerning)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(Typography.body)
                .kerning(Typography.bodyKerning)
                .foregroundColor(.primary)
        }
    }

    // MARK: - Sessions Section

    private var sessionsSection: some View {
        VStack(spacing: Spacing.base) {
            HStack {
                Text("Recent Sessions")
                    .font(Typography.body)
                    .kerning(Typography.bodyKerning)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(sessionCount) total")
                    .font(Typography.caption)
                    .kerning(Typography.captionKerning)
                    .foregroundColor(.secondary)
            }

            VStack(spacing: Spacing.tight) {
                ForEach(sessions.prefix(10)) { session in
                    sessionRow(session: session)
                }
            }
            .padding(Spacing.loose)
            .background(
                RoundedRectangle(cornerRadius: Dimensions.cornerRadiusMedium)
                    .fill(Color.primary.opacity(Opacity.backgroundMedium))
            )
        }
    }

    private func sessionRow(session: Session) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                if let startTime = session.startTime {
                    Text(startTime.formatted(date: .abbreviated, time: .omitted))
                        .font(Typography.caption)
                        .kerning(Typography.captionKerning)
                        .foregroundColor(.secondary)

                    Text(startTime.formatted(date: .omitted, time: .shortened))
                        .font(Typography.caption)
                        .kerning(Typography.captionKerning)
                        .foregroundColor(.secondary)
                        .opacity(0.7)
                }
            }

            Spacer()

            Text(session.durationSeconds.formattedTime())
                .font(Typography.body)
                .kerning(Typography.bodyKerning)
                .foregroundColor(.primary)
        }
        .padding(.vertical, Spacing.tight)
    }

    // MARK: - Action Buttons Section

    private var actionButtonsSection: some View {
        VStack(spacing: Spacing.base) {
            // Start tracking button
            Button(action: {
                withAnimation(.panelTransition) {
                    viewModel.selectedSkillForDetail = nil
                    viewModel.startTracking(skill: skill)
                }
            }) {
                HStack {
                    Image(systemName: "play.fill")
                        .font(.system(size: 12))
                    Text("Start Tracking")
                        .font(Typography.body)
                        .kerning(Typography.bodyKerning)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.base)
                .background(
                    RoundedRectangle(cornerRadius: Dimensions.cornerRadiusMedium)
                        .fill(Color.trackingBlue)
                )
            }
            .buttonStyle(PlainButtonStyle())

            // Delete button
            Button(action: {
                showDeleteConfirmation = true
            }) {
                HStack {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                    Text("Delete Skill")
                        .font(Typography.body)
                        .kerning(Typography.bodyKerning)
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.base)
                .background(
                    RoundedRectangle(cornerRadius: Dimensions.cornerRadiusMedium)
                        .fill(Color.red.opacity(Opacity.backgroundMedium))
                )
            }
            .buttonStyle(PlainButtonStyle())
            .alert("Delete Skill", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    withAnimation(.panelTransition) {
                        viewModel.selectedSkillForDetail = nil
                        viewModel.deleteSkill(skill)
                    }
                }
            } message: {
                Text("Are you sure you want to delete '\(skill.name ?? "this skill")'? All associated sessions will be permanently deleted.")
            }
        }
    }

    // MARK: - Helper Functions

    private func saveSkillName() {
        let trimmedName = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, trimmedName.count <= ValidationLimits.maxSkillNameLength else {
            editedName = skill.name ?? ""
            isEditingName = false
            return
        }

        // Check for duplicates (excluding current skill)
        let isDuplicate = viewModel.skills.contains { otherSkill in
            otherSkill.id != skill.id && otherSkill.name == trimmedName
        }

        if isDuplicate {
            editedName = skill.name ?? ""
            isEditingName = false
            return
        }

        skill.name = trimmedName
        viewModel.persistenceController.save()
        viewModel.fetchSkills()
        isEditingName = false
    }

    private func skillColor(for index: Int16) -> Color {
        let colors: [Color] = [
            .skillRed, .skillOrange, .skillYellow, .skillGreen,
            .skillTeal, .trackingBlue, .skillPurple, .skillPink
        ]
        return colors[Int(index) % colors.count]
    }
}
