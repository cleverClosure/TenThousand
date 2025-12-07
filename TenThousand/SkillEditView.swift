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
        guard trimmed.count <= ValidationLimits.maxSkillNameLength else { return false }

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
        characterCount >= ValidationLimits.maxSkillNameLength - 5
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            ScrollView {
                VStack(spacing: Spacing.section) {
                    nameSection
                    colorSection
                }
                .padding(.horizontal, Spacing.section)
                .padding(.vertical, Spacing.loose)
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
                withAnimation(.panelTransition) {
                    viewModel.showSkillList()
                }
            } label: {
                HStack(spacing: Spacing.tight) {
                    Image(systemName: "chevron.left")
                        .iconFont(.body, weight: .semibold)
                    Text("Cancel")
                        .font(Typography.body)
                }
                .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()

            Text("Edit Skill")
                .font(Typography.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Spacer()

            // Invisible spacer to center title
            HStack(spacing: Spacing.tight) {
                Image(systemName: "chevron.left")
                Text("Cancel")
            }
            .font(Typography.body)
            .opacity(0)
        }
        .padding(.horizontal, Spacing.section)
        .padding(.top, Spacing.loose)
        .padding(.bottom, Spacing.base)
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: Spacing.base) {
            Text("NAME")
                .labelFont()
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: Spacing.tight) {
                HStack(spacing: Spacing.loose) {
                    Circle()
                        .fill(selectedColor)
                        .frame(width: Dimensions.colorDotSize, height: Dimensions.colorDotSize)
                        .shadow(color: selectedColor.opacity(Shadows.medium.opacity), radius: Shadows.medium.radius, y: Shadows.medium.yOffset)

                    TextField("Skill name", text: $editedName)
                        .displayFont()
                        .textFieldStyle(PlainTextFieldStyle())
                        .onChange(of: editedName) { _, newValue in
                            errorMessage = nil
                            if newValue.count > ValidationLimits.maxSkillNameLength {
                                editedName = String(newValue.prefix(ValidationLimits.maxSkillNameLength))
                            }
                        }
                }
                .padding(.horizontal, Dimensions.skillRowPaddingHorizontal)
                .padding(.vertical, Dimensions.skillRowPaddingVertical)
                .background(
                    RoundedRectangle(cornerRadius: Dimensions.cornerRadiusMedium)
                        .fill(Color.backgroundPrimary(.light))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Dimensions.cornerRadiusMedium)
                        .stroke(Color.backgroundSecondary(.overlay), lineWidth: LayoutConstants.borderWidth)
                )

                HStack {
                    if let error = errorMessage {
                        HStack(spacing: Spacing.tight) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .iconFont(.caption)
                            Text(error)
                                .font(Typography.caption)
                        }
                        .foregroundColor(.stateError)
                    }
                    Spacer()
                    Text("\(characterCount)/\(ValidationLimits.maxSkillNameLength)")
                        .font(Typography.caption)
                        .foregroundColor(isNearLimit ? .stateWarning : .secondary.opacity(0.6))
                }
            }
        }
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: Spacing.base) {
            Text("COLOR")
                .labelFont()
                .foregroundColor(.secondary)

            VStack(spacing: Spacing.loose) {
                ForEach(ColorPalette.all) { palette in
                    paletteRow(palette)
                }
            }
            .padding(Spacing.loose)
            .background(
                RoundedRectangle(cornerRadius: Dimensions.cornerRadiusMedium)
                    .fill(Color.backgroundPrimary(.ultraLight))
            )
        }
    }

    private func paletteRow(_ palette: ColorPalette) -> some View {
        HStack(spacing: Spacing.compact) {
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
            withAnimation(.microInteraction) {
                selectedPaletteId = paletteId
                selectedColorIndex = colorIndex
            }
        } label: {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: Dimensions.colorPickerButtonSize, height: Dimensions.colorPickerButtonSize)
                    .shadow(
                        color: color.opacity(isSelected ? Opacity.colorPickerSelected : Opacity.colorPickerDefault),
                        radius: isSelected ? Shadows.medium.radius : Shadows.subtle.radius,
                        y: Shadows.small.yOffset
                    )

                if isSelected {
                    Circle()
                        .stroke(Color.buttonTextLight, lineWidth: Dimensions.menubarStrokeWidth)
                        .frame(width: Dimensions.colorPickerButtonSize, height: Dimensions.colorPickerButtonSize)

                    Image(systemName: "checkmark")
                        .iconFont(.body, weight: .bold)
                        .foregroundColor(.buttonTextLight)
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
                HStack(spacing: Spacing.base) {
                    Image(systemName: "checkmark.circle.fill")
                        .iconFont(.large, weight: .semibold)
                    Text("Save Changes")
                        .font(Typography.body)
                        .fontWeight(.semibold)
                }
                .foregroundColor(hasChanges && isValidName ? .buttonTextLight : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.loose)
                .background(
                    RoundedRectangle(cornerRadius: Dimensions.cornerRadiusMedium)
                        .fill(hasChanges && isValidName ? selectedColor : Color.backgroundPrimary(.medium))
                )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!hasChanges || !isValidName)
            .padding(.horizontal, Spacing.section)
            .padding(.vertical, Spacing.loose)
        }
    }

    // MARK: - Private Methods

    private func saveChanges() {
        let trimmed = editedName.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            withAnimation(.microInteraction) {
                errorMessage = UIText.errorEmptySkillName
            }
            return
        }

        let isDuplicate = viewModel.skills.contains {
            $0.id != skill.id && $0.name.lowercased() == trimmed.lowercased()
        }

        if isDuplicate {
            withAnimation(.microInteraction) {
                errorMessage = UIText.errorDuplicateSkillName
            }
            return
        }

        viewModel.updateSkill(
            skill,
            name: trimmed,
            paletteId: selectedPaletteId,
            colorIndex: Int16(selectedColorIndex)
        )

        withAnimation(.panelTransition) {
            viewModel.showSkillList()
        }
    }
}
