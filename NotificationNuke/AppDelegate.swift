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

        // Sync launch-at-login preference (do not re-register every launch)
        // Read system status without forcing register/unregister
        LaunchAtLoginManager.shared.syncStatus()

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
        if mainWindow == nil {
            let mainView = MainWindowView().environmentObject(NotificationManager.shared)
            let hostingController = NSHostingController(rootView: mainView)

            let window = NSWindow(contentViewController: hostingController)
            window.title = "NotificationNuke"

            // App Store compliant window configuration
            // Include resizable flag for better user experience and HIG compliance
            window.styleMask = [.titled, .closable, .miniaturizable, .resizable]

            // Set initial size and constraints
            window.setContentSize(NSSize(width: 500, height: 600))

            // Set minimum and maximum sizes for proper window behavior
            // Minimum: 400x500 (prevents UI from becoming unusable)
            // Maximum: 600x800 (prevents excessive scaling on large displays)
            window.minSize = NSSize(width: 400, height: 500)
            window.maxSize = NSSize(width: 600, height: 800)

            // Center window on screen (App Store recommended)
            window.center()

            // Keep window in memory when closed (for quick reopening)
            window.isReleasedWhenClosed = false

            // Do not set a restorationClass unless a proper NSWindowRestoration implementer exists.
            // Accessibility: window title is already set and will be used by VoiceOver.
            // Assign window delegate so delegate methods are called.
            window.delegate = self

            mainWindow = window
        }

        // Avoid re-showing if already visible
        guard mainWindow?.isVisible != true else { return }
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

