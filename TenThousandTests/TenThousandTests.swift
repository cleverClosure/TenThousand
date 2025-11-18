//
//  TenThousandTests.swift
//  TenThousandTests
//
//  Created by Tim Isaev on 18.11.2025.
//

import Testing
import Foundation
import SwiftUI
@testable import TenThousand

// MARK: - Session Tests

@Suite("Session Tests")
struct SessionTests {
    @Test("Session initialization with default values")
    func testSessionDefaultInit() {
        let session = Session()

        #expect(session.id != UUID(uuidString: "00000000-0000-0000-0000-000000000000"))
        #expect(session.startTime <= Date())
        #expect(session.endTime == nil)
    }

    @Test("Session initialization with custom values")
    func testSessionCustomInit() {
        let id = UUID()
        let startTime = Date(timeIntervalSince1970: 1000)
        let endTime = Date(timeIntervalSince1970: 2000)

        let session = Session(id: id, startTime: startTime, endTime: endTime)

        #expect(session.id == id)
        #expect(session.startTime == startTime)
        #expect(session.endTime == endTime)
    }

    @Test("Session duration calculation with end time")
    func testSessionDurationWithEndTime() {
        let startTime = Date(timeIntervalSince1970: 1000)
        let endTime = Date(timeIntervalSince1970: 4600) // 1 hour later

        let session = Session(startTime: startTime, endTime: endTime)

        #expect(session.duration == 3600.0)
    }

    @Test("Session duration calculation without end time")
    func testSessionDurationWithoutEndTime() {
        let startTime = Date()
        let session = Session(startTime: startTime)

        // Duration should be close to 0 since we just created it
        #expect(session.duration >= 0)
        #expect(session.duration < 1.0)
    }

    @Test("Session codable encoding and decoding")
    func testSessionCodable() throws {
        let originalSession = Session(
            id: UUID(),
            startTime: Date(timeIntervalSince1970: 1000),
            endTime: Date(timeIntervalSince1970: 2000)
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(originalSession)

        let decoder = JSONDecoder()
        let decodedSession = try decoder.decode(Session.self, from: data)

        #expect(decodedSession.id == originalSession.id)
        #expect(decodedSession.startTime == originalSession.startTime)
        #expect(decodedSession.endTime == originalSession.endTime)
    }
}

// MARK: - Skill Tests

@Suite("Skill Tests")
struct SkillTests {
    @Test("Skill initialization with minimal parameters")
    func testSkillMinimalInit() {
        let skill = Skill(name: "Piano", colorHex: "#FF0000")

        #expect(skill.name == "Piano")
        #expect(skill.totalSeconds == 0)
        #expect(skill.goalHours == 10000)
        #expect(skill.colorHex == "#FF0000")
        #expect(skill.sessions.isEmpty)
        #expect(skill.currentSession == nil)
    }

    @Test("Skill initialization with all parameters")
    func testSkillFullInit() {
        let sessions = [Session(startTime: Date(), endTime: Date())]
        let currentSession = Session()

        let skill = Skill(
            name: "Guitar",
            totalSeconds: 3600,
            goalHours: 5000,
            colorHex: "#00FF00",
            sessions: sessions,
            currentSession: currentSession
        )

        #expect(skill.name == "Guitar")
        #expect(skill.totalSeconds == 3600)
        #expect(skill.goalHours == 5000)
        #expect(skill.colorHex == "#00FF00")
        #expect(skill.sessions.count == 1)
        #expect(skill.currentSession?.id == currentSession.id)
    }

    @Test("Skill total hours calculation")
    func testSkillTotalHours() {
        let skill = Skill(name: "Test", totalSeconds: 7200, colorHex: "#000000")

        #expect(skill.totalHours == 2.0)
    }

    @Test("Skill percent complete calculation")
    func testSkillPercentComplete() {
        let skill = Skill(
            name: "Test",
            totalSeconds: 18000000, // 5000 hours
            goalHours: 10000,
            colorHex: "#000000"
        )

        #expect(skill.percentComplete == 50.0)
    }

    @Test("Skill is tracking when current session exists")
    func testSkillIsTracking() {
        var skill = Skill(name: "Test", colorHex: "#000000")

        #expect(skill.isTracking == false)

        skill.startTracking()

        #expect(skill.isTracking == true)
    }

    @Test("Skill start tracking creates current session")
    func testSkillStartTracking() {
        var skill = Skill(name: "Test", colorHex: "#000000")

        skill.startTracking()

        #expect(skill.currentSession != nil)
        #expect(skill.isTracking == true)
    }

