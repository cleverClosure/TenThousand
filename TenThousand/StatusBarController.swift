//
//  StatusBarController.swift
//  TenThousand
//
//  Manages the menubar status item with fixed width to prevent jitter
//

import AppKit
import Combine
import SwiftUI

class StatusBarController: ObservableObject {
    // MARK: - Properties

    private var statusItem: NSStatusItem?
    private let viewModel: AppViewModel
    private var popover: NSPopover
    private var hostingView: NSHostingView<MenuBarIconView>?
    private var cancellables = Set<AnyCancellable>()
    private var eventMonitor: Any?

    // MARK: - Constants

    /// Fixed width for icon only (when timer is hidden or not running)
    private let iconOnlyWidth: CGFloat = 28

    /// Fixed width for icon + timer
    private let iconWithTimerWidth: CGFloat = 80

    // MARK: - Initialization

    init(viewModel: AppViewModel) {
        self.viewModel = viewModel
        self.popover = NSPopover()
        setupPopover()
        setupStatusItem()
        observeTimerState()
    }

    // MARK: - Setup

    private func setupPopover() {
        popover.contentViewController = NSHostingController(
            rootView: DropdownPanelView(viewModel: viewModel)
        )
        popover.behavior = .transient
        popover.animates = true
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let statusItem = statusItem,
              let button = statusItem.button else { return }

        let menuBarView = MenuBarIconView(viewModel: viewModel)
        hostingView = NSHostingView(rootView: menuBarView)

        guard let hostingView = hostingView else { return }

        hostingView.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(hostingView)

        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: button.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: button.bottomAnchor)
        ])

        button.action = #selector(togglePopover)
        button.target = self

        updateStatusItemWidth(
            isRunning: viewModel.isTimerRunning,
            showTimer: UserDefaults.standard.bool(forKey: "showMenuBarTimer")
        )
    }

    private func observeTimerState() {
        // Combine timer state and user defaults into single reactive stream
        viewModel.$isTimerRunning
            .combineLatest(
                NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
                    .map { _ in UserDefaults.standard.bool(forKey: "showMenuBarTimer") }
                    .prepend(UserDefaults.standard.bool(forKey: "showMenuBarTimer"))
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isRunning, showTimer in
                self?.updateStatusItemWidth(isRunning: isRunning, showTimer: showTimer)
            }
            .store(in: &cancellables)
    }

    private func updateStatusItemWidth(isRunning: Bool, showTimer: Bool) {
        let width = (showTimer && isRunning) ? iconWithTimerWidth : iconOnlyWidth
        statusItem?.length = width
    }

    // MARK: - Actions

    @objc private func togglePopover() {
        guard let button = statusItem?.button else { return }

        if popover.isShown {
            closePopover()
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            setupEventMonitor()
        }
    }

    private func closePopover() {
        popover.performClose(nil)
        removeEventMonitor()
    }

    private func setupEventMonitor() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { [weak self] _ in
            if self?.popover.isShown == true {
                self?.closePopover()
            }
        }
    }

    private func removeEventMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    deinit {
        removeEventMonitor()
        if let statusItem = statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
        }
    }
}
