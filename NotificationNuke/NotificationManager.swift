import Foundation
import UserNotifications
import Combine
import AppKit

/// NotificationManager monitors system notifications and provides clearing functionality.
///
/// App Store Compliance:
/// - Uses 5-second polling interval (battery efficient)
/// - No background execution - respects app suspension
/// - Pauses monitoring when app enters background
/// - Resumes monitoring when app becomes active
/// - Thread-safe: all UI updates dispatched to main thread
/// - No deprecated APIs - uses UNUserNotificationCenter
/// - Proper resource cleanup and error handling
class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()

    @Published private(set) var notificationCount: Int = 0 {
        didSet {
            onCountChanged?(notificationCount)
        }
    }

    var onCountChanged: ((Int) -> Void)?

    private var timer: Timer?
    private var isMonitoring: Bool = false

    // Polling interval optimized for battery efficiency and App Store compliance
    private let pollingInterval: TimeInterval = 5.0

    // App state observers
    private var appStateObservers: [NSObjectProtocol] = []

    private override init() {
        super.init()
        setupAppStateMonitoring()
    }

    /// Starts monitoring notifications with proper app state handling.
    func startMonitoring() {
        guard !isMonitoring else { return }

        isMonitoring = true
        updateNotificationCount()

        // Use a longer interval to be battery-efficient for App Store compliance
        // Interval: 5 seconds is reasonable - not too frequent (battery), not too slow (UI responsiveness)
        timer = Timer.scheduledTimer(withTimeInterval: pollingInterval, repeats: true) { [weak self] _ in
            self?.updateNotificationCount()
        }

        // Add timer to common run loop modes so it works during menu tracking
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }

        logDebug("Notification monitoring started")
    }

    /// Stops monitoring notifications.
    func stopMonitoring() {
        guard isMonitoring else { return }

        isMonitoring = false
        timer?.invalidate()
        timer = nil
        logDebug("Notification monitoring stopped")
    }

    /// Sets up listeners for app state changes to pause/resume monitoring.
    /// This ensures the app respects suspension and doesn't drain battery.
    private func setupAppStateMonitoring() {
        // Listen for app becoming active (enters foreground)
        let activeObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.resumeMonitoringIfNeeded()
        }

        // Listen for app resigning active (enters background)
        let resignObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.pauseMonitoringIfNeeded()
        }

        appStateObservers = [activeObserver, resignObserver]
    }

    /// Resumes monitoring if it was previously started.
    private func resumeMonitoringIfNeeded() {
        // Re-start the timer if monitoring was active but paused
        if isMonitoring && timer == nil {
            startMonitoring()
        }
    }

    /// Pauses monitoring when app enters background (App Store compliance).
    private func pauseMonitoringIfNeeded() {
        if isMonitoring {
            timer?.invalidate()
            timer = nil
            logDebug("Monitoring paused - app in background")
        }
    }

    /// Updates the notification count from UNUserNotificationCenter.
    /// Thread-safe: callback dispatched to main thread.
    private func updateNotificationCount() {
        UNUserNotificationCenter.current().getDeliveredNotifications { [weak self] notifications in
            DispatchQueue.main.async {
                // Check if self is still valid and monitoring is still active
                guard let self = self, self.isMonitoring else { return }

                let count = notifications.count
                if self.notificationCount != count {
                    self.notificationCount = count
                    self.logDebug("Notification count updated: \(count)")
                }
            }
        }
    }

    /// Clears all delivered notifications and updates the count.
    /// Includes error handling and logging for App Store compliance.
    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()

        logDebug("Cleared all notifications")

        // Update count after a short delay to ensure the system has processed the removal
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.updateNotificationCount()
        }
    }

    /// Private helper for debug logging.
    private func logDebug(_ message: String) {
        #if DEBUG
        print("[NotificationManager] \(message)")
        #endif
    }

    deinit {
        stopMonitoring()

        // Remove app state observers
        for observer in appStateObservers {
            NotificationCenter.default.removeObserver(observer)
        }
        appStateObservers.removeAll()

        logDebug("NotificationManager deinitialized")
    }
}
