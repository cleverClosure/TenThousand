//
//  AppViewModel.swift
//  TenThousand
//
//  Main view model coordinating app state
//

import Combine
import Foundation
import os.log
import SwiftUI

class AppViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var skills: [Skill] = []
    @Published var activeSkill: Skill?
    @Published var currentSession: Session?
    @Published var justUpdatedSkillId: UUID?
    @Published var selectedSkillForDetail: Skill?

    // MARK: - Dependencies

    let timerManager = TimerManager()
    let dataStore: DataStore
    let colorPaletteManager: ColorPaletteManager

    private let logger = Logger(subsystem: "com.tenthousand.app", category: "AppViewModel")

    // MARK: - Initialization

    init(dataStore: DataStore = SwiftDataStore.shared, colorPaletteManager: ColorPaletteManager = .shared) {
        self.dataStore = dataStore
        self.colorPaletteManager = colorPaletteManager
        fetchSkills()
        recalculatePaletteState()
    }

    // MARK: - Palette State

    private func recalculatePaletteState() {
        let usedColors = skills.map { $0.colorAssignment }
        colorPaletteManager.recalculateState(usedColors: usedColors)
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

        // Check skill limit
        guard skills.count < ValidationLimits.maxSkillCount else { return }

        // Get next available color from palette manager
        let usedColors = skills.map { $0.colorAssignment }
        guard let colorAssignment = colorPaletteManager.nextColor(usedColors: usedColors) else {
            return
        }

        dataStore.createSkill(name: trimmedName, paletteId: colorAssignment.paletteId, colorIndex: Int16(colorAssignment.colorIndex))
        dataStore.save()
        fetchSkills()
    }

    func deleteSkill(_ skill: Skill) {
        // Clear selection before triggering view updates to avoid
        // SwiftUI rendering with a reference to the deleted object
        if selectedSkillForDetail?.id == skill.id {
            selectedSkillForDetail = nil
        }
        dataStore.deleteSkill(skill)
        dataStore.save()
        fetchSkills()
        recalculatePaletteState()
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
