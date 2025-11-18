//
//  EditSkillView.swift
//  TenThousand
//
//  Created by Tim Isaev on 18.11.2025.
//

import SwiftUI

struct EditSkillView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var data: SkillTrackerData
    let skill: Skill

    @State private var skillName: String
    @State private var goalHours: String
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    init(data: SkillTrackerData, skill: Skill) {
        self.data = data
        self.skill = skill
        _skillName = State(initialValue: skill.name)
        _goalHours = State(initialValue: String(Int(skill.goalHours)))
    }

    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Edit Skill")
                .font(.system(size: 17, weight: .semibold))
                .padding(.top, 20)

            // Skill Name
            VStack(alignment: .leading, spacing: 6) {
                Text("Skill Name")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)

                TextField("e.g., Python Programming", text: $skillName)
                    .textFieldStyle(.roundedBorder)
            }

            // Goal Hours
            VStack(alignment: .leading, spacing: 6) {
                Text("Goal (hours)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)

                TextField("10000", text: $goalHours)
                    .textFieldStyle(.roundedBorder)

                if hasGoalChanged {
                    Text("Changing the goal will affect your progress percentage and projections.")
                        .font(.system(size: 11))
                        .foregroundColor(.orange)
                }
            }

            if showError {
                Text(errorMessage)
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }

            Spacer()

            // Buttons
            HStack(spacing: 12) {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button("Save") {
                    saveChanges()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!isValid || !hasChanges)
            }
            .padding(.bottom, 20)
        }
        .frame(width: 320, height: 280)
        .padding(.horizontal, 20)
    }

    private var isValid: Bool {
        !skillName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Double(goalHours) != nil &&
        (Double(goalHours) ?? 0) > 0
    }

    private var hasChanges: Bool {
        skillName != skill.name || goalHours != String(Int(skill.goalHours))
    }

    private var hasGoalChanged: Bool {
        goalHours != String(Int(skill.goalHours))
    }

    private func saveChanges() {
        let trimmedName = skillName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            showError(message: "Please enter a skill name")
            return
        }

        guard let hours = Double(goalHours), hours > 0 else {
            showError(message: "Please enter a valid goal (must be greater than 0)")
            return
        }

        data.updateSkill(skill, name: trimmedName, goalHours: hours)
        dismiss()
    }

    private func showError(message: String) {
        errorMessage = message
        showError = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showError = false
        }
    }
}

#Preview {
    EditSkillView(
        data: SkillTrackerData(),
        skill: Skill(
            name: "Python Programming",
            totalSeconds: 44280,
            goalHours: 10000,
            colorHex: "#FF6B6B"
        )
    )
}
