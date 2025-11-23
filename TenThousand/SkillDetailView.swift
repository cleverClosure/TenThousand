//
//  SkillDetailView.swift
//  TenThousand
//
//  Detailed view for a skill
//

import SwiftUI

struct SkillDetailView: View {
    // MARK: - Properties

    let skill: Skill
    @ObservedObject var viewModel: AppViewModel

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            Spacer()
        }
        .frame(width: Dimensions.panelWidth)
    }

    // MARK: - View Components

    private var headerSection: some View {
        HStack {
            Button {
                withAnimation(.panelTransition) {
                    viewModel.selectedSkillForDetail = nil
                }
            } label: {
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
}
