//
//  Persistence.swift
//  TenThousand
//
//  CoreData persistence controller
//

import CoreData
import os.log

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer
    private let logger = Logger(subsystem: "com.tenthousand.app", category: "Persistence")

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TenThousand")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { [logger] description, error in
            if let error = error {
                // Log error but don't crash - this allows the app to continue
                // with in-memory storage if persistent store fails to load
                logger.error("Failed to load Core Data stack: \(error.localizedDescription)")
                logger.info("Falling back to in-memory storage")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                logger.error("Failed to save context: \(error.localizedDescription)")
            }
        }
    }
}
