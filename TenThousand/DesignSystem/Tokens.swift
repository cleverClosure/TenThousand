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
    static let loose: CGFloat = 12
    static let section: CGFloat = 16
    static let chunk: CGFloat = 24
}

// MARK: - Dimensions

struct Dimensions {
    // Panel
    static let panelWidth: CGFloat = 280
    static let panelMinHeight: CGFloat = 120
    static let panelMaxHeight: CGFloat = 400
    static let panelCornerRadius: CGFloat = 12

    // Skill Row
    static let skillRowHeight: CGFloat = 36
    static let skillRowPaddingHorizontal: CGFloat = 8
    static let skillRowPaddingVertical: CGFloat = 6
    static let colorDotSize: CGFloat = 20

    // Active Session
    static let activeSessionHeight: CGFloat = 64

    // Today's Summary
    static let todaySummaryHeight: CGFloat = 48

    // Corner Radii
    static let cornerRadiusSmall: CGFloat = 4
    static let cornerRadiusMedium: CGFloat = 8
    static let cornerRadiusLarge: CGFloat = 12

    // Icon Sizes
    static let iconSizeSmall: CGFloat = 14
    static let iconSizeMedium: CGFloat = 24

    // Menubar
    static let menubarTimerWidth: CGFloat = 52

    // Dividers
    static let dividerHeight: CGFloat = 1
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
}

// MARK: - Layout Constants

struct LayoutConstants {
    static let maxSkillListHeight: CGFloat = 200
    static let skillNameLineLimit = 1
    static let borderWidth: CGFloat = 1
}

// MARK: - Mastery Constants

struct MasteryConstants {
    /// The 10,000 hour rule for mastery
    static let masteryHours: Int64 = 10_000
    static let masterySeconds: Int64 = masteryHours * TimeConstants.secondsPerHour
}
