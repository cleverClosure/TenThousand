//
//  TimeHorizonsView.swift
//  TenThousand
//
//  View for visualizing time remaining and life milestones
//

import SwiftUI

struct TimeHorizonsView: View {
    @ObservedObject var viewModel: AppViewModel
    @AppStorage("userBirthdate") private var birthdateTimestamp: Double = 0
    @State private var isEditingBirthdate = false
    @State private var selectedDate = Date()
    @State private var customMilestones: [Int] = [30, 40, 50, 60]
    @State private var isEditingMilestones = false

    private var birthdate: Date? {
        birthdateTimestamp > 0 ? Date(timeIntervalSince1970: birthdateTimestamp) : nil
    }

    private var age: Int? {
        guard let birthdate = birthdate else { return nil }
        return Calendar.current.dateComponents([.year], from: birthdate, to: Date()).year
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header with back button
                headerSection

                Divider()

                // Birthdate input section
                birthdateSection

                if birthdate != nil {
                    Divider()

                    // Life milestones section
                    lifeMilestonesSection

                    Divider()

                    // Time horizons section
                    timeHorizonsSection
                }
            }
        }
        .frame(width: Dimensions.panelWidth)
        .background(Color.canvasBase)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            Button(action: {
                withAnimation(.panelTransition) {
                    viewModel.showingTimeHorizons = false
                }
            }) {
                HStack(spacing: Spacing.tight) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: Dimensions.iconSizeSmall))
                        .foregroundColor(.secondary)

                    Text("Back")
                        .font(Typography.body)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()

            Text("Time Horizons")
                .font(Typography.display)
                .foregroundColor(.primary)

            Spacer()

            // Invisible spacer to center the title
            HStack(spacing: Spacing.tight) {
                Image(systemName: "chevron.left")
                    .font(.system(size: Dimensions.iconSizeSmall))
                Text("Back")
                    .font(Typography.body)
            }
            .opacity(0)
        }
        .padding(.horizontal, Spacing.base)
        .padding(.vertical, Spacing.tight)
        .frame(height: Dimensions.skillRowHeight)
    }

    // MARK: - Birthdate Section

    private var birthdateSection: some View {
        VStack(alignment: .leading, spacing: Spacing.base) {
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: Dimensions.iconSizeSmall))
                    .foregroundColor(.secondary)

                Text("Your Birthdate")
                    .font(Typography.body)
                    .foregroundColor(.primary)

                Spacer()

                if birthdate != nil {
                    Button(action: {
                        isEditingBirthdate.toggle()
                    }) {
                        Text(isEditingBirthdate ? "Done" : "Edit")
                            .font(Typography.caption)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }

            if let birthdate = birthdate, !isEditingBirthdate {
                HStack {
                    Text(birthdate, style: .date)
                        .font(Typography.body)
                        .foregroundColor(.secondary)

                    if let age = age {
                        Text("(\(age) years old)")
                            .font(Typography.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                DatePicker(
                    "Select your birthdate",
                    selection: Binding(
                        get: { birthdate ?? selectedDate },
                        set: { newDate in
                            selectedDate = newDate
                            birthdateTimestamp = newDate.timeIntervalSince1970
                            isEditingBirthdate = false
                        }
                    ),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
            }
        }
        .padding(Spacing.base)
    }

    // MARK: - Life Milestones Section

    private var lifeMilestonesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.base) {
            HStack {
                Image(systemName: "flag.fill")
                    .font(.system(size: Dimensions.iconSizeSmall))
                    .foregroundColor(.secondary)

                Text("Life Milestones")
                    .font(Typography.display)
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(.bottom, Spacing.tight)

            if let age = age {
                ForEach(customMilestones.sorted(), id: \.self) { milestone in
                    if age < milestone {
                        milestoneCard(for: milestone, currentAge: age)
                    }
                }

                if customMilestones.allSatisfy({ age >= $0 }) {
                    VStack(spacing: Spacing.tight) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: Dimensions.iconSizeMedium))
                            .foregroundColor(.green)

                        Text("You've reached all milestones!")
                            .font(Typography.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.base)
                }
            }
        }
        .padding(Spacing.base)
    }

    private func milestoneCard(for milestone: Int, currentAge: Int) -> some View {
        let hoursRemaining = calculateHoursToMilestone(milestone: milestone, currentAge: currentAge)
        let skillsEquivalent = hoursRemaining / 10_000

        return VStack(alignment: .leading, spacing: Spacing.tight) {
            HStack {
                Text("Age \(milestone)")
                    .font(Typography.display)
                    .foregroundColor(.primary)

                Spacer()

                Text("\(milestone - currentAge) years")
                    .font(Typography.caption)
                    .foregroundColor(.secondary)
            }

            Text("\(formatLargeNumber(hoursRemaining)) hours remaining")
                .font(Typography.body)
                .foregroundColor(.secondary)

            if skillsEquivalent > 0 {
                Text("Enough for \(skillsEquivalent) skill\(skillsEquivalent == 1 ? "" : "s") to mastery")
                    .font(Typography.caption)
                    .foregroundColor(.green)
            }
        }
        .padding(Spacing.base)
        .background(Color.primary.opacity(Opacity.backgroundLight))
        .cornerRadius(Dimensions.cornerRadiusMedium)
    }

    // MARK: - Time Horizons Section

    private var timeHorizonsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.base) {
            HStack {
                Image(systemName: "hourglass")
                    .font(.system(size: Dimensions.iconSizeSmall))
                    .foregroundColor(.secondary)

                Text("Time Available")
                    .font(Typography.display)
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(.bottom, Spacing.tight)

            timeHorizonCard(
                title: "Today",
                icon: "sun.max.fill",
                hours: hoursRemainingToday(),
                message: inspiringMessage(for: .today)
            )

            timeHorizonCard(
                title: "This Week",
                icon: "calendar.badge.clock",
                hours: hoursRemainingThisWeek(),
                message: inspiringMessage(for: .week)
            )

            timeHorizonCard(
                title: "This Month",
                icon: "calendar",
                hours: hoursRemainingThisMonth(),
                message: inspiringMessage(for: .month)
            )

            timeHorizonCard(
                title: "This Year",
                icon: "sparkles",
                hours: hoursRemainingThisYear(),
                message: inspiringMessage(for: .year)
            )

            // Daily time budget
            dailyBudgetSection
        }
        .padding(Spacing.base)
    }

    private func timeHorizonCard(title: String, icon: String, hours: Int, message: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.tight) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: Dimensions.iconSizeSmall))
                    .foregroundColor(.blue)

                Text(title)
                    .font(Typography.body)
                    .foregroundColor(.primary)

                Spacer()

                Text("\(hours)h")
                    .font(Typography.timeDisplay)
                    .foregroundColor(.primary)
            }

            Text(message)
                .font(Typography.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(Spacing.base)
        .background(Color.primary.opacity(Opacity.backgroundSubtle))
        .cornerRadius(Dimensions.cornerRadiusSmall)
    }

    private var dailyBudgetSection: some View {
        VStack(alignment: .leading, spacing: Spacing.tight) {
            HStack {
                Image(systemName: "target")
                    .font(.system(size: Dimensions.iconSizeSmall))
                    .foregroundColor(.orange)

                Text("Daily Practice Budget")
                    .font(Typography.body)
                    .foregroundColor(.primary)
            }

            let budgetHours = 3 // Assuming 3 hours/day for deliberate practice
            let hoursToday = hoursRemainingToday()
            let sessionsAvailable = max(0, hoursToday / budgetHours)

            if sessionsAvailable > 0 {
                Text("You have \(hoursToday) hours left today")
                    .font(Typography.caption)
                    .foregroundColor(.secondary)

                Text("Enough for \(sessionsAvailable) focused practice session\(sessionsAvailable == 1 ? "" : "s")")
                    .font(Typography.caption)
                    .foregroundColor(.green)
            } else {
                Text("Rest and recharge for tomorrow")
                    .font(Typography.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(Spacing.base)
        .background(Color.orange.opacity(Opacity.backgroundSubtle))
        .cornerRadius(Dimensions.cornerRadiusMedium)
    }

    // MARK: - Calculations

    private func calculateHoursToMilestone(milestone: Int, currentAge: Int) -> Int {
        let yearsRemaining = milestone - currentAge
        let daysRemaining = yearsRemaining * 365
        return daysRemaining * 24
    }

    private func hoursRemainingToday() -> Int {
        let calendar = Calendar.current
        let now = Date()

        guard let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) else {
            return 0
        }

        let secondsRemaining = endOfDay.timeIntervalSince(now)
        return max(0, Int(secondsRemaining / 3600))
    }

    private func hoursRemainingThisWeek() -> Int {
        let calendar = Calendar.current
        let now = Date()

        guard let endOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)),
              let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: endOfWeek) else {
            return 0
        }

        let secondsRemaining = nextWeek.timeIntervalSince(now)
        return max(0, Int(secondsRemaining / 3600))
    }

    private func hoursRemainingThisMonth() -> Int {
        let calendar = Calendar.current
        let now = Date()

        guard let endOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let nextMonth = calendar.date(byAdding: .month, value: 1, to: endOfMonth) else {
            return 0
        }

        let secondsRemaining = nextMonth.timeIntervalSince(now)
        return max(0, Int(secondsRemaining / 3600))
    }

    private func hoursRemainingThisYear() -> Int {
        let calendar = Calendar.current
        let now = Date()

        guard let endOfYear = calendar.date(from: calendar.dateComponents([.year], from: now)),
              let nextYear = calendar.date(byAdding: .year, value: 1, to: endOfYear) else {
            return 0
        }

        let secondsRemaining = nextYear.timeIntervalSince(now)
        return max(0, Int(secondsRemaining / 3600))
    }

    enum TimeHorizon {
        case today, week, month, year
    }

    private func inspiringMessage(for horizon: TimeHorizon) -> String {
        switch horizon {
        case .today:
            return "\(hoursRemainingToday()) hours to make today count"
        case .week:
            return "Focus on small daily wins"
        case .month:
            return "Build momentum with consistent practice"
        case .year:
            return "Transform your skills over time"
        }
    }

    private func formatLargeNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

#Preview {
    TimeHorizonsView(viewModel: AppViewModel(persistenceController: .preview))
}
