import Foundation
import ServiceManagement

/// Manages "Launch at Login" functionality using ServiceManagement framework
///
/// **App Store Compliance:**
/// - Uses modern SMAppService API (introduced macOS 13.0)
/// - Requires `com.apple.security.automation` entitlement
/// - Requires `com.apple.security.app-sandbox = true` entitlement
/// - Deprecated SMAppService is no longer used
///
/// **Sandbox Restrictions:**
/// - The app runs in a restricted sandbox after launch
/// - User may need to grant permissions in System Settings
/// - Notification clearing operations work within sandbox constraints
///
/// **System Integration:**
/// - ServiceManagement handles all launch-at-login logic
/// - No shell scripts or launchd plists needed
/// - Works seamlessly across updates
/// - Properly integrates with macOS login experience
class LaunchAtLoginManager {
    static let shared = LaunchAtLoginManager()

    private let launchAtLoginKey = "LaunchAtLogin"

    /// Returns whether Launch at Login is currently enabled
    /// Checks both system status and cached preference
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

    /// Enables or disables Launch at Login
    /// - Parameter enabled: `true` to enable, `false` to disable
    ///
    /// This method registers or unregisters the app with ServiceManagement.
    /// On success, updates both the system and UserDefaults.
    /// On failure, still caches user intent in UserDefaults.
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
                print("✓ Launch at Login enabled")
            } else {
                try SMAppService.mainApp.unregister()
                UserDefaults.standard.set(false, forKey: launchAtLoginKey)
                print("✓ Launch at Login disabled")
            }
        } catch {
            // Log the actual error for debugging
            let action = enabled ? "enable" : "disable"
            print("⚠ Failed to \(action) launch at login: \(error.localizedDescription)")

            // Still update UserDefaults to reflect user intent
            // Next app launch will attempt again
            UserDefaults.standard.set(enabled, forKey: launchAtLoginKey)
        }
    }

    /// Synchronize cached UserDefaults with actual system status
    /// Called on initialization to ensure consistency
    private func syncStatus() {
        let systemEnabled = SMAppService.mainApp.status == .enabled
        UserDefaults.standard.set(systemEnabled, forKey: launchAtLoginKey)
    }
}
