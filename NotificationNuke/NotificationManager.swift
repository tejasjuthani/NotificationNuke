import Foundation
import UserNotifications
import Combine

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()

    @Published private(set) var notificationCount: Int = 0 {
        didSet {
            onCountChanged?(notificationCount)
        }
    }

    var onCountChanged: ((Int) -> Void)?

    private var timer: Timer?
    private var backgroundTask: NSBackgroundActivityScheduler?

    // Increased interval for App Store compliance (battery efficiency)
    private let pollingInterval: TimeInterval = 5.0

    private override init() {
        super.init()
        setupBackgroundActivity()
    }

    func startMonitoring() {
        updateNotificationCount()

        // Use a longer interval to be more battery-efficient for App Store
        timer = Timer.scheduledTimer(withTimeInterval: pollingInterval, repeats: true) { [weak self] _ in
            self?.updateNotificationCount()
        }

        // Add timer to common run loop modes so it works during menu tracking
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }

    private func setupBackgroundActivity() {
        // Setup background activity scheduler for when app is in background
        backgroundTask = NSBackgroundActivityScheduler(identifier: "com.notificationnuke.app.monitoring")
        backgroundTask?.repeats = true
        backgroundTask?.interval = pollingInterval
        backgroundTask?.tolerance = 2.0

        backgroundTask?.schedule { [weak self] completion in
            self?.updateNotificationCount()
            completion(.finished)
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    private func updateNotificationCount() {
        UNUserNotificationCenter.current().getDeliveredNotifications { [weak self] notifications in
            DispatchQueue.main.async {
                self?.notificationCount = notifications.count
            }
        }
    }

    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.updateNotificationCount()
        }
    }

    deinit {
        stopMonitoring()
    }
}