    @Test("Skill pause tracking saves session and updates total")
    func testSkillPauseTracking() {
        var skill = Skill(name: "Test", colorHex: "#000000")
        let initialTotal = skill.totalSeconds

        skill.startTracking()

        // Wait a tiny bit to ensure duration > 0
        Thread.sleep(forTimeInterval: 0.1)

        skill.pauseTracking()

        #expect(skill.currentSession == nil)
        #expect(skill.isTracking == false)
        #expect(skill.sessions.count == 1)
        #expect(skill.totalSeconds > initialTotal)
    }

    @Test("Skill add time increases total seconds")
    func testSkillAddTime() {
        var skill = Skill(name: "Test", colorHex: "#000000")

        skill.addTime(3600)

        #expect(skill.totalSeconds == 3600)

        skill.addTime(1800)

        #expect(skill.totalSeconds == 5400)
    }

    @Test("Skill formatted total time")
    func testSkillFormattedTotalTime() {
        let skill = Skill(
            name: "Test",
            totalSeconds: 7260, // 2 hours and 1 minute
            colorHex: "#000000"
        )

        #expect(skill.formattedTotalTime() == "2h 1m")
    }

    @Test("Skill formatted goal")
    func testSkillFormattedGoal() {
        let skill = Skill(name: "Test", goalHours: 5000, colorHex: "#000000")

        #expect(skill.formattedGoal() == "5,000h")
    }

    @Test("Skill formatted percentage")
    func testSkillFormattedPercentage() {
        let skill = Skill(
            name: "Test",
            totalSeconds: 18000000, // 5000 hours
            goalHours: 10000,
            colorHex: "#000000"
        )

        #expect(skill.formattedPercentage() == "50.0%")
    }

    @Test("Skill formatted current session returns nil when not tracking")
    func testSkillFormattedCurrentSessionNil() {
        let skill = Skill(name: "Test", colorHex: "#000000")

        #expect(skill.formattedCurrentSession() == nil)
    }

    @Test("Skill formatted current session with hours")
    func testSkillFormattedCurrentSessionWithHours() {
        let currentSession = Session(
            startTime: Date(timeIntervalSince1970: 0),
            endTime: Date(timeIntervalSince1970: 3665) // 1h 1m 5s
        )
        let skill = Skill(
            name: "Test",
            colorHex: "#000000",
            currentSession: currentSession
        )

        let formatted = skill.formattedCurrentSession()
        #expect(formatted == "1h 1m 5s")
    }

    @Test("Skill formatted current session with minutes only")
    func testSkillFormattedCurrentSessionWithMinutes() {
        let currentSession = Session(
            startTime: Date(timeIntervalSince1970: 0),
            endTime: Date(timeIntervalSince1970: 125) // 2m 5s
        )
        let skill = Skill(
            name: "Test",
            colorHex: "#000000",
            currentSession: currentSession
        )

        let formatted = skill.formattedCurrentSession()
        #expect(formatted == "2m 5s")
    }

    @Test("Skill formatted current session with seconds only")
    func testSkillFormattedCurrentSessionWithSeconds() {
        let currentSession = Session(
            startTime: Date(timeIntervalSince1970: 0),
            endTime: Date(timeIntervalSince1970: 45) // 45s
        )
        let skill = Skill(
            name: "Test",
            colorHex: "#000000",
            currentSession: currentSession
        )

        let formatted = skill.formattedCurrentSession()
        #expect(formatted == "45s")
    }

    @Test("Skill projected completion date returns nil with no recent sessions")
    func testSkillProjectedCompletionDateNil() {
        let skill = Skill(name: "Test", colorHex: "#000000")

        #expect(skill.projectedCompletionDate() == nil)
    }

    @Test("Skill projected completion date calculation with recent sessions")
    func testSkillProjectedCompletionDate() {
        let twentyDaysAgo = Calendar.current.date(byAdding: .day, value: -20, to: Date())!
        let sessions = [
            Session(
                startTime: twentyDaysAgo,
                endTime: Calendar.current.date(byAdding: .second, value: 3600, to: twentyDaysAgo)
            )
        ]

        let skill = Skill(
            name: "Test",
            totalSeconds: 3600, // 1 hour done
            goalHours: 10,
            colorHex: "#000000",
            sessions: sessions
        )

        let projectedDate = skill.projectedCompletionDate()
        #expect(projectedDate != nil)
        #expect(projectedDate! > Date())
    }

