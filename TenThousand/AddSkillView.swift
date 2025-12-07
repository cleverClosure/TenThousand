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
        characterCount >= Limits.maxSkillNameLength - 5
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            inputCard
            errorLabel
        }
    }

    // MARK: - View Components

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            // Input row
            HStack(spacing: DS.Spacing.md) {
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
                    Text("\(characterCount)/\(Limits.maxSkillNameLength)")
                        .font(DS.Font.caption)
                        .foregroundColor(isNearLimit ? DS.Color.warning : .secondary.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, DS.Spacing.md)
        .padding(.vertical, DS.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.medium)
                .fill(isFocused ? DS.Color.background(.medium) : DS.Color.background(.subtle))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.medium)
                .stroke(
                    isFocused ? Color.primary.opacity(DS.Opacity.strong) : .clear,
                    lineWidth: 1
                )
        )
    }

    private var placeholderDot: some View {
        ZStack {
            Circle()
                .fill(Color.primary.opacity(DS.Opacity.strong))
                .frame(width: DS.Size.colorDot, height: DS.Size.colorDot)

            Image(systemName: "plus")
                .iconFont(.body)
                .foregroundColor(.secondary.opacity(0.6))
        }
    }

    private var textField: some View {
        ZStack(alignment: .leading) {
            // Custom placeholder
            if skillName.isEmpty {
                Text("Add a skill...")
                    .titleFont()
                    .foregroundColor(.secondary.opacity(0.6))
            }

            TextField("", text: $skillName, onEditingChanged: { editing in
                withAnimation(.dsQuick) {
                    isFocused = editing
                }
            })
            .titleFont()
            .textFieldStyle(PlainTextFieldStyle())
            .onSubmit {
                createSkill()
            }
            .onChange(of: skillName) { _, newValue in
                errorMessage = nil
                if newValue.count > Limits.maxSkillNameLength {
                    skillName = String(newValue.prefix(Limits.maxSkillNameLength))
                }
            }
        }
    }

    private var submitButton: some View {
        Button(action: createSkill) {
            Image(systemName: "arrow.right.circle.fill")
                .iconFont(.xl)
                .foregroundColor(DS.Color.success)
        }
        .buttonStyle(PlainButtonStyle())
        .transition(.scale.combined(with: .opacity))
    }

    @ViewBuilder
    private var errorLabel: some View {
        if let error = errorMessage {
            HStack(spacing: DS.Spacing.xs) {
                Image(systemName: "exclamationmark.circle.fill")
                    .iconFont(.body)
                Text(error)
                    .font(DS.Font.caption)
            }
            .foregroundColor(DS.Color.error)
            .padding(.horizontal, DS.Spacing.md)
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    // MARK: - Private Methods

    private func createSkill() {
        let trimmed = skillName.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            withAnimation(.dsQuick) {
                errorMessage = "Skill name cannot be empty"
            }
            return
        }

        if existingSkillNames.contains(where: { $0.lowercased() == trimmed.lowercased() }) {
            withAnimation(.dsQuick) {
                errorMessage = "A skill with this name already exists"
            }
            return
        }

        onCreate(trimmed)
        skillName = ""
        errorMessage = nil
    }
}
