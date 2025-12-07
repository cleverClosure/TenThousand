//
//  SkillEditView.swift
//  TenThousand
//
//  Author: Tim Isaev
//
//  Edit view for modifying skill name and color
//

import SwiftUI

struct SkillEditView: View {
    // MARK: - Properties

    let skill: Skill
    @ObservedObject var viewModel: AppViewModel

    // MARK: - Private State

    @State private var editedName: String = ""
    @State private var selectedPaletteId: String = ""
    @State private var selectedColorIndex: Int = 0
    @State private var errorMessage: String?

    // MARK: - Private Computed Properties

    private var selectedColor: Color {
        viewModel.colorPaletteManager.color(
            forPaletteId: selectedPaletteId,
            colorIndex: selectedColorIndex
        )
    }

    private var hasChanges: Bool {
        editedName != skill.name ||
        selectedPaletteId != skill.paletteId ||
        selectedColorIndex != Int(skill.colorIndex)
    }

    private var isValidName: Bool {
        let trimmed = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        guard trimmed.count <= Limits.maxSkillNameLength else { return false }

        // Check for duplicates (excluding current skill)
        let isDuplicate = viewModel.skills.contains {
            $0.id != skill.id && $0.name.lowercased() == trimmed.lowercased()
        }
        return !isDuplicate
    }

    private var characterCount: Int {
        editedName.count
    }

    private var isNearLimit: Bool {
        characterCount >= Limits.maxSkillNameLength - 5
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            ScrollView {
                VStack(spacing: DS.Spacing.lg) {
                    nameSection
                    colorSection
                }
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.vertical, DS.Spacing.md)
            }
            .scrollIndicators(.hidden)
            footerSection
        }
        .onAppear {
            editedName = skill.name
            selectedPaletteId = skill.paletteId
            selectedColorIndex = Int(skill.colorIndex)
        }
    }

    // MARK: - View Components

    private var headerSection: some View {
        HStack {
            Button {
                withAnimation(.dsStandard) {
                    viewModel.showSkillList()
                }
            } label: {
                HStack(spacing: DS.Spacing.xs) {
                    Image(systemName: "chevron.left")
                        .iconFont(.body, weight: .semibold)
                    Text("Cancel")
                        .font(DS.Font.body)
                }
                .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()

            Text("Edit Skill")
                .font(DS.Font.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Spacer()

            // Invisible spacer to center title
            HStack(spacing: DS.Spacing.xs) {
                Image(systemName: "chevron.left")
                Text("Cancel")
            }
            .font(DS.Font.body)
            .opacity(0)
        }
        .padding(.horizontal, DS.Spacing.lg)
        .padding(.top, DS.Spacing.md)
        .padding(.bottom, DS.Spacing.sm)
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("NAME")
                .labelFont()
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                HStack(spacing: DS.Spacing.md) {
                    Circle()
                        .fill(selectedColor)
                        .frame(width: DS.Size.colorDot, height: DS.Size.colorDot)
                        .shadow(color: selectedColor.opacity(DS.Shadow.elevated.opacity), radius: DS.Shadow.elevated.radius, y: DS.Shadow.elevated.y)

                    TextField("Skill name", text: $editedName)
                        .titleFont()
                        .textFieldStyle(PlainTextFieldStyle())
                        .onChange(of: editedName) { _, newValue in
                            errorMessage = nil
                            if newValue.count > Limits.maxSkillNameLength {
                                editedName = String(newValue.prefix(Limits.maxSkillNameLength))
                            }
                        }
                }
                .padding(.horizontal, DS.Spacing.md)
                .padding(.vertical, DS.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DS.Radius.medium)
                        .fill(DS.Color.background(.subtle))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.medium)
                        .stroke(Color.primary.opacity(DS.Opacity.strong), lineWidth: 1)
                )

                HStack {
                    if let error = errorMessage {
                        HStack(spacing: DS.Spacing.xs) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .iconFont(.body)
                            Text(error)
                                .font(DS.Font.caption)
                        }
                        .foregroundColor(DS.Color.error)
                    }
                    Spacer()
                    Text("\(characterCount)/\(Limits.maxSkillNameLength)")
                        .font(DS.Font.caption)
                        .foregroundColor(isNearLimit ? DS.Color.warning : .secondary.opacity(0.6))
                }
            }
        }
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("COLOR")
                .labelFont()
                .foregroundColor(.secondary)

            VStack(spacing: DS.Spacing.md) {
                ForEach(ColorPalette.all) { palette in
                    paletteRow(palette)
                }
            }
            .padding(DS.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.medium)
                    .fill(DS.Color.background(.subtle))
            )
        }
    }

    private func paletteRow(_ palette: ColorPalette) -> some View {
        HStack(spacing: DS.Spacing.md) {
            ForEach(Array(palette.colors.enumerated()), id: \.element.id) { index, skillColor in
                colorButton(
                    color: skillColor.color,
                    paletteId: palette.id,
                    colorIndex: index
                )
            }
        }
    }

    private func colorButton(color: Color, paletteId: String, colorIndex: Int) -> some View {
        let isSelected = selectedPaletteId == paletteId && selectedColorIndex == colorIndex

        return Button {
            withAnimation(.dsQuick) {
                selectedPaletteId = paletteId
                selectedColorIndex = colorIndex
            }
        } label: {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: DS.Size.colorPickerButton, height: DS.Size.colorPickerButton)
                    .shadow(
                        color: color.opacity(isSelected ? DS.Opacity.muted : DS.Opacity.medium),
                        radius: isSelected ? DS.Shadow.elevated.radius : 2,
                        y: DS.Shadow.elevated.y
                    )

                if isSelected {
                    Circle()
                        .stroke(Color.white, lineWidth: DS.Size.menubarStroke)
                        .frame(width: DS.Size.colorPickerButton, height: DS.Size.colorPickerButton)

                    Image(systemName: "checkmark")
                        .iconFont(.body, weight: .bold)
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
    }

    private var footerSection: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                saveChanges()
            } label: {
                HStack(spacing: DS.Spacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .iconFont(.large, weight: .semibold)
                    Text("Save Changes")
                        .font(DS.Font.body)
                        .fontWeight(.semibold)
                }
                .foregroundColor(hasChanges && isValidName ? .white : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DS.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DS.Radius.medium)
                        .fill(hasChanges && isValidName ? selectedColor : DS.Color.background(.medium))
                )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!hasChanges || !isValidName)
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.vertical, DS.Spacing.md)
        }
    }

    // MARK: - Private Methods

    private func saveChanges() {
        let trimmed = editedName.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            withAnimation(.dsQuick) {
                errorMessage = "Skill name cannot be empty"
            }
            return
        }

        let isDuplicate = viewModel.skills.contains {
            $0.id != skill.id && $0.name.lowercased() == trimmed.lowercased()
        }

        if isDuplicate {
            withAnimation(.dsQuick) {
                errorMessage = "A skill with this name already exists"
            }
            return
        }

        viewModel.updateSkill(
            skill,
            name: trimmed,
            paletteId: selectedPaletteId,
            colorIndex: Int16(selectedColorIndex)
        )

        withAnimation(.dsStandard) {
            viewModel.showSkillList()
        }
    }
}
