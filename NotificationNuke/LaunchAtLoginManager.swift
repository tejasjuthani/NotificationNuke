import Foundation
import ServiceManagement

/// Manages "Launch at Login" functionality using modern SMAppService API
/// App Store compliant - requires macOS 13.0+
class LaunchAtLoginManager {
    static let shared = LaunchAtLoginManager()

    private let launchAtLoginKey = "LaunchAtLogin"

    var isEnabled: Bool {
        get {
            // Check both UserDefaults and actual system status
            if SMAppService.mainApp.status == .enabled {
                return true
            }
            return UserDefaults.standard.bool(forKey: launchAtLoginKey)
        }
    }

    private init() {
        // Sync UserDefaults with actual system status on init
        syncStatus()
    }

    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                if SMAppService.mainApp.status == .enabled {
                    // Already enabled, no need to register again
                    UserDefaults.standard.set(true, forKey: launchAtLoginKey)
                    return
                }
                try SMAppService.mainApp.register()
                UserDefaults.standard.set(true, forKey: launchAtLoginKey)
            } else {
                try SMAppService.mainApp.unregister()
                UserDefaults.standard.set(false, forKey: launchAtLoginKey)
            }
        } catch {
            print("Failed to \(enabled ? "enable" : "disable") launch at login: \(error)")
            // Even if registration fails, update UserDefaults to reflect user intent
            UserDefaults.standard.set(enabled, forKey: launchAtLoginKey)
        }
    }

    /// Synchronize UserDefaults with actual system status
    private func syncStatus() {
        let systemEnabled = SMAppService.mainApp.status == .enabled
        UserDefaults.standard.set(systemEnabled, forKey: launchAtLoginKey)
    }
}
