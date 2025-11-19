//
//  GoalSettings+CoreDataProperties.swift
//  TenThousand
//

import Foundation
import CoreData

extension GoalSettings {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<GoalSettings> {
        return NSFetchRequest<GoalSettings>(entityName: "GoalSettings")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var goalType: String? // "daily" or "weekly"
    @NSManaged public var targetMinutes: Int64
    @NSManaged public var isEnabled: Bool

    // Computed property for target in seconds
    var targetSeconds: Int64 {
        return targetMinutes * 60
    }

    // Computed properties for displaying target time
    var targetHours: Int {
        return Int(targetMinutes / 60)
    }

    var targetRemainingMinutes: Int {
        return Int(targetMinutes % 60)
    }

    // Check if goal type is daily
    var isDaily: Bool {
        return goalType == "daily"
    }

    // Check if goal type is weekly
    var isWeekly: Bool {
        return goalType == "weekly"
    }

    // Convenience initializer
    convenience init(context: NSManagedObjectContext, goalType: String = "daily", targetMinutes: Int64 = 60) {
        self.init(context: context)
        self.id = UUID()
        self.goalType = goalType
        self.targetMinutes = targetMinutes
        self.isEnabled = false
    }
}

extension GoalSettings : Identifiable {

}
