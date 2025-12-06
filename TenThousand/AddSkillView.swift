//
//  AddSkillView.swift
//  TenThousand
//
//  Author: Tim Isaev
//
//  Inline skill creation with enhanced styling
//

import SwiftUI

struct AddSkillView: View {
    // MARK: - Properties

    let existingSkillNames: [String]
    let onCreate: (String) -> Void

    // MARK: - Private State

    @State private var skillName = ""
    @State private var errorMessage: String?
    @State private var isFocused = false

    // MARK: - Private Computed Properties

    private var characterCount: Int {
        skillName.count
    }

    private var isNearLimit: Bool {
        characterCount >= ValidationLimits.maxSkillNameLength - 5
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.base) {
            inputCard
            errorLabel
        }
    }

    // MARK: - View Components

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: Spacing.base) {
            // Input row
            HStack(spacing: Spacing.loose) {
                placeholderDot
                textField
                if !skillName.isEmpty {
                    submitButton
                }
            }

            // Character count (only when typing)
            if !skillName.isEmpty {
                HStack {
                    Spacer()
                    Text("\(characterCount)/\(ValidationLimits.maxSkillNameLength)")
                        .font(Typography.caption)
                        .foregroundColor(isNearLimit ? .orange : .secondary.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, Dimensions.skillRowPaddingHorizontal)
        .padding(.vertical, Dimensions.skillRowPaddingVertical)
        .background(
            RoundedRectangle(cornerRadius: Dimensions.cornerRadiusMedium)
                .fill(Color.primary.opacity(isFocused ? 0.04 : 0.02))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Dimensions.cornerRadiusMedium)
                .stroke(
                    isFocused ? Color.secondary.opacity(0.2) : Color.clear,
                    lineWidth: 1
                )
        )
    }

    private var placeholderDot: some View {
        ZStack {
            Circle()
                .fill(Color.secondary.opacity(0.2))
                .frame(width: Dimensions.colorDotSize, height: Dimensions.colorDotSize)

            Image(systemName: "plus")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary.opacity(0.6))
        }
    }

    private var textField: some View {
        ZStack(alignment: .leading) {
            // Custom placeholder
            if skillName.isEmpty {
                Text("Add a skill...")
                    .displayFont()
                    .foregroundColor(.secondary.opacity(0.6))
            }

            TextField("", text: $skillName, onEditingChanged: { editing in
                withAnimation(.hoverState) {
                    isFocused = editing
                }
            })
            .displayFont()
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
            Image(systemName: "arrow.right.circle.fill")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.green)
        }
        .buttonStyle(PlainButtonStyle())
        .transition(.scale.combined(with: .opacity))
    }

    @ViewBuilder
    private var errorLabel: some View {
        if let error = errorMessage {
            HStack(spacing: Spacing.tight) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 11))
                Text(error)
                    .font(Typography.caption)
            }
            .foregroundColor(.red)
            .padding(.horizontal, Dimensions.skillRowPaddingHorizontal)
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    // MARK: - Private Methods

    private func createSkill() {
        let trimmed = skillName.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            withAnimation(.microInteraction) {
                errorMessage = UIText.errorEmptySkillName
            }
            return
        }

        if existingSkillNames.contains(where: { $0.lowercased() == trimmed.lowercased() }) {
            withAnimation(.microInteraction) {
                errorMessage = UIText.errorDuplicateSkillName
            }
            return
        }

        onCreate(trimmed)
        skillName = ""
        errorMessage = nil
    }
}
