//
//  AppViewModel.swift
//  TenThousand
//
//  Main view model coordinating app state
//

import Foundation
import SwiftUI
import Combine
import os.log

class AppViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var skills: [Skill] = []
    @Published var activeSkill: Skill?
    @Published var currentSession: Session?
    @Published var justUpdatedSkillId: UUID? = nil
    @Published var selectedSkillForDetail: Skill? = nil

    // MARK: - Dependencies

    let timerManager = TimerManager()
    let dataStore: DataStore

    private let logger = Logger(subsystem: "com.tenthousand.app", category: "AppViewModel")

    // MARK: - Initialization

    init(dataStore: DataStore = SwiftDataStore.shared) {
        self.dataStore = dataStore
        fetchSkills()
    }

    // MARK: - Skill Management

    func fetchSkills() {
        skills = dataStore.fetchAllSkills()
    }

    func createSkill(name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, trimmedName.count <= ValidationLimits.maxSkillNameLength else { return }

        if skills.contains(where: { $0.name == trimmedName }) {
            return
        }

        let colorIndex = Int16(skills.count % ValidationLimits.colorPaletteSize)
        dataStore.createSkill(name: trimmedName, colorIndex: colorIndex)
        dataStore.save()
        fetchSkills()
    }

    func deleteSkill(_ skill: Skill) {
        dataStore.deleteSkill(skill)
        dataStore.save()
        fetchSkills()
    }

    // MARK: - Session Management

    func startTracking(skill: Skill) {
        if timerManager.isRunning {
            stopTracking()
        }

        activeSkill = skill
        currentSession = dataStore.createSession(for: skill)
        timerManager.start()
    }

    func pauseTracking() {
        timerManager.pause()
    }

    func resumeTracking() {
        timerManager.resume()
    }

    func stopTracking() {
        guard let session = currentSession, let skill = session.skill else { return }

        _ = timerManager.stop()
        let pausedDuration = timerManager.getPausedDuration()

        dataStore.completeSession(session, endTime: Date(), pausedDuration: pausedDuration)
        dataStore.save()

        justUpdatedSkillId = skill.id

        currentSession = nil
        activeSkill = nil

        fetchSkills()

        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationDurations.updateHighlight) { [weak self] in
            self?.justUpdatedSkillId = nil
        }
    }

    // MARK: - Statistics

    func todaysTotalSeconds() -> Int64 {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())

        let sessions = dataStore.fetchSessions(from: startOfDay)
        return sessions.reduce(0) { total, session in
            total + session.durationSeconds
        }
    }

    func todaysSkillCount() -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())

        let sessions = dataStore.fetchSessions(from: startOfDay)
        let uniqueSkills = Set(sessions.compactMap { $0.skill })
        return uniqueSkills.count
    }
}
