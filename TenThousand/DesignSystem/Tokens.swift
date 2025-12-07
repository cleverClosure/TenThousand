//
//  Tokens.swift
//  TenThousand
//
//  Design tokens: spacing, dimensions, animations, and other constants
//

import SwiftUI

// MARK: - Spacing

struct Spacing {
    static let atomic: CGFloat = 2
    static let tight: CGFloat = 4
    static let base: CGFloat = 8
    static let compact: CGFloat = 10
    static let loose: CGFloat = 12
    static let section: CGFloat = 16
    static let comfortable: CGFloat = 20
    static let chunk: CGFloat = 24
    static let generous: CGFloat = 32
    static let spacious: CGFloat = 40
}

// MARK: - Dimensions

struct Dimensions {
    // Panel
    static let panelWidth: CGFloat = 320
    static let panelMinHeight: CGFloat = 140
    static let panelMaxHeight: CGFloat = 480
    static let panelCornerRadius: CGFloat = 14

    // Skill Row
    static let skillRowHeight: CGFloat = 72
    static let skillRowPaddingHorizontal: CGFloat = 12
    static let skillRowPaddingVertical: CGFloat = 10
    static let colorDotSize: CGFloat = 28
    static let colorDotSizeSmall: CGFloat = 12

    // Buttons
    static let compactButtonHeight: CGFloat = 36
    static let colorPickerButtonSize: CGFloat = 32

    // Progress Bar
    static let progressBarHeightSmall: CGFloat = 4
    static let progressBarHeightMedium: CGFloat = 6
    static let progressBarHeightLarge: CGFloat = 10

    // Circular Progress
    static let circularProgressSize: CGFloat = 140
    static let circularProgressStroke: CGFloat = 10
    static let circularProgressTrackOffset: CGFloat = 2
    static let circularProgressShadowOffset: CGFloat = 4

    // Active Session
    static let activeSessionHeight: CGFloat = 80
    static let pulseIndicatorSize: CGFloat = 6

    // Today's Summary
    static let todaySummaryHeight: CGFloat = 56

    // Corner Radii
    static let cornerRadiusSmall: CGFloat = 6
    static let cornerRadiusMedium: CGFloat = 10
    static let cornerRadiusLarge: CGFloat = 14

    // Icon Sizes (for frame dimensions)
    static let iconSizeSmall: CGFloat = 14
    static let iconSizeMedium: CGFloat = 24
    static let iconSizeLarge: CGFloat = 32

    // Menubar
    static let menubarTimerWidth: CGFloat = 52
    static let menubarIconSize: CGFloat = 20
    static let menubarStrokeWidth: CGFloat = 2

    // Dividers
    static let dividerHeight: CGFloat = 1

    // Hero Typography
    static let heroTimerSize: CGFloat = 64
    static let heroHoursSize: CGFloat = 56

    // Frame Widths
    static let percentageFrameWidth: CGFloat = 48
}

// MARK: - Icon Font Sizes

struct IconFontSize {
    static let tiny: CGFloat = 9
    static let small: CGFloat = 10
    static let caption: CGFloat = 11
    static let body: CGFloat = 12
    static let menubarTimer: CGFloat = 13
    static let medium: CGFloat = 14
    static let large: CGFloat = 16
    static let xl: CGFloat = 20
}

// MARK: - Circular Progress Sizing

struct CircularProgressSizing {
    static let valueFontRatio: CGFloat = 0.32
    static let labelFontRatio: CGFloat = 0.085
}

// MARK: - Animations

extension Animation {
    static let microInteraction = Animation.timingCurve(0.4, 0, 0.2, 1, duration: 0.2)
    static let panelTransition = Animation.timingCurve(0.4, 0, 0.2, 1, duration: 0.3)
    static let countUp = Animation.timingCurve(0.4, 0, 0.2, 1, duration: 0.4)
    static let hoverState = Animation.timingCurve(0.4, 0, 0.2, 1, duration: 0.15)
}

// MARK: - Opacity

struct Opacity {
    // Backgrounds
    static let backgroundSubtle: Double = 0.02
    static let backgroundLight: Double = 0.03
    static let backgroundMedium: Double = 0.05
    static let backgroundDark: Double = 0.08

