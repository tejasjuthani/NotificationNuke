import Cocoa
import SwiftUI
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var notificationManager = NotificationManager.shared
    private var mainWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        requestNotificationPermissions()
        startMonitoringNotifications()
        openMainWindow()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            openMainWindow()
        }
        return true
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if statusItem.button != nil {
            updateMenuBarIcon()
        }

        let menu = NSMenu()

        let notificationCountItem = NSMenuItem(title: "Notifications: \(notificationManager.notificationCount)", action: nil, keyEquivalent: "")
        notificationCountItem.isEnabled = false
        notificationCountItem.tag = 100
        menu.addItem(notificationCountItem)

        menu.addItem(NSMenuItem.separator())

        let clearAllItem = NSMenuItem(title: "Clear All Notifications", action: #selector(clearAllNotifications), keyEquivalent: "")
        clearAllItem.target = self
        menu.addItem(clearAllItem)

        menu.addItem(NSMenuItem.separator())

        let preferencesItem = NSMenuItem(title: "Preferences...", action: #selector(openPreferences), keyEquivalent: ",")
        preferencesItem.target = self
        menu.addItem(preferencesItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit NotificationNuke", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu

        notificationManager.onCountChanged = { [weak self] count in
            DispatchQueue.main.async {
                self?.updateMenuBarIcon()
                self?.updateNotificationCountInMenu(count: count)
            }
        }
    }

    private func updateMenuBarIcon() {
        guard let button = statusItem.button else { return }

        let count = notificationManager.notificationCount
        let image = NSImage(systemSymbolName: "bell.fill", accessibilityDescription: "Notifications")
        image?.isTemplate = true

        button.image = image
        button.imagePosition = .imageLeading

        if count > 0 {
            button.title = " \(count)"
        } else {
            button.title = ""
        }
    }

    private func updateNotificationCountInMenu(count: Int) {
        guard let menu = statusItem.menu else { return }

        if let countItem = menu.item(withTag: 100) {
            countItem.title = "Notifications: \(count)"
        }
    }

    @objc private func clearAllNotifications() {
        notificationManager.clearAllNotifications()

        if let button = statusItem.button {
            let originalTitle = button.title
            button.title = " Cleared!"

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                button.title = originalTitle
            }
        }
    }

    @objc private func openPreferences() {
        openMainWindow()
    }

    private func openMainWindow() {
        if mainWindow == nil {
            let mainView = MainWindowView().environmentObject(NotificationManager.shared)
            let hostingController = NSHostingController(rootView: mainView)

            let window = NSWindow(contentViewController: hostingController)
            window.title = "NotificationNuke"
            window.styleMask = [.titled, .closable, .miniaturizable]
            window.setContentSize(NSSize(width: 500, height: 400))
            window.center()
            window.isReleasedWhenClosed = false

            mainWindow = window
        }

        mainWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification permissions: \(error)")
            }
        }
    }

    private func startMonitoringNotifications() {
        notificationManager.startMonitoring()
    }
}

