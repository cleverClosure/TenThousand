//
//  AddSkillView.swift
//  TenThousand
//
//  Created by Tim Isaev on 18.11.2025.
//

import SwiftUI

struct AddSkillView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var data: SkillTrackerData

    @State private var skillName: String = ""
    @State private var goalHours: String = "10000"
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Add New Skill")
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

                Button("Create") {
                    createSkill()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!isValid)
            }
            .padding(.bottom, 20)
        }
        .frame(width: 320, height: 260)
        .padding(.horizontal, 20)
    }

    private var isValid: Bool {
        !skillName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Double(goalHours) != nil &&
        (Double(goalHours) ?? 0) > 0
    }

    private func createSkill() {
        let trimmedName = skillName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            showError(message: "Please enter a skill name")
            return
        }

        guard let hours = Double(goalHours), hours > 0 else {
            showError(message: "Please enter a valid goal (must be greater than 0)")
            return
        }

        data.addSkill(name: trimmedName, goalHours: hours)
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
    AddSkillView(data: SkillTrackerData())
}
