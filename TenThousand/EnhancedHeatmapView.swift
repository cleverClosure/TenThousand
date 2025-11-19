//
//  EnhancedHeatmapView.swift
//  TenThousand
//
//  Advanced heatmap visualization with year/month/week views
//

import SwiftUI

struct EnhancedHeatmapView: View {
    let skill: Skill?
    let viewMode: HeatmapViewMode
    @ObservedObject var viewModel: AppViewModel
    @State private var hoveredDate: Date? = nil
    @State private var hoveredHour: Int? = nil
    @Namespace private var animation

    private var displayColor: Color {
        if let skill = skill {
            let colors: [Color] = [
                .skillRed, .skillOrange, .skillYellow, .skillGreen,
                .skillTeal, .trackingBlue, .skillPurple, .skillPink
            ]
            return colors[Int(skill.colorIndex) % colors.count]
        } else {
            return .trackingBlue
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            switch viewMode {
            case .week:
                weekView
            case .month:
                monthView
            case .year:
                yearView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Week View (Hourly Breakdown)

    private var weekView: some View {
        let hourlyData = viewModel.hourlyWeekDataForSkill(skill)
        let calendar = Calendar.current
        let today = Date()

        return ScrollView {
            VStack(alignment: .leading, spacing: Spacing.section) {
                // Title
                Text("Hourly Activity - Past 7 Days")
                    .font(Typography.display)
                    .kerning(Typography.displayKerning)
                    .padding(.horizontal, Spacing.section)
                    .padding(.top, Spacing.section)

                // Day grid
                ForEach((0..<7).reversed(), id: \.self) { dayOffset in
                    if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                        let dayStart = calendar.startOfDay(for: date)
                        let hours = hourlyData[dayStart] ?? [:]

                        VStack(alignment: .leading, spacing: Spacing.tight) {
                            // Day label
                            Text(formatWeekDayLabel(date))
                                .font(Typography.body)
                                .kerning(Typography.bodyKerning)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, Spacing.section)

                            // 24-hour grid
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 4) {
                                    ForEach(0..<24, id: \.self) { hour in
                                        hourCell(
                                            date: dayStart,
                                            hour: hour,
                                            seconds: hours[hour] ?? 0
                                        )
                                    }
                                }
                                .padding(.horizontal, Spacing.section)
                            }
                        }
                    }
                }

                // Hour labels
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(0..<24, id: \.self) { hour in
                            Text("\(hour)")
                                .font(Typography.caption)
                                .kerning(Typography.captionKerning)
                                .foregroundColor(.secondary)
                                .frame(width: 48)
                        }
                    }
                    .padding(.horizontal, Spacing.section)
                }
                .padding(.bottom, Spacing.section)
            }
        }
    }

    private func hourCell(date: Date, hour: Int, seconds: Int64) -> some View {
        let isHovered = hoveredDate == date && hoveredHour == hour
        let opacity = intensityOpacity(for: seconds)

        return RoundedRectangle(cornerRadius: 4)
            .fill(displayColor.opacity(opacity))
            .frame(width: 48, height: 48)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(Color.primary.opacity(0.3), lineWidth: isHovered ? 2 : 0)
            )
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .animation(.hoverState, value: isHovered)
            .onHover { hovering in
                if hovering {
                    hoveredDate = date
                    hoveredHour = hour
                } else if hoveredDate == date && hoveredHour == hour {
                    hoveredDate = nil
                    hoveredHour = nil
                }
            }
            .overlay(
                Group {
                    if isHovered {
                        hourTooltip(date: date, hour: hour, seconds: seconds)
                    }
                }
            )
    }

    private func hourTooltip(date: Date, hour: Int, seconds: Int64) -> some View {
        VStack(spacing: Spacing.tight) {
            Text(date.formatted(date: .abbreviated, time: .omitted))
                .font(Typography.caption)
                .kerning(Typography.captionKerning)

            Text("\(hour):00 - \(hour):59")
                .font(Typography.caption)
                .kerning(Typography.captionKerning)
                .fontWeight(.medium)

            if seconds > 0 {
                let minutes = Double(seconds) / 60.0
                Text(String(format: "%.1f minutes", minutes))
                    .font(Typography.caption)
                    .kerning(Typography.captionKerning)
            } else {
                Text("No activity")
                    .font(Typography.caption)
                    .kerning(Typography.captionKerning)
            }
        }
        .padding(Spacing.base)
        .background(
            RoundedRectangle(cornerRadius: Dimensions.cornerRadiusSmall)
                .fill(Color.primary.opacity(0.95))
        )
        .foregroundColor(Color(nsColor: .controlBackgroundColor))
        .offset(y: -70)
        .zIndex(100)
    }

    // MARK: - Month View (30 Days with Larger Cells)

    private var monthView: some View {
        let heatmapData = skill != nil
            ? viewModel.heatmapDataForSkill(skill!, daysBack: 30)
            : viewModel.combinedHeatmapData(daysBack: 30)

        let calendar = Calendar.current
        let today = Date()

        return ScrollView {
            VStack(alignment: .leading, spacing: Spacing.section) {
                // Title
                Text("Daily Activity - Past 30 Days")
                    .font(Typography.display)
                    .kerning(Typography.displayKerning)
                    .padding(.horizontal, Spacing.section)
                    .padding(.top, Spacing.section)

                // Grid layout (5 rows × 6 columns = 30 days)
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6),
                    spacing: 8
                ) {
                    ForEach((0..<30).reversed(), id: \.self) { dayOffset in
                        if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                            let dayStart = calendar.startOfDay(for: date)
                            let seconds = heatmapData[dayStart] ?? 0

                            monthCell(date: dayStart, seconds: seconds)
                        }
                    }
                }
                .padding(.horizontal, Spacing.section)
                .padding(.bottom, Spacing.section)
            }
        }
    }

    private func monthCell(date: Date, seconds: Int64) -> some View {
        let isHovered = hoveredDate == date
        let opacity = intensityOpacity(for: seconds)

        return VStack(spacing: Spacing.tight) {
            // Date label
            Text(date.formatted(.dateTime.day()))
                .font(Typography.body)
                .kerning(Typography.bodyKerning)
                .foregroundColor(.secondary)

            // Cell
            RoundedRectangle(cornerRadius: 8)
                .fill(displayColor.opacity(opacity))
                .frame(height: 64)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.primary.opacity(0.3), lineWidth: isHovered ? 2 : 0)
                )
                .overlay(
                    // Show hours in cell
                    Group {
                        if seconds > 0 {
                            Text(formatHours(seconds: seconds))
                                .font(Typography.caption)
                                .kerning(Typography.captionKerning)
                                .fontWeight(.medium)
                                .foregroundColor(opacity > 0.5 ? .white : .primary)
                        }
                    }
                )
                .scaleEffect(isHovered ? 1.05 : 1.0)
                .animation(.hoverState, value: isHovered)
                .onHover { hovering in
                    hoveredDate = hovering ? date : nil
                }
                .overlay(
                    Group {
                        if isHovered {
                            dayTooltip(date: date, seconds: seconds)
                        }
                    }
                )
        }
    }

    // MARK: - Year View (365 Days GitHub Style)

    private var yearView: some View {
        let heatmapData = skill != nil
            ? viewModel.heatmapDataForSkill(skill!, daysBack: 365)
            : viewModel.combinedHeatmapData(daysBack: 365)

        return ScrollView {
            VStack(alignment: .leading, spacing: Spacing.section) {
                // Title
                Text("Daily Activity - Past Year")
                    .font(Typography.display)
                    .kerning(Typography.displayKerning)
                    .padding(.horizontal, Spacing.section)
                    .padding(.top, Spacing.section)

                // GitHub-style calendar
                GitHubStyleCalendar(
                    data: heatmapData,
                    color: displayColor,
                    hoveredDate: $hoveredDate
                )
                .padding(.horizontal, Spacing.section)

                // Legend
                legendView
                    .padding(.horizontal, Spacing.section)
                    .padding(.bottom, Spacing.section)
            }
        }
    }

    private var legendView: some View {
        HStack(spacing: Spacing.base) {
            Text("Less")
                .font(Typography.caption)
                .kerning(Typography.captionKerning)
                .foregroundColor(.secondary)

            ForEach(0..<7, id: \.self) { level in
                RoundedRectangle(cornerRadius: 2)
                    .fill(displayColor.opacity(opacityForLevel(level)))
                    .frame(width: 14, height: 14)
            }

            Text("More")
                .font(Typography.caption)
                .kerning(Typography.captionKerning)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Tooltip

    private func dayTooltip(date: Date, seconds: Int64) -> some View {
        VStack(spacing: Spacing.tight) {
            Text(date.formatted(date: .long, time: .omitted))
                .font(Typography.caption)
                .kerning(Typography.captionKerning)

            if seconds > 0 {
                let hours = Double(seconds) / 3600.0
                Text(String(format: "%.1f hours", hours))
                    .font(Typography.caption)
                    .kerning(Typography.captionKerning)
                    .fontWeight(.medium)
            } else {
                Text("No activity")
                    .font(Typography.caption)
                    .kerning(Typography.captionKerning)
            }
        }
        .padding(Spacing.base)
        .background(
            RoundedRectangle(cornerRadius: Dimensions.cornerRadiusSmall)
                .fill(Color.primary.opacity(0.95))
        )
        .foregroundColor(Color(nsColor: .controlBackgroundColor))
        .offset(y: -80)
        .zIndex(100)
    }

    // MARK: - Helper Functions

    private func intensityOpacity(for seconds: Int64) -> Double {
        if seconds == 0 { return 0.05 }

        let hours = Double(seconds) / 3600.0

        // Progressive intensity levels
        if hours < 0.25 { return 0.15 }      // < 15 min
        if hours < 0.5 { return 0.30 }       // < 30 min
        if hours < 1.0 { return 0.45 }       // < 1 hour
        if hours < 2.0 { return 0.60 }       // < 2 hours
        if hours < 3.0 { return 0.75 }       // < 3 hours
        return 0.90                           // 3+ hours
    }

    private func opacityForLevel(_ level: Int) -> Double {
        switch level {
        case 0: return 0.05
        case 1: return 0.15
        case 2: return 0.30
        case 3: return 0.45
        case 4: return 0.60
        case 5: return 0.75
        case 6: return 0.90
        default: return 0.05
        }
    }

    private func formatWeekDayLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }

    private func formatHours(seconds: Int64) -> String {
        let hours = Double(seconds) / 3600.0
        if hours < 1.0 {
            let minutes = Int(Double(seconds) / 60.0)
            return "\(minutes)m"
        }
        return String(format: "%.1fh", hours)
    }
}

