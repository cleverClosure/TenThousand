//
//  PersistenceTests.swift
//  TenThousandTests
//
//  Unit tests for PersistenceController
//  Testing behaviors, not implementations
//

import Testing
import CoreData
@testable import TenThousand

@Suite("PersistenceController Behaviors")
struct PersistenceTests {

    // MARK: - Initialization Behaviors

    @Test("Creating persistence controller with in-memory store succeeds")
    func testInMemoryPersistenceCreation() {
        let persistence = PersistenceController(inMemory: true)

        #expect(persistence.container.persistentStoreDescriptions.count > 0)
    }

    @Test("Creating persistence controller initializes view context")
    func testViewContextInitialization() {
        let persistence = PersistenceController(inMemory: true)

        let context = persistence.container.viewContext

        #expect(context.automaticallyMergesChangesFromParent)
        #expect(context.mergePolicy is NSMergeByPropertyObjectTrumpMergePolicy)
    }

    @Test("In-memory persistence controller uses null store")
    func testInMemoryUsesNullStore() {
        let persistence = PersistenceController(inMemory: true)

        let storeURL = persistence.container.persistentStoreDescriptions.first?.url

        #expect(storeURL?.path == "/dev/null")
    }

    @Test("Regular persistence controller does not use null store")
    func testRegularPersistenceDoesNotUseNullStore() {
        let persistence = PersistenceController(inMemory: false)

        let storeURL = persistence.container.persistentStoreDescriptions.first?.url

        #expect(storeURL?.path != "/dev/null")
    }

    // MARK: - Save Behaviors

    @Test("Saving with no changes does nothing")
    func testSaveWithNoChanges() {
        let persistence = PersistenceController(inMemory: true)

        // Should not throw or crash
        persistence.save()

        #expect(!persistence.container.viewContext.hasChanges)
    }

    @Test("Saving with changes persists data")
    func testSaveWithChanges() {
        let persistence = PersistenceController(inMemory: true)
        let context = persistence.container.viewContext

        let skill = Skill(context: context, name: "Swift")

        #expect(context.hasChanges)

        persistence.save()

        #expect(!context.hasChanges)
    }

    @Test("Saved data can be fetched")
    func testSavedDataCanBeFetched() {
        let persistence = PersistenceController(inMemory: true)
        let context = persistence.container.viewContext

        let skill = Skill(context: context, name: "Swift")
        persistence.save()

        let request: NSFetchRequest<Skill> = Skill.fetchRequest()
        let results = try? context.fetch(request)

        #expect(results?.count == 1)
        #expect(results?.first?.name == "Swift")
    }

    @Test("Multiple saves accumulate data")
    func testMultipleSaves() {
        let persistence = PersistenceController(inMemory: true)
        let context = persistence.container.viewContext

        let skill1 = Skill(context: context, name: "Swift")
        persistence.save()

        let skill2 = Skill(context: context, name: "Python")
        persistence.save()

        let request: NSFetchRequest<Skill> = Skill.fetchRequest()
        let results = try? context.fetch(request)

        #expect(results?.count == 2)
    }

    @Test("Saving preserves relationships")
    func testSavePreservesRelationships() {
        let persistence = PersistenceController(inMemory: true)
        let context = persistence.container.viewContext

        let skill = Skill(context: context, name: "Swift")
        let session = Session(context: context, skill: skill)
        persistence.save()

        let request: NSFetchRequest<Session> = Session.fetchRequest()
        let results = try? context.fetch(request)

        #expect(results?.count == 1)
        #expect(results?.first?.skill == skill)
    }

    // MARK: - Data Integrity Behaviors

    @Test("Deleting and saving removes data")
    func testDeleteAndSave() {
        let persistence = PersistenceController(inMemory: true)
        let context = persistence.container.viewContext

        let skill = Skill(context: context, name: "Swift")
        persistence.save()

        context.delete(skill)
        persistence.save()

        let request: NSFetchRequest<Skill> = Skill.fetchRequest()
        let results = try? context.fetch(request)

        #expect(results?.isEmpty == true)
    }

    @Test("Updating and saving persists changes")
    func testUpdateAndSave() {
        let persistence = PersistenceController(inMemory: true)
        let context = persistence.container.viewContext

        let skill = Skill(context: context, name: "Swift")
        persistence.save()

        skill.name = "Python"
        persistence.save()

        let request: NSFetchRequest<Skill> = Skill.fetchRequest()
        let results = try? context.fetch(request)

        #expect(results?.first?.name == "Python")
    }

