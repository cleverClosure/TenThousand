//
//  AddSkillView.swift
//  TenThousand
//
//  Inline skill creation
//

import SwiftUI

struct AddSkillView: View {
    @Binding var isActive: Bool
    let onCreate: (String) -> Void

    @State private var skillName = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: Spacing.loose) {
            Circle()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: Dimensions.colorDotSize, height: Dimensions.colorDotSize)

            TextField("Skill name...", text: $skillName)
                .font(Typography.display)
                .textFieldStyle(PlainTextFieldStyle())
                .focused($isFocused)
                .onSubmit {
                    createSkill()
                }
                .onChange(of: skillName) { newValue in
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
                .fill(Color.primary.opacity(0.03))
        )
        .onAppear {
            isFocused = true
        }
        .onExitCommand {
            cancel()
        }
    }

    private func createSkill() {
        let trimmed = skillName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            onCreate(trimmed)
            skillName = ""
        }
        isActive = false
    }

    private func cancel() {
        skillName = ""
        isActive = false
    }
}