    // Overlays & Highlights
    static let overlayLight: Double = 0.10
    static let overlayMedium: Double = 0.20
    static let overlayStrong: Double = 0.30

    // Borders & Strokes
    static let borderSubtle: Double = 0.30

    // States
    static let disabled: Double = 0.40

    // Icon & Text States
    static let secondaryIdle: Double = 0.35
    static let accentStrong: Double = 0.80

    // Color Picker
    static let colorPickerSelected: Double = 0.50
    static let colorPickerDefault: Double = 0.20
}

// MARK: - Shadows

struct ShadowConfig {
    let radius: CGFloat
    let xOffset: CGFloat
    let yOffset: CGFloat
    let opacity: Double
}

struct Shadows {
    static let floating = ShadowConfig(radius: 24, xOffset: 0, yOffset: 8, opacity: 0.12)
    static let subtle = ShadowConfig(radius: 2, xOffset: 0, yOffset: 0, opacity: 0.50)
    static let small = ShadowConfig(radius: 3, xOffset: 0, yOffset: 1, opacity: 0.50)
    static let medium = ShadowConfig(radius: 4, xOffset: 0, yOffset: 2, opacity: 0.40)
    static let progressGlow = ShadowConfig(radius: 6, xOffset: 0, yOffset: 2, opacity: 0.35)
    static let timerGlow = ShadowConfig(radius: 20, xOffset: 0, yOffset: 0, opacity: 0.30)
}

// MARK: - Scale Values

struct ScaleValues {
    static let normal: CGFloat = 1.0
    static let hoverGrow: CGFloat = 1.05
    static let pressedShrink: CGFloat = 0.98
    static let dismissScale: CGFloat = 0.95
}

// MARK: - Time Constants

struct TimeConstants {
    static let secondsPerMinute: Int64 = 60
    static let secondsPerMinuteDouble: Double = 60.0
    static let secondsPerHour: Int64 = 3600
    static let timerUpdateInterval: TimeInterval = 1.0
}

// MARK: - Validation Limits

struct ValidationLimits {
    static let maxSkillNameLength = 30
    static let maxSkillCount = 12
}

// MARK: - UI Text

struct UIText {
    static let skillNamePlaceholder = "Skill name..."
    static let defaultSkillName = "Untitled"
    static let todayLabel = "Today"
    static let addSkillLabel = "Add skill"
    static let errorEmptySkillName = "Skill name cannot be empty"
    static let errorDuplicateSkillName = "A skill with this name already exists"
    static let lessThanOneMinute = "<1m"
    static let hoursSuffix = "h"
    static let minutesSuffix = "m"
    static let hoursSeparator = "h "
    static let minutesSeparator = "m"
}

// MARK: - Format Strings

struct FormatStrings {
    static let timeWithHours = "%d:%02d:%02d"
    static let timeWithoutHours = "%02d:%02d"
}

// MARK: - Animation Durations

struct AnimationDurations {
    static let flash: Double = 0.1
    static let updateHighlight: Double = 1.0
    static let progressAppear: Double = 0.6
    static let progressUpdate: Double = 0.4
    static let circularAppear: Double = 0.8
    static let circularUpdate: Double = 0.5
    static let pulse: Double = 1.5
}

// MARK: - Layout Constants

struct LayoutConstants {
    static let maxSkillListHeight: CGFloat = 320
    static let skillNameLineLimit = 1
    static let borderWidth: CGFloat = 1
}

// MARK: - Mastery Constants

struct MasteryConstants {
    /// The 10,000 hour rule for mastery
    static let masteryHours: Int64 = 10_000
    static let masterySeconds: Int64 = masteryHours * TimeConstants.secondsPerHour
}

// MARK: - Mastery Projection

struct MasteryProjection {
    let years: Int
    let months: Int

    var formatted: String {
        if years == 0 && months == 0 {
            return "less than a month"
        } else if years == 0 {
            return "\(months) month\(months == 1 ? "" : "s")"
        } else if months == 0 {
            return "\(years) year\(years == 1 ? "" : "s")"
        } else {
            return "\(years) year\(years == 1 ? "" : "s"), \(months) month\(months == 1 ? "" : "s")"
        }
    }
}