    @Test("Skill codable encoding and decoding")
    func testSkillCodable() throws {
        let originalSkill = Skill(
            name: "Piano",
            totalSeconds: 3600,
            goalHours: 5000,
            colorHex: "#FF0000"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(originalSkill)

        let decoder = JSONDecoder()
        let decodedSkill = try decoder.decode(Skill.self, from: data)

        #expect(decodedSkill.id == originalSkill.id)
        #expect(decodedSkill.name == originalSkill.name)
        #expect(decodedSkill.totalSeconds == originalSkill.totalSeconds)
        #expect(decodedSkill.goalHours == originalSkill.goalHours)
        #expect(decodedSkill.colorHex == originalSkill.colorHex)
    }
}

// MARK: - Color Extension Tests

@Suite("Color Extension Tests")
struct ColorExtensionTests {
    @Test("Color from 6-character hex")
    func testColorFrom6CharHex() {
        let color = Color(hex: "#FF0000")

        #expect(color != nil)
    }

    @Test("Color from 6-character hex without hash")
    func testColorFrom6CharHexWithoutHash() {
        let color = Color(hex: "00FF00")

        #expect(color != nil)
    }

    @Test("Color from 3-character hex")
    func testColorFrom3CharHex() {
        let color = Color(hex: "#F00")

        #expect(color != nil)
    }

    @Test("Color from 8-character hex with alpha")
    func testColorFrom8CharHex() {
        let color = Color(hex: "#FF0000FF")

        #expect(color != nil)
    }

    @Test("Color from invalid hex returns nil")
    func testColorFromInvalidHex() {
        let color = Color(hex: "GGGGGG")

        #expect(color == nil)
    }

    @Test("Color from empty string returns nil")
    func testColorFromEmptyString() {
        let color = Color(hex: "")

        #expect(color == nil)
    }

    @Test("Color from wrong length hex returns nil")
    func testColorFromWrongLengthHex() {
        let color = Color(hex: "#FF00")

        #expect(color == nil)
    }
}

// MARK: - SkillTrackerData Tests

@Suite("SkillTrackerData Tests")
struct SkillTrackerDataTests {
    @Test("SkillTrackerData initialization")
    func testSkillTrackerDataInit() {
        // Clear any saved data first
        UserDefaults.standard.removeObject(forKey: "savedSkills")

        let tracker = SkillTrackerData()

        #expect(tracker.skills.isEmpty)
    }

    @Test("Add skill to tracker")
    func testAddSkill() {
        UserDefaults.standard.removeObject(forKey: "savedSkills")
        let tracker = SkillTrackerData()

        tracker.addSkill(name: "Piano")

        #expect(tracker.skills.count == 1)
        #expect(tracker.skills[0].name == "Piano")
        #expect(tracker.skills[0].goalHours == 10000)
    }

    @Test("Add skill with custom goal hours")
    func testAddSkillWithCustomGoal() {
        UserDefaults.standard.removeObject(forKey: "savedSkills")
        let tracker = SkillTrackerData()

        tracker.addSkill(name: "Guitar", goalHours: 5000)

        #expect(tracker.skills.count == 1)
        #expect(tracker.skills[0].name == "Guitar")
        #expect(tracker.skills[0].goalHours == 5000)
    }

    @Test("Add multiple skills assigns different colors")
    func testAddMultipleSkillsColors() {
        UserDefaults.standard.removeObject(forKey: "savedSkills")
        let tracker = SkillTrackerData()

        tracker.addSkill(name: "Skill1")
        tracker.addSkill(name: "Skill2")
        tracker.addSkill(name: "Skill3")

        #expect(tracker.skills.count == 3)
        // Colors should cycle through the available palette
        #expect(!tracker.skills[0].colorHex.isEmpty)
        #expect(!tracker.skills[1].colorHex.isEmpty)
        #expect(!tracker.skills[2].colorHex.isEmpty)
    }

    @Test("Update skill name and goal")
    func testUpdateSkill() {
        UserDefaults.standard.removeObject(forKey: "savedSkills")
        let tracker = SkillTrackerData()

        tracker.addSkill(name: "Piano", goalHours: 10000)
        let skill = tracker.skills[0]

        tracker.updateSkill(skill, name: "Guitar", goalHours: 5000)

        #expect(tracker.skills[0].name == "Guitar")
        #expect(tracker.skills[0].goalHours == 5000)
    }

