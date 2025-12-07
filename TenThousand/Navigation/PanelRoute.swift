//
//  PanelRoute.swift
//  TenThousand
//
//  Author: Tim Isaev
//
//  Explicit navigation state for the dropdown panel
//

import Foundation

// MARK: - PanelRoute

/// Represents the current navigation state of the dropdown panel.
/// Separates view routing from application state (like active tracking).
enum PanelRoute: Equatable {
    /// The main skill list view
    case skillList

    /// Detailed view for a specific skill
    case skillDetail(Skill)

    /// Active tracking view (shown when a session is in progress)
    case activeTracking

    /// Edit view for modifying skill settings
    case skillEdit(Skill)

    #if DEBUG
    /// Developer debug screen (only available in debug builds)
    case debug
    #endif

    // MARK: - Equatable

    static func == (lhs: PanelRoute, rhs: PanelRoute) -> Bool {
        switch (lhs, rhs) {
        case (.skillList, .skillList):
            return true
        case (.activeTracking, .activeTracking):
            return true
        case let (.skillDetail(lhsSkill), .skillDetail(rhsSkill)):
            return lhsSkill.id == rhsSkill.id
        case let (.skillEdit(lhsSkill), .skillEdit(rhsSkill)):
            return lhsSkill.id == rhsSkill.id
        #if DEBUG
        case (.debug, .debug):
            return true
        #endif
        default:
            return false
        }
    }
}