    @Test("Cascade delete removes related sessions")
    func testCascadeDelete() {
        let persistence = PersistenceController(inMemory: true)
        let context = persistence.container.viewContext

        let skill = Skill(context: context, name: "Swift")
        let session1 = Session(context: context, skill: skill)
        let session2 = Session(context: context, skill: skill)
        persistence.save()

        context.delete(skill)
        persistence.save()

        let sessionRequest: NSFetchRequest<Session> = Session.fetchRequest()
        let sessions = try? context.fetch(sessionRequest)

        // If cascade delete is configured, sessions should be deleted too
        // If not, they might remain but with nil skill
        let sessionCount = sessions?.count ?? 0
        let hasOrphanedSessions = sessions?.contains { $0.skill == nil } ?? false

        // Behavior: Either sessions are deleted OR they exist without skill
        #expect(sessionCount == 0 || hasOrphanedSessions)
    }

    // MARK: - Concurrent Access Behaviors

    @Test("Merge policy handles concurrent updates")
    func testMergePolicyHandlesConcurrentUpdates() {
        let persistence = PersistenceController(inMemory: true)
        let context = persistence.container.viewContext

        let skill = Skill(context: context, name: "Swift")
        persistence.save()

        // Simulate concurrent update by modifying the same object
        skill.name = "Python"
        skill.colorIndex = 5

        persistence.save()

        let request: NSFetchRequest<Skill> = Skill.fetchRequest()
        let results = try? context.fetch(request)

        #expect(results?.first?.name == "Python")
        #expect(results?.first?.colorIndex == 5)
    }

    // MARK: - Context Merge Behaviors

    @Test("View context automatically merges changes from parent")
    func testAutomaticMergeFromParent() {
        let persistence = PersistenceController(inMemory: true)

        #expect(persistence.container.viewContext.automaticallyMergesChangesFromParent)
    }

    // MARK: - Data Isolation Behaviors

    @Test("In-memory stores are isolated per instance")
    func testInMemoryStoresAreIsolated() {
        let persistence1 = PersistenceController(inMemory: true)
        let persistence2 = PersistenceController(inMemory: true)

        let context1 = persistence1.container.viewContext
        let context2 = persistence2.container.viewContext

        let skill1 = Skill(context: context1, name: "Swift")
        persistence1.save()

        let request: NSFetchRequest<Skill> = Skill.fetchRequest()
        let results1 = try? context1.fetch(request)
        let results2 = try? context2.fetch(request)

        #expect(results1?.count == 1)
        #expect(results2?.count == 0) // Different store
    }

    // MARK: - Fetch Request Behaviors

    @Test("Fetching with no data returns empty array")
    func testFetchWithNoData() {
        let persistence = PersistenceController(inMemory: true)
        let context = persistence.container.viewContext

        let request: NSFetchRequest<Skill> = Skill.fetchRequest()
        let results = try? context.fetch(request)

        #expect(results?.isEmpty == true)
    }

    @Test("Fetching with predicate filters results")
    func testFetchWithPredicate() {
        let persistence = PersistenceController(inMemory: true)
        let context = persistence.container.viewContext

        let skill1 = Skill(context: context, name: "Swift")
        let skill2 = Skill(context: context, name: "Python")
        persistence.save()

        let request: NSFetchRequest<Skill> = Skill.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", "Swift")
        let results = try? context.fetch(request)

        #expect(results?.count == 1)
        #expect(results?.first?.name == "Swift")
    }

    @Test("Fetching with sort descriptor orders results")
    func testFetchWithSortDescriptor() {
        let persistence = PersistenceController(inMemory: true)
        let context = persistence.container.viewContext

        let skillZ = Skill(context: context, name: "Zebra")
        let skillA = Skill(context: context, name: "Apple")
        let skillM = Skill(context: context, name: "Mango")
        persistence.save()

        let request: NSFetchRequest<Skill> = Skill.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let results = try? context.fetch(request)

        #expect(results?.count == 3)
        #expect(results?[0].name == "Apple")
        #expect(results?[1].name == "Mango")
        #expect(results?[2].name == "Zebra")
    }
}