// MARK: - GitHub-Style Calendar Component

struct GitHubStyleCalendar: View {
    let data: [Date: Int64]
    let color: Color
    @Binding var hoveredDate: Date?

    private let weeksToShow = 53
    private let cellSize: CGFloat = 14
    private let cellSpacing: CGFloat = 4

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.tight) {
            // Month labels
            monthLabelsView

            HStack(alignment: .top, spacing: 0) {
                // Day labels
                dayLabelsView

                // Calendar grid
                calendarGridView
            }
        }
    }

    private var monthLabelsView: some View {
        HStack(spacing: 0) {
            Spacer().frame(width: 30)

            let calendar = Calendar.current
            let today = Date()
            let startDate = calendar.date(byAdding: .day, value: -364, to: today) ?? today

            ForEach(0..<12, id: \.self) { monthIndex in
                if let monthStart = calendar.date(byAdding: .month, value: monthIndex, to: startDate),
                   monthStart <= today {
                    let daysSinceStart = calendar.dateComponents([.day], from: startDate, to: monthStart).day ?? 0
                    let weekPosition = daysSinceStart / 7

                    if weekPosition < weeksToShow {
                        Text(monthStart.formatted(.dateTime.month(.abbreviated)))
                            .font(Typography.caption)
                            .kerning(Typography.captionKerning)
                            .foregroundColor(.secondary)
                            .frame(width: (cellSize + cellSpacing) * 4.35, alignment: .leading)
                            .offset(x: CGFloat(weekPosition) * (cellSize + cellSpacing))
                    }
                }
            }

            Spacer()
        }
        .frame(height: 16)
    }

    private var dayLabelsView: some View {
        VStack(alignment: .trailing, spacing: cellSpacing) {
            Spacer().frame(height: cellSize)
            Text("Mon")
                .font(Typography.caption)
                .kerning(Typography.captionKerning)
                .foregroundColor(.secondary)
                .frame(height: cellSize)
            Spacer().frame(height: cellSize)
            Text("Wed")
                .font(Typography.caption)
                .kerning(Typography.captionKerning)
                .foregroundColor(.secondary)
                .frame(height: cellSize)
            Spacer().frame(height: cellSize)
            Text("Fri")
                .font(Typography.caption)
                .kerning(Typography.captionKerning)
                .foregroundColor(.secondary)
                .frame(height: cellSize)
            Spacer().frame(height: cellSize)
        }
        .frame(width: 30)
    }

    private var calendarGridView: some View {
        let calendar = Calendar.current
        let today = Date()
        let startDate = calendar.date(byAdding: .day, value: -364, to: today) ?? today

        let weekdayOfStart = calendar.component(.weekday, from: startDate)
        let adjustedStartDate = calendar.date(byAdding: .day, value: -(weekdayOfStart - 1), to: startDate) ?? startDate

        return HStack(alignment: .top, spacing: cellSpacing) {
            ForEach(0..<weeksToShow, id: \.self) { weekIndex in
                VStack(spacing: cellSpacing) {
                    ForEach(0..<7, id: \.self) { dayIndex in
                        let dayOffset = weekIndex * 7 + dayIndex
                        if let cellDate = calendar.date(byAdding: .day, value: dayOffset, to: adjustedStartDate),
                           cellDate <= today {
                            calendarCell(date: cellDate, seconds: data[cellDate] ?? 0)
                        } else {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
        }
    }

    private func calendarCell(date: Date, seconds: Int64) -> some View {
        let isHovered = hoveredDate == date
        let opacity = intensityOpacity(for: seconds)

        return RoundedRectangle(cornerRadius: 2)
            .fill(color.opacity(opacity))
            .frame(width: cellSize, height: cellSize)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .strokeBorder(Color.primary.opacity(0.3), lineWidth: isHovered ? 1 : 0)
            )
            .scaleEffect(isHovered ? 1.15 : 1.0)
            .animation(.hoverState, value: isHovered)
            .onHover { hovering in
                hoveredDate = hovering ? date : nil
            }
    }

    private func intensityOpacity(for seconds: Int64) -> Double {
        if seconds == 0 { return 0.05 }

        let hours = Double(seconds) / 3600.0

        if hours < 0.5 { return 0.15 }
        if hours < 1.0 { return 0.30 }
        if hours < 2.0 { return 0.45 }
        if hours < 3.0 { return 0.60 }
        if hours < 4.0 { return 0.75 }
        return 0.90
    }
}