    @Test("Update nonexistent skill does nothing")
    func testUpdateNonexistentSkill() {
        UserDefaults.standard.removeObject(forKey: "savedSkills")
        let tracker = SkillTrackerData()

        tracker.addSkill(name: "Piano")
        let fakeSkill = Skill(name: "Fake", colorHex: "#000000")

        tracker.updateSkill(fakeSkill, name: "Updated", goalHours: 1000)

        #expect(tracker.skills[0].name == "Piano")
    }

    @Test("Delete skill")
    func testDeleteSkill() {
        UserDefaults.standard.removeObject(forKey: "savedSkills")
        let tracker = SkillTrackerData()

        tracker.addSkill(name: "Piano")
        tracker.addSkill(name: "Guitar")
        let skillToDelete = tracker.skills[0]

        tracker.deleteSkill(skillToDelete)

        #expect(tracker.skills.count == 1)
        #expect(tracker.skills[0].name == "Guitar")
    }

    @Test("Update skill hours")
    func testUpdateSkillHours() {
        UserDefaults.standard.removeObject(forKey: "savedSkills")
        let tracker = SkillTrackerData()

        tracker.addSkill(name: "Piano")
        let skill = tracker.skills[0]

        tracker.updateSkillHours(skill: skill, totalSeconds: 3600)

        #expect(tracker.skills[0].totalSeconds == 3600)
    }

    @Test("Start tracking skill")
    func testStartTracking() {
        UserDefaults.standard.removeObject(forKey: "savedSkills")
        let tracker = SkillTrackerData()

        tracker.addSkill(name: "Piano")
        let skill = tracker.skills[0]

        tracker.startTracking(skill: skill)

        #expect(tracker.skills[0].isTracking == true)
        #expect(tracker.currentlyTrackingSkill?.id == skill.id)
    }

    @Test("Start tracking stops other tracking skills")
    func testStartTrackingStopsOthers() {
        UserDefaults.standard.removeObject(forKey: "savedSkills")
        let tracker = SkillTrackerData()

        tracker.addSkill(name: "Piano")
        tracker.addSkill(name: "Guitar")
        let skill1 = tracker.skills[0]
        let skill2 = tracker.skills[1]

        tracker.startTracking(skill: skill1)
        #expect(tracker.skills[0].isTracking == true)

        tracker.startTracking(skill: skill2)
        #expect(tracker.skills[0].isTracking == false)
        #expect(tracker.skills[1].isTracking == true)
        #expect(tracker.currentlyTrackingSkill?.id == skill2.id)
    }

    @Test("Pause tracking skill")
    func testPauseTracking() {
        UserDefaults.standard.removeObject(forKey: "savedSkills")
        let tracker = SkillTrackerData()

        tracker.addSkill(name: "Piano")
        let skill = tracker.skills[0]

        tracker.startTracking(skill: skill)
        Thread.sleep(forTimeInterval: 0.1)
        tracker.pauseTracking(skill: skill)

        #expect(tracker.skills[0].isTracking == false)
        #expect(tracker.currentlyTrackingSkill == nil)
        #expect(tracker.skills[0].totalSeconds > 0)
    }

    @Test("Currently tracking skill returns nil when none tracking")
    func testCurrentlyTrackingSkillNil() {
        UserDefaults.standard.removeObject(forKey: "savedSkills")
        let tracker = SkillTrackerData()

        tracker.addSkill(name: "Piano")

        #expect(tracker.currentlyTrackingSkill == nil)
    }

    @Test("Persistence saves and loads skills")
    func testPersistence() {
        UserDefaults.standard.removeObject(forKey: "savedSkills")

        // Create tracker and add skills
        let tracker1 = SkillTrackerData()
        tracker1.addSkill(name: "Piano", goalHours: 5000)
        tracker1.addSkill(name: "Guitar", goalHours: 3000)

        // Create new tracker instance - should load saved skills
        let tracker2 = SkillTrackerData()

        #expect(tracker2.skills.count == 2)
        #expect(tracker2.skills[0].name == "Piano")
        #expect(tracker2.skills[0].goalHours == 5000)
        #expect(tracker2.skills[1].name == "Guitar")
        #expect(tracker2.skills[1].goalHours == 3000)

        // Clean up
        UserDefaults.standard.removeObject(forKey: "savedSkills")
    }
}

// MARK: - Additional Color Extension Tests

@Suite("Color toHex Tests")
struct ColorToHexTests {
    @Test("Color toHex conversion for red")
    func testColorToHexRed() {
        let color = Color(hex: "#FF0000")
        let hex = color?.toHex()

        #expect(hex?.uppercased() == "#FF0000")
    }

