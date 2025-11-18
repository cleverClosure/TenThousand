//
//  SkillTrackerData.swift
//  TenThousand
//
//  Created by Tim Isaev on 18.11.2025.
//

import Foundation
import SwiftUI
import Combine

class SkillTrackerData: ObservableObject {
    @Published var skills: [Skill] = []

    private let skillColors = [
        "#FF6B6B", // Red
        "#4ECDC4", // Teal
        "#45B7D1", // Blue
        "#FFA07A", // Orange
        "#98D8C8", // Mint
        "#F7DC6F", // Yellow
        "#BB8FCE", // Purple
        "#85C1E2"  // Light Blue
    ]

    private var timer: Timer?
    private let autosaveInterval: TimeInterval = 60.0 // Auto-save every 60 seconds

    // UserDefaults keys
    private let skillsKey = "savedSkills"

    init() {
        loadSkills()
        startAutosaveTimer()
    }

    deinit {
        timer?.invalidate()
    }

    // MARK: - Skill Management

    func addSkill(name: String, goalHours: Double = 10000) {
        let colorHex = skillColors[skills.count % skillColors.count]
        let newSkill = Skill(name: name, goalHours: goalHours, colorHex: colorHex)
        skills.append(newSkill)
        saveSkills()
    }

    func deleteSkill(_ skill: Skill) {
        skills.removeAll { $0.id == skill.id }
        saveSkills()
    }

    // MARK: - Time Tracking

    func startTracking(skill: Skill) {
        // Stop any currently tracking skill
        stopAllTracking()

        // Start tracking the selected skill
        if let index = skills.firstIndex(where: { $0.id == skill.id }) {
            skills[index].startTracking()
            saveSkills()
        }
    }

    func pauseTracking(skill: Skill) {
        if let index = skills.firstIndex(where: { $0.id == skill.id }) {
            skills[index].pauseTracking()
            saveSkills()
        }
    }

    private func stopAllTracking() {
        for index in skills.indices {
            if skills[index].isTracking {
                skills[index].pauseTracking()
            }
        }
    }

    func updateTrackingTime() {
        // Update current session time for display
        for index in skills.indices {
            if let session = skills[index].currentSession {
                let currentDuration = session.duration
                // This will trigger UI updates
                objectWillChange.send()
            }
        }
    }

    var currentlyTrackingSkill: Skill? {
        skills.first { $0.isTracking }
    }

    // MARK: - Persistence

    private func saveSkills() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(skills)
            UserDefaults.standard.set(data, forKey: skillsKey)
        } catch {
            print("Error saving skills: \(error)")
        }
    }

    private func loadSkills() {
        guard let data = UserDefaults.standard.data(forKey: skillsKey) else {
            return
        }

        do {
            let decoder = JSONDecoder()
            skills = try decoder.decode([Skill].self, from: data)
        } catch {
            print("Error loading skills: \(error)")
        }
    }

    // MARK: - Auto-save Timer

    private func startAutosaveTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: autosaveInterval, repeats: true) { [weak self] _ in
            self?.saveSkills()
            self?.updateTrackingTime()
        }
    }
}
