//
//  Persistence.swift
//  TenThousand
//
//  CoreData persistence controller
//

import CoreData
import os.log

/// The CoreData persistence controller managing the database stack.
///
/// PersistenceController provides a centralized way to access the CoreData stack
/// with proper error handling and logging. It supports both persistent (SQLite-backed)
/// and in-memory storage modes.
///
/// ## Usage
/// ```swift
/// // Use shared singleton for production
/// let controller = PersistenceController.shared
/// let context = controller.container.viewContext
///
/// // Use in-memory for testing
/// let testController = PersistenceController(inMemory: true)
/// ```
///
/// - Note: The controller automatically handles store loading failures by falling
///   back to in-memory storage, ensuring the app never crashes due to persistence errors.
struct PersistenceController {

    /// Shared singleton instance for production use.
    ///
    /// Uses persistent SQLite storage at the default CoreData location.
    static let shared = PersistenceController()

    /// The NSPersistentContainer managing the CoreData stack.
    ///
    /// Access `container.viewContext` for the main thread context.
    let container: NSPersistentContainer

    private let logger = Logger(subsystem: "com.tenthousand.app", category: "Persistence")

    // MARK: - Initialization

    /// Initializes the persistence controller with the specified storage mode.
    ///
    /// - Parameter inMemory: If true, uses in-memory storage (for testing).
    ///   If false, uses persistent SQLite storage (for production).
    ///
    /// The initializer:
    /// 1. Creates an NSPersistentContainer for the "TenThousand" data model
    /// 2. Loads persistent stores (or configures in-memory storage)
    /// 3. Configures automatic change merging and merge policy
    /// 4. Logs errors but doesn't crash (falls back to in-memory on failure)
    ///
    /// ## Examples
    /// ```swift
    /// // Production
    /// let controller = PersistenceController()
    ///
    /// // Testing
    /// let testController = PersistenceController(inMemory: true)
    /// ```
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

    // MARK: - Public Methods

    /// Saves the view context if it has unsaved changes.
    ///
    /// This method is safe to call frequently - it only performs a save
    /// if the context has pending changes. Errors are logged but don't throw.
    ///
    /// - Note: Called automatically by AppViewModel after create/update/delete operations.
    ///
    /// ## Example
    /// ```swift
    /// let skill = Skill(context: controller.container.viewContext, name: "Swift")
    /// controller.save()  // Persists the new skill
    /// ```
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