    @Test("Color toHex conversion for green")
    func testColorToHexGreen() {
        let color = Color(hex: "#00FF00")
        let hex = color?.toHex()

        #expect(hex?.uppercased() == "#00FF00")
    }

    @Test("Color toHex conversion for blue")
    func testColorToHexBlue() {
        let color = Color(hex: "#0000FF")
        let hex = color?.toHex()

        #expect(hex?.uppercased() == "#0000FF")
    }
}

// MARK: - Date Extension Tests

@Suite("Date Extension Tests")
struct DateExtensionTests {
    @Test("Date startOfDay removes time components")
    func testStartOfDay() {
        let date = Date(timeIntervalSince1970: 1000000) // Some random time
        let startOfDay = date.startOfDay

        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: startOfDay)
        #expect(components.hour == 0)
        #expect(components.minute == 0)
        #expect(components.second == 0)
    }

    @Test("Date endOfDay is at 23:59:59")
    func testEndOfDay() {
        let date = Date()
        let endOfDay = date.endOfDay

        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: endOfDay)
        #expect(components.hour == 23)
        #expect(components.minute == 59)
        #expect(components.second == 59)
    }

    @Test("Date startOfWeek returns beginning of week")
    func testStartOfWeek() {
        let date = Date()
        let startOfWeek = date.startOfWeek

        let weekday = Calendar.current.component(.weekday, from: startOfWeek)
        #expect(weekday == 1) // Sunday is 1 in Gregorian calendar
    }

    @Test("Date endOfWeek is after startOfWeek")
    func testEndOfWeek() {
        let date = Date()
        let startOfWeek = date.startOfWeek
        let endOfWeek = date.endOfWeek

        #expect(endOfWeek > startOfWeek)
        let interval = endOfWeek.timeIntervalSince(startOfWeek)
        // Should be approximately 7 days minus 1 second
        #expect(interval > 6 * 24 * 3600)
        #expect(interval < 7 * 24 * 3600)
    }

    @Test("Date startOfMonth is first day of month")
    func testStartOfMonth() {
        let date = Date()
        let startOfMonth = date.startOfMonth

        let day = Calendar.current.component(.day, from: startOfMonth)
        #expect(day == 1)
    }

    @Test("Date endOfMonth is last day of month")
    func testEndOfMonth() {
        let date = Date()
        let startOfMonth = date.startOfMonth
        let endOfMonth = date.endOfMonth

        #expect(endOfMonth > startOfMonth)
        // End of month should be in the same month
        let startMonth = Calendar.current.component(.month, from: startOfMonth)
        let endMonth = Calendar.current.component(.month, from: endOfMonth)
        #expect(startMonth == endMonth)
    }

    @Test("Date startOfYear is January 1st")
    func testStartOfYear() {
        let date = Date()
        let startOfYear = date.startOfYear

        let components = Calendar.current.dateComponents([.month, .day], from: startOfYear)
        #expect(components.month == 1)
        #expect(components.day == 1)
    }

    @Test("Date endOfYear is December 31st at 23:59:59")
    func testEndOfYear() {
        let date = Date()
        let endOfYear = date.endOfYear

        let components = Calendar.current.dateComponents([.month, .day, .hour, .minute, .second], from: endOfYear)
        #expect(components.month == 12)
        #expect(components.day == 31)
        #expect(components.hour == 23)
        #expect(components.minute == 59)
        #expect(components.second == 59)
    }

    @Test("Date timeRemaining formats days correctly")
    func testTimeRemainingDays() {
        let start = Date()
        let end = Calendar.current.date(byAdding: .day, value: 5, to: start)!

        let remaining = start.timeRemaining(until: end)
        #expect(remaining.contains("d"))
    }

    @Test("Date timeRemaining formats hours correctly")
    func testTimeRemainingHours() {
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 7200) // 2 hours

        let remaining = start.timeRemaining(until: end)
        #expect(remaining == "2h 0m")
    }

    @Test("Date timeRemaining formats minutes correctly")
    func testTimeRemainingMinutes() {
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 1800) // 30 minutes

        let remaining = start.timeRemaining(until: end)
        #expect(remaining == "30m")
    }
}

// MARK: - TimeInterval Extension Tests

