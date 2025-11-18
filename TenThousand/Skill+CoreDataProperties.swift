//
//  Skill+CoreDataProperties.swift
//  TenThousand
//

import Foundation
import CoreData

extension Skill {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Skill> {
        return NSFetchRequest<Skill>(entityName: "Skill")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var colorIndex: Int16
    @NSManaged public var createdAt: Date?
    @NSManaged public var sessions: NSSet?

    // Computed property for total seconds
    var totalSeconds: Int64 {
        guard let sessions = sessions as? Set<Session> else { return 0 }
        return sessions.reduce(0) { total, session in
            guard let endTime = session.endTime else { return total }
            let duration = Int64(endTime.timeIntervalSince(session.startTime ?? Date()))
            return total + duration - session.pausedDuration
        }
    }

    // Convenience initializer
    convenience init(context: NSManagedObjectContext, name: String, colorIndex: Int16 = 0) {
        self.init(context: context)
        self.id = UUID()
        self.name = name
        self.colorIndex = colorIndex
        self.createdAt = Date()
    }
}

// MARK: Generated accessors for sessions
extension Skill {
    @objc(addSessionsObject:)
    @NSManaged public func addToSessions(_ value: Session)

    @objc(removeSessionsObject:)
    @NSManaged public func removeFromSessions(_ value: Session)

    @objc(addSessions:)
    @NSManaged public func addToSessions(_ values: NSSet)

    @objc(removeSessions:)
    @NSManaged public func removeFromSessions(_ values: NSSet)
}

extension Skill : Identifiable {

}
