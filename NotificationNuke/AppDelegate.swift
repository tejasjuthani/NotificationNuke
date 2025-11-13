import Cocoa
import SwiftUI
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var statusItem: NSStatusItem!
    private var notificationManager = NotificationManager.shared
    private var mainWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("🚀 NotificationNuke launching...")

        setupMenuBar()
        requestNotificationPermissions()
        startMonitoringNotifications()

        // Initialize launch-at-login support
        LaunchAtLoginManager.shared.setEnabled(UserDefaults.standard.bool(forKey: "LaunchAtLogin"))

        openMainWindow()

        print("✅ NotificationNuke ready")
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
        // Guard against opening window if already visible
        guard mainWindow?.isVisible != true else {
            mainWindow?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        if mainWindow == nil {
            do {
                let mainView = MainWindowView().environmentObject(NotificationManager.shared)
                let hostingController = NSHostingController(rootView: mainView)

                let window = NSWindow(contentViewController: hostingController)
                window.title = "NotificationNuke"
                window.styleMask = [.titled, .closable, .miniaturizable]
                window.setContentSize(NSSize(width: 500, height: 400))
                window.center()
                window.isReleasedWhenClosed = false

                // Set window delegate to handle close events
                window.delegate = self

                mainWindow = window
                print("✅ Main window created")
            } catch {
                print("❌ Error creating main window: \(error)")
                return
            }
        }

        mainWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { [weak self] granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Permission request error: \(error.localizedDescription)")
                    self?.showPermissionError(error)
                } else if granted {
                    print("✅ Notification permissions granted")
                } else {
                    print("⚠️ Notification permissions denied by user")
                    self?.showPermissionDeniedAlert()
                }
            }
        }
    }

    private func showPermissionError(_ error: Error) {
        let alert = NSAlert()
        alert.messageText = "Permission Request Error"
        alert.informativeText = "Failed to request notification permissions: \(error.localizedDescription)"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    private func showPermissionDeniedAlert() {
        let alert = NSAlert()
        alert.messageText = "Notification Permissions Required"
        alert.informativeText = "NotificationNuke needs notification access to work. Please enable it in System Settings > Notifications."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    private func startMonitoringNotifications() {
        notificationManager.startMonitoring()
    }

    // MARK: - NSWindowDelegate Methods

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        // Hide window instead of closing it for better UX
        sender.orderOut(nil)
        print("📋 Main window hidden")
        return false
    }

    func windowDidResignMain(_ notification: Notification) {
        // Optional: Additional handling when window loses focus
        // For now, we don't need to do anything special here
        print("📋 Main window resigned focus")
    }
}

