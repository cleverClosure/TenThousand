//
//  Session+CoreDataProperties.swift
//  TenThousand
//

import Foundation
import CoreData

extension Session {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Session> {
        return NSFetchRequest<Session>(entityName: "Session")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var startTime: Date?
    @NSManaged public var endTime: Date?
    @NSManaged public var pausedDuration: Int64
    @NSManaged public var skill: Skill?

    // Computed property for duration in seconds
    var durationSeconds: Int64 {
        guard let start = startTime else { return 0 }
        let end = endTime ?? Date()
        return Int64(end.timeIntervalSince(start)) - pausedDuration
    }

    // Convenience initializer
    convenience init(context: NSManagedObjectContext, skill: Skill) {
        self.init(context: context)
        self.id = UUID()
        self.startTime = Date()
        self.pausedDuration = 0
        self.skill = skill
    }
}

extension Session : Identifiable {

}
