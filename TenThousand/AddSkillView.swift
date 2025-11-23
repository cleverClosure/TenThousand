//
//  AddSkillView.swift
//  TenThousand
//
//  Inline skill creation
//

import SwiftUI

struct AddSkillView: View {
    // MARK: - Properties

    let existingSkillNames: [String]
    let onCreate: (String) -> Void

    // MARK: - Private State

    @State private var skillName = ""
    @State private var errorMessage: String?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.tight) {
            inputRow
            errorLabel
        }
    }

    // MARK: - View Components

    private var inputRow: some View {
        HStack(spacing: Spacing.loose) {
            placeholderDot
            textField
            if !skillName.isEmpty {
                submitButton
            }
        }
        .padding(.horizontal, Dimensions.skillRowPaddingHorizontal)
        .padding(.vertical, Dimensions.skillRowPaddingVertical)
        .frame(height: Dimensions.skillRowHeight)
        .background(
            RoundedRectangle(cornerRadius: Dimensions.cornerRadiusSmall)
                .fill(Color.primary.opacity(Opacity.backgroundLight))
        )
    }

    private var placeholderDot: some View {
        Circle()
            .fill(Color.secondary.opacity(Opacity.overlayStrong))
            .frame(width: Dimensions.colorDotSize, height: Dimensions.colorDotSize)
    }

    private var textField: some View {
        ZStack(alignment: .leading) {
            // Custom placeholder with matching kerning to prevent microjump
            if skillName.isEmpty {
                Text(UIText.skillNamePlaceholder)
                    .font(Typography.display)
                    .kerning(Typography.displayKerning)
                    .foregroundColor(.secondary)
            }
            TextField("", text: $skillName)
                .font(Typography.display)
                .kerning(Typography.displayKerning)
                .textFieldStyle(PlainTextFieldStyle())
                .onSubmit {
                    createSkill()
                }
                .onChange(of: skillName) { _, newValue in
                    errorMessage = nil
                    if newValue.count > ValidationLimits.maxSkillNameLength {
                        skillName = String(newValue.prefix(ValidationLimits.maxSkillNameLength))
                    }
                }
        }
    }

    private var submitButton: some View {
        Button(action: createSkill) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(.trackingBlue)
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private var errorLabel: some View {
        if let error = errorMessage {
            Text(error)
                .font(Typography.caption)
                .kerning(Typography.captionKerning)
                .foregroundColor(.red)
                .padding(.horizontal, Dimensions.skillRowPaddingHorizontal)
                .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    // MARK: - Private Methods

    private func createSkill() {
        let trimmed = skillName.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            errorMessage = UIText.errorEmptySkillName
            return
        }

        if existingSkillNames.contains(where: { $0.lowercased() == trimmed.lowercased() }) {
            errorMessage = UIText.errorDuplicateSkillName
            return
        }

        onCreate(trimmed)
        skillName = ""
        errorMessage = nil
    }
}
