//
//  AddSkillView.swift
//  TenThousand
//
//  Inline skill creation
//

import SwiftUI

struct AddSkillView: View {
    @Binding var isActive: Bool
    let existingSkillNames: [String]
    let onCreate: (String) -> Void

    @State private var skillName = ""
    @State private var errorMessage: String? = nil
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.tight) {
            HStack(spacing: Spacing.loose) {
                Circle()
                    .fill(Color.secondary.opacity(Opacity.overlayStrong))
                    .frame(width: Dimensions.colorDotSize, height: Dimensions.colorDotSize)

                TextField("Skill name...", text: $skillName)
                    .font(Typography.display)
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused($isFocused)
                    .onSubmit {
                        createSkill()
                    }
                    .onChange(of: skillName) { oldValue, newValue in
                        // Clear error when user types
                        errorMessage = nil

                        // Limit to 30 characters
                        if newValue.count > 30 {
                            skillName = String(newValue.prefix(30))
                        }
                    }

                if !skillName.isEmpty {
                    Button(action: createSkill) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.trackingBlue)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, Dimensions.skillRowPaddingHorizontal)
            .padding(.vertical, Dimensions.skillRowPaddingVertical)
            .frame(height: Dimensions.skillRowHeight)
            .background(
                RoundedRectangle(cornerRadius: Dimensions.cornerRadiusSmall)
                    .fill(Color.primary.opacity(Opacity.backgroundLight))
            )

            // Error message
            if let error = errorMessage {
                Text(error)
                    .font(Typography.caption)
                    .kerning(Typography.captionKerning)
                    .foregroundColor(.red)
                    .padding(.horizontal, Dimensions.skillRowPaddingHorizontal)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .onAppear {
            isFocused = true
        }
        .onExitCommand {
            cancel()
        }
    }

    private func createSkill() {
        let trimmed = skillName.trimmingCharacters(in: .whitespacesAndNewlines)

        // Validation
        if trimmed.isEmpty {
            errorMessage = "Skill name cannot be empty"
            return
        }

        if existingSkillNames.contains(where: { $0.lowercased() == trimmed.lowercased() }) {
            errorMessage = "A skill with this name already exists"
            return
        }

        // Success
        onCreate(trimmed)
        skillName = ""
        errorMessage = nil
        isActive = false
    }

    private func cancel() {
        skillName = ""
        isActive = false
    }
}
