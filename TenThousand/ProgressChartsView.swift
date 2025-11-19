//
//  ProgressChartsView.swift
//  TenThousand
//
//  Interactive progress charts showing cumulative hours and daily/weekly totals
//

import SwiftUI
import Charts

struct ProgressChartsView: View {
    let skill: Skill
    @ObservedObject var viewModel: AppViewModel

    @State private var selectedPeriod: ChartPeriod = .thirtyDays
    @State private var selectedView: ChartView = .daily
    @State private var selectedDataPoint: Date?
    @State private var scrollPosition: Date?

    enum ChartPeriod: String, CaseIterable {
        case thirtyDays = "30 Days"
        case ninetyDays = "90 Days"
        case year = "1 Year"

        var daysBack: Int {
            switch self {
            case .thirtyDays: return 30
            case .ninetyDays: return 90
            case .year: return 365
            }
        }

        var weeksBack: Int {
            return daysBack / 7
        }
    }

    enum ChartView: String, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
    }

    var body: some View {
        VStack(spacing: Spacing.section) {
            // Header with period selector
            headerSection

            // Cumulative hours chart
            cumulativeChartSection

            // Daily/Weekly totals chart
            totalsChartSection
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            Text("Progress Charts")
                .font(Typography.body)
                .kerning(Typography.bodyKerning)
                .foregroundColor(.secondary)

            Spacer()

            // Period selector
            Picker("Period", selection: $selectedPeriod) {
                ForEach(ChartPeriod.allCases, id: \.self) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 250)
        }
    }

    // MARK: - Cumulative Chart Section

    private var cumulativeChartSection: some View {
        VStack(alignment: .leading, spacing: Spacing.base) {
            Text("Cumulative Hours")
                .font(Typography.caption)
                .kerning(Typography.captionKerning)
                .foregroundColor(.secondary)

            cumulativeChart
                .frame(height: 200)
        }
        .padding(Spacing.loose)
        .background(
            RoundedRectangle(cornerRadius: Dimensions.cornerRadiusMedium)
                .fill(Color.primary.opacity(Opacity.backgroundMedium))
        )
    }

    private var cumulativeChart: some View {
        let data = viewModel.cumulativeHoursForSkill(skill, daysBack: selectedPeriod.daysBack)

        return Chart {
            ForEach(data, id: \.date) { dataPoint in
                LineMark(
                    x: .value("Date", dataPoint.date),
                    y: .value("Hours", dataPoint.hours)
                )
                .foregroundStyle(skillColor(for: skill.colorIndex))
                .lineStyle(StrokeStyle(lineWidth: 2))

                AreaMark(
                    x: .value("Date", dataPoint.date),
                    y: .value("Hours", dataPoint.hours)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            skillColor(for: skill.colorIndex).opacity(0.3),
                            skillColor(for: skill.colorIndex).opacity(0.05)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                if let selectedDate = selectedDataPoint,
                   Calendar.current.isDate(dataPoint.date, inSameDayAs: selectedDate) {
                    RuleMark(x: .value("Selected", dataPoint.date))
                        .foregroundStyle(.secondary.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: selectedPeriod == .year ? 60 : (selectedPeriod == .ninetyDays ? 15 : 5))) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let hours = value.as(Double.self) {
                        Text("\(Int(hours))h")
                            .font(Typography.caption)
                    }
                }
            }
        }
        .chartXSelection(value: $selectedDataPoint)
        .chartScrollableAxes(.horizontal)
        .overlay(alignment: .topTrailing) {
            if let selectedDate = selectedDataPoint,
               let dataPoint = data.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
                tooltipView(date: dataPoint.date, value: dataPoint.hours, unit: "hours")
            }
        }
    }

    // MARK: - Totals Chart Section

    private var totalsChartSection: some View {
        VStack(alignment: .leading, spacing: Spacing.base) {
            HStack {
                Text("Time Distribution")
                    .font(Typography.caption)
                    .kerning(Typography.captionKerning)
                    .foregroundColor(.secondary)

                Spacer()

                // Daily/Weekly toggle
                Picker("View", selection: $selectedView) {
                    ForEach(ChartView.allCases, id: \.self) { view in
                        Text(view.rawValue).tag(view)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 150)
            }

            totalsChart
                .frame(height: 250)
        }
        .padding(Spacing.loose)
        .background(
            RoundedRectangle(cornerRadius: Dimensions.cornerRadiusMedium)
                .fill(Color.primary.opacity(Opacity.backgroundMedium))
        )
    }

    private var totalsChart: some View {
        Group {
            if selectedView == .daily {
                dailyBarChart
            } else {
                weeklyBarChart
            }
        }
    }

    private var dailyBarChart: some View {
        let data = viewModel.dailyTotalsForSkill(skill, daysBack: selectedPeriod.daysBack)

        return Chart {
            ForEach(data, id: \.date) { dataPoint in
                BarMark(
                    x: .value("Date", dataPoint.date),
                    y: .value("Hours", Double(dataPoint.seconds) / 3600.0)
                )
                .foregroundStyle(skillColor(for: skill.colorIndex))

                if let selectedDate = selectedDataPoint,
                   Calendar.current.isDate(dataPoint.date, inSameDayAs: selectedDate) {
                    RuleMark(x: .value("Selected", dataPoint.date))
                        .foregroundStyle(.secondary.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: selectedPeriod == .year ? 30 : (selectedPeriod == .ninetyDays ? 10 : 3))) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let hours = value.as(Double.self) {
                        Text("\(Int(hours))h")
                            .font(Typography.caption)
                    }
                }
            }
        }
        .chartXSelection(value: $selectedDataPoint)
        .chartScrollableAxes(.horizontal)
        .overlay(alignment: .topTrailing) {
            if let selectedDate = selectedDataPoint,
               let dataPoint = data.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
                tooltipView(
                    date: dataPoint.date,
                    value: Double(dataPoint.seconds) / 3600.0,
                    unit: "hours"
                )
            }
        }
    }

    private var weeklyBarChart: some View {
        let data = viewModel.weeklyTotalsForSkill(skill, weeksBack: selectedPeriod.weeksBack)

        return Chart {
            ForEach(data, id: \.date) { dataPoint in
                BarMark(
                    x: .value("Week", dataPoint.date),
                    y: .value("Hours", Double(dataPoint.seconds) / 3600.0)
                )
                .foregroundStyle(skillColor(for: skill.colorIndex))

                if let selectedDate = selectedDataPoint,
                   Calendar.current.isDate(dataPoint.date, inSameDayAs: selectedDate) {
                    RuleMark(x: .value("Selected", dataPoint.date))
                        .foregroundStyle(.secondary.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .weekOfYear, count: selectedPeriod.weeksBack > 20 ? 8 : 2)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let hours = value.as(Double.self) {
                        Text("\(Int(hours))h")
                            .font(Typography.caption)
                    }
                }
            }
        }
        .chartXSelection(value: $selectedDataPoint)
        .chartScrollableAxes(.horizontal)
        .overlay(alignment: .topTrailing) {
            if let selectedDate = selectedDataPoint,
               let dataPoint = data.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
                tooltipView(
                    date: dataPoint.date,
                    value: Double(dataPoint.seconds) / 3600.0,
                    unit: "hours",
                    isWeekly: true
                )
            }
        }
    }

    // MARK: - Tooltip View

    private func tooltipView(date: Date, value: Double, unit: String, isWeekly: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: Spacing.tight) {
            if isWeekly {
                Text("Week of \(date.formatted(date: .abbreviated, time: .omitted))")
                    .font(Typography.caption)
                    .kerning(Typography.captionKerning)
                    .foregroundColor(.secondary)
            } else {
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(Typography.caption)
                    .kerning(Typography.captionKerning)
                    .foregroundColor(.secondary)
            }

            Text(String(format: "%.1f %@", value, unit))
                .font(Typography.body)
                .kerning(Typography.bodyKerning)
                .foregroundColor(.primary)
        }
        .padding(Spacing.base)
        .background(
            RoundedRectangle(cornerRadius: Dimensions.cornerRadiusSmall)
                .fill(Color.primary.opacity(Opacity.backgroundDark))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .padding(Spacing.base)
    }

    // MARK: - Helper Functions

    private func skillColor(for index: Int16) -> Color {
        let colors: [Color] = [
            .skillRed, .skillOrange, .skillYellow, .skillGreen,
            .skillTeal, .trackingBlue, .skillPurple, .skillPink
        ]
        return colors[Int(index) % colors.count]
    }
}