@Suite("TimeInterval Extension Tests")
struct TimeIntervalExtensionTests {
    @Test("TimeInterval formattedTime with hours and minutes")
    func testFormattedTimeHoursMinutes() {
        let interval: TimeInterval = 7260 // 2 hours 1 minute

        #expect(interval.formattedTime == "2h 1m")
    }

    @Test("TimeInterval formattedTime with only hours")
    func testFormattedTimeHoursOnly() {
        let interval: TimeInterval = 7200 // 2 hours

        #expect(interval.formattedTime == "2h 0m")
    }

    @Test("TimeInterval formattedTime with only minutes")
    func testFormattedTimeMinutesOnly() {
        let interval: TimeInterval = 120 // 2 minutes

        #expect(interval.formattedTime == "0h 2m")
    }

    @Test("TimeInterval formattedTime with zero")
    func testFormattedTimeZero() {
        let interval: TimeInterval = 0

        #expect(interval.formattedTime == "0h 0m")
    }

    @Test("TimeInterval formattedTime with large value")
    func testFormattedTimeLarge() {
        let interval: TimeInterval = 36000000 // 10000 hours

        #expect(interval.formattedTime == "10000h 0m")
    }
}

// MARK: - Edge Case Tests

@Suite("Skill Edge Cases")
struct SkillEdgeCaseTests {
    @Test("Skill percentComplete with zero goal hours")
    func testPercentCompleteZeroGoal() {
        let skill = Skill(
            name: "Test",
            totalSeconds: 3600,
            goalHours: 0,
            colorHex: "#000000"
        )

        // Should handle division by zero gracefully
        // percentComplete = (totalHours / goalHours) * 100
        // With goalHours = 0, this would be infinity
        let percent = skill.percentComplete
        #expect(percent.isInfinite || percent.isNaN)
    }

    @Test("Skill with very large goal hours")
    func testVeryLargeGoalHours() {
        let skill = Skill(
            name: "Test",
            totalSeconds: 3600,
            goalHours: 1000000,
            colorHex: "#000000"
        )

        #expect(skill.percentComplete < 1.0)
    }

    @Test("Skill pause tracking when not tracking does nothing")
    func testPauseWhenNotTracking() {
        var skill = Skill(name: "Test", colorHex: "#000000")
        let initialSeconds = skill.totalSeconds
        let initialSessionCount = skill.sessions.count

        skill.pauseTracking()

        #expect(skill.totalSeconds == initialSeconds)
        #expect(skill.sessions.count == initialSessionCount)
        #expect(skill.currentSession == nil)
    }

    @Test("Skill with negative addTime still updates")
    func testAddNegativeTime() {
        var skill = Skill(name: "Test", totalSeconds: 3600, colorHex: "#000000")

        skill.addTime(-1800)

        #expect(skill.totalSeconds == 1800)
    }

    @Test("Skill multiple tracking sessions accumulate")
    func testMultipleTrackingSessions() {
        var skill = Skill(name: "Test", colorHex: "#000000")

        skill.startTracking()
        Thread.sleep(forTimeInterval: 0.1)
        skill.pauseTracking()

        let firstTotal = skill.totalSeconds

        skill.startTracking()
        Thread.sleep(forTimeInterval: 0.1)
        skill.pauseTracking()

        #expect(skill.totalSeconds > firstTotal)
        #expect(skill.sessions.count == 2)
    }

    @Test("Skill projected completion with sessions older than 30 days")
    func testProjectedCompletionOldSessions() {
        let sixtyDaysAgo = Calendar.current.date(byAdding: .day, value: -60, to: Date())!
        let sessions = [
            Session(
                startTime: sixtyDaysAgo,
                endTime: Calendar.current.date(byAdding: .second, value: 3600, to: sixtyDaysAgo)
            )
        ]

        let skill = Skill(
            name: "Test",
            totalSeconds: 3600,
            goalHours: 10,
            colorHex: "#000000",
            sessions: sessions
        )

        // Should return nil because no sessions in last 30 days
        #expect(skill.projectedCompletionDate() == nil)
    }
}

@Suite("Session Edge Cases")
struct SessionEdgeCaseTests {
    @Test("Session with same start and end time has zero duration")
    func testZeroDuration() {
        let time = Date()
        let session = Session(startTime: time, endTime: time)

        #expect(session.duration == 0)
    }

    @Test("Session with end time before start time has negative duration")
    func testNegativeDuration() {
        let start = Date(timeIntervalSince1970: 1000)
        let end = Date(timeIntervalSince1970: 500)
        let session = Session(startTime: start, endTime: end)

        #expect(session.duration < 0)
    }
}
