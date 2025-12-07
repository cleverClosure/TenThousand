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

    // MARK: - Timer State (bound from TimerManager)

    @Published private(set) var elapsedSeconds: Int64 = 0
    @Published private(set) var isTimerRunning = false
    @Published private(set) var isTimerPaused = false

    // MARK: - Navigation State

    @Published var panelRoute: PanelRoute = .skillList

    // MARK: - Dependencies

    private let timerManager = TimerManager()
    let dataStore: DataStore
    let colorPaletteManager: ColorPaletteManager

    private let logger = Logger(subsystem: "com.tenthousand.app", category: "AppViewModel")
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(dataStore: DataStore = SwiftDataStore.shared, colorPaletteManager: ColorPaletteManager = .shared) {
        self.dataStore = dataStore
        self.colorPaletteManager = colorPaletteManager
        bindTimerState()
        fetchSkills()
        recalculatePaletteState()
    }

    // MARK: - Timer State Binding

    private func bindTimerState() {
        timerManager.$elapsedSeconds
            .assign(to: &$elapsedSeconds)
        timerManager.$isRunning
            .assign(to: &$isTimerRunning)
        timerManager.$isPaused
            .assign(to: &$isTimerPaused)
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
        guard !trimmedName.isEmpty, trimmedName.count <= Limits.maxSkillNameLength else { return }

        if skills.contains(where: { $0.name == trimmedName }) {
            return
        }

        // Check skill limit
        guard skills.count < Limits.maxSkillCount else { return }

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
        // Navigate away if viewing the deleted skill
        if case .skillDetail(let detailSkill) = panelRoute, detailSkill.id == skill.id {
            panelRoute = .skillList
        }
        dataStore.deleteSkill(skill)
        dataStore.save()
        fetchSkills()
        recalculatePaletteState()
    }

    func updateSkill(_ skill: Skill, name: String, paletteId: String, colorIndex: Int16) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, trimmedName.count <= Limits.maxSkillNameLength else { return }

        // Check for duplicate name (excluding current skill)
        if skills.contains(where: { $0.id != skill.id && $0.name.lowercased() == trimmedName.lowercased() }) {
            return
        }

        skill.name = trimmedName
        skill.paletteId = paletteId
        skill.colorIndex = colorIndex

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
        panelRoute = .activeTracking
    }

    func pauseTracking() {
        timerManager.pause()
    }

    func resumeTracking() {
        timerManager.resume()
    }

    func stopTracking() {
        guard let session = currentSession, let skill = session.skill else { return }

        let pausedDuration = timerManager.getPausedDuration()
        _ = timerManager.stop()

        dataStore.completeSession(session, endTime: Date(), pausedDuration: pausedDuration)
        dataStore.save()

        justUpdatedSkillId = skill.id

        currentSession = nil
        activeSkill = nil
        panelRoute = .skillList

        fetchSkills()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
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

    // MARK: - Navigation

    func showSkillList() {
        panelRoute = .skillList
    }

    func showSkillDetail(_ skill: Skill) {
        panelRoute = .skillDetail(skill)
    }

    func showActiveTracking() {
        guard activeSkill != nil else { return }
        panelRoute = .activeTracking
    }

    func showSkillEdit(_ skill: Skill) {
        panelRoute = .skillEdit(skill)
    }
}
