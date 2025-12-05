//
//  SwiftDataStore.swift
//  TenThousand
//
//  Created by Tim Isaev
//
//  SwiftData implementation of DataStore protocol
//

import Foundation
import os.log
import SwiftData

/// SwiftData implementation of the DataStore protocol.
final class SwiftDataStore: DataStore {
    // MARK: - Properties

    /// Shared singleton instance for production use.
    static let shared = SwiftDataStore()

    let modelContainer: ModelContainer
    let modelContext: ModelContext

    private let logger = Logger(subsystem: "com.tenthousand.app", category: "SwiftDataStore")

    // MARK: - Initialization

    /// Creates a SwiftDataStore with the default configuration.
    init() {
        do {
            let schema = Schema([Skill.self, Session.self])
            let configuration = ModelConfiguration(isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
            modelContext = ModelContext(modelContainer)
            modelContext.autosaveEnabled = false
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    /// Creates an in-memory SwiftDataStore for testing.
    /// - Parameter inMemory: Must be true (only used for API consistency).
    private init(inMemory: Bool) {
        do {
            let schema = Schema([Skill.self, Session.self])
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
            modelContext = ModelContext(modelContainer)
            modelContext.autosaveEnabled = false
        } catch {
            fatalError("Failed to create in-memory ModelContainer: \(error)")
        }
    }

    /// Creates an in-memory SwiftDataStore for testing.
    /// - Returns: A SwiftDataStore backed by in-memory storage.
    static func inMemory() -> SwiftDataStore {
        SwiftDataStore(inMemory: true)
    }

    // MARK: - Skill Operations

    func fetchAllSkills() -> [Skill] {
        let descriptor = FetchDescriptor<Skill>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            logger.error("Failed to fetch skills: \(error.localizedDescription)")
            return []
        }
    }

    @discardableResult
    func createSkill(name: String, paletteId: String, colorIndex: Int16) -> Skill {
        let skill = Skill(name: name, paletteId: paletteId, colorIndex: colorIndex)
        modelContext.insert(skill)
        return skill
    }

    func deleteSkill(_ skill: Skill) {
        modelContext.delete(skill)
    }

    // MARK: - Session Operations

    @discardableResult
    func createSession(for skill: Skill) -> Session {
        let session = Session(skill: skill)
        skill.sessions.append(session)
        modelContext.insert(session)
        return session
    }

    func completeSession(_ session: Session, endTime: Date, pausedDuration: Int64) {
        session.endTime = endTime
        session.pausedDuration = pausedDuration
    }

    func fetchSessions(from startDate: Date) -> [Session] {
        let descriptor = FetchDescriptor<Session>(
            predicate: #Predicate<Session> { session in
                session.startTime >= startDate
            }
        )

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            logger.error("Failed to fetch sessions: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - Persistence

    func save() {
        do {
            if modelContext.hasChanges {
                try modelContext.save()
            }
        } catch {
            logger.error("Failed to save context: \(error.localizedDescription)")
        }
    }
}
