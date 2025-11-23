//
//  DataStore.swift
//  TenThousand
//
//  Created by Tim Isaev
//
//  Protocol abstraction for persistence layer
//

import Foundation

/// Protocol defining persistence operations for the app.
///
/// This abstraction allows swapping between different persistence implementations
/// (CoreData, SwiftData, etc.) without modifying the consuming code.
protocol DataStore {
    // MARK: - Skill Operations

    /// Fetches all skills sorted by creation date.
    /// - Returns: Array of skills sorted by createdAt ascending.
    func fetchAllSkills() -> [Skill]

    /// Creates a new skill with the given name and color assignment.
    /// - Parameters:
    ///   - name: The skill name.
    ///   - paletteId: The color palette identifier.
    ///   - colorIndex: The color index within the palette.
    /// - Returns: The newly created skill.
    @discardableResult
    func createSkill(name: String, paletteId: String, colorIndex: Int16) -> Skill

    /// Deletes the specified skill.
    /// - Parameter skill: The skill to delete.
    func deleteSkill(_ skill: Skill)

    // MARK: - Session Operations

    /// Creates a new session for the specified skill.
    /// - Parameter skill: The skill to track.
    /// - Returns: The newly created session.
    @discardableResult
    func createSession(for skill: Skill) -> Session

    /// Completes a session by setting its end time and paused duration.
    /// - Parameters:
    ///   - session: The session to complete.
    ///   - endTime: The end time of the session.
    ///   - pausedDuration: Total paused duration in seconds.
    func completeSession(_ session: Session, endTime: Date, pausedDuration: Int64)

    /// Fetches sessions that started on or after the specified date.
    /// - Parameter startDate: The minimum start date.
    /// - Returns: Array of sessions starting on or after the date.
    func fetchSessions(from startDate: Date) -> [Session]

    // MARK: - Persistence

    /// Saves any pending changes to the persistent store.
    func save()
}
