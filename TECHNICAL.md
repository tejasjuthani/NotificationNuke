# NotificationNuke - Technical Documentation

## Architecture Overview

NotificationNuke is a native macOS menu bar application built with SwiftUI and AppKit, targeting macOS 12.0+. The app uses a modular architecture with clear separation of concerns.

## Core Components

### 1. App Lifecycle (`NotificationNukeApp.swift`)

```swift
@main
struct NotificationNukeApp: App
```

- Entry point using SwiftUI's `@main` attribute
- Uses `@NSApplicationDelegateAdaptor` to bridge to AppDelegate
- Minimal SwiftUI scene (Settings with EmptyView) as the app is menu bar-only

### 2. Menu Bar Management (`AppDelegate.swift`)

**Responsibilities:**
- Create and manage `NSStatusItem` in the system menu bar
- Build the dropdown menu using `NSMenu` and `NSMenuItem`
- Coordinate between NotificationManager and HotKeyManager
- Handle user interactions (clear, preferences, quit)
- Update menu bar badge in real-time

**Key Implementation Details:**
```swift
statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
```

- Uses SF Symbols `bell.fill` for the icon
- Updates badge count via button title
- Observes `NotificationManager.onCountChanged` callback for real-time updates

### 3. Notification Management (`NotificationManager.swift`)

**Responsibilities:**
- Monitor delivered notifications using `UNUserNotificationCenter`
- Track notification count
- Clear all notifications on demand
- Provide callbacks for UI updates

**Key APIs:**
```swift
UNUserNotificationCenter.current().getDeliveredNotifications()  // Get count
UNUserNotificationCenter.current().removeAllDeliveredNotifications()  // Clear all
```

**Monitoring Strategy:**
- Polls every 2 seconds using `Timer.scheduledTimer`
- Updates count asynchronously on main thread
- Singleton pattern for app-wide access

**Limitations:**
- macOS only allows clearing delivered notifications (not pending)
- Cannot filter by app (all-or-nothing)
- Requires notification permissions from user

### 4. Keyboard Shortcuts (`HotKeyManager.swift`)

**Responsibilities:**
- Register global keyboard shortcuts using Carbon Event Manager
- Handle hotkey events and trigger notifications clearing
- Store and retrieve custom hotkey configurations
- Convert key codes to human-readable strings

**Key Implementation:**
```swift
RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
```

**Default Hotkey:**
- Key: N (keyCode 45)
- Modifiers: Cmd+Option (cmdKey | optionKey)

**Architecture:**
- Uses Carbon's `EventHotKeyRef` for global registration
- `InstallEventHandler` to receive hotkey pressed events
- Unmanaged pointers to pass Swift object to C callbacks
- UserDefaults for persistence

**Supported Modifiers:**
- ⌘ Command (cmdKey)
- ⌥ Option (optionKey)
- ⇧ Shift (shiftKey)
- ⌃ Control (controlKey)

### 5. Launch at Login (`LaunchAtLoginManager.swift`)

**Responsibilities:**
- Enable/disable launch at login
- Handle both modern (macOS 13+) and legacy APIs
- Persist user preference

**Implementation:**
```swift
// macOS 13+
SMAppService.mainApp.register()
SMAppService.mainApp.unregister()

// macOS 12
SMLoginItemSetEnabled(bundleIdentifier as CFString, enabled)
```

**Storage:**
- Uses UserDefaults with key "LaunchAtLogin"
- Provides `isEnabled` computed property for SwiftUI binding

### 6. Preferences UI (`PreferencesView.swift`)

**Responsibilities:**
- Display preferences window
- Toggle launch at login
- Show and customize keyboard shortcut
- Reset to default settings

**UI Components:**
- SwiftUI `Toggle` for launch at login
- Custom button showing current hotkey
- Reset button for defaults
- 400x250px fixed size window

**SwiftUI Integration:**
- Hosted in `NSWindow` via `NSHostingController`
- `@State` for local UI state
- Direct interaction with manager singletons

## App Configuration

### Info.plist Key Settings

```xml
<key>LSUIElement</key>
<true/>
```
- Makes app a "UI Element" (no Dock icon, menu bar only)

```xml
<key>NSUserNotificationAlertStyle</key>
<string>alert</string>
```
- Ensures proper notification behavior

### Entitlements

```xml
<key>com.apple.security.app-sandbox</key>
<true/>
```
- Enables App Sandbox for App Store distribution

```xml
<key>com.apple.security.automation.apple-events</key>
<true/>
```
- Required for global keyboard shortcuts

## Data Flow

### Notification Clearing Flow

1. User triggers clear (button click or hotkey)
2. `AppDelegate` or `HotKeyManager` calls `NotificationManager.clearAllNotifications()`
3. NotificationManager calls `UNUserNotificationCenter.current().removeAllDeliveredNotifications()`
4. After 0.5s delay, NotificationManager updates count
5. `onCountChanged` callback fires
6. AppDelegate updates menu bar badge on main thread

### Notification Count Updates

```
Timer (2s interval)
  → getDeliveredNotifications()
  → Update notificationCount property
  → Trigger onCountChanged callback
  → Update menu bar badge and menu item
```

### Hotkey Registration Flow

1. App launches → HotKeyManager.registerHotKey()
2. Load saved keyCode/modifiers from UserDefaults (or use defaults)
3. Install Carbon event handler with Swift object pointer
4. Register hotkey with Carbon API
5. When pressed → Event handler → onHotKeyPressed callback → Clear notifications

## Thread Safety

- All UI updates forced to main thread via `DispatchQueue.main.async`
- Notification queries run on background thread (UNUserNotificationCenter's queue)
- Timer runs on main run loop
- Singleton pattern with private init prevents race conditions

## Memory Management

- Weak references in closures to prevent retain cycles
- Proper cleanup in deinit (timers, event handlers)
- Unmanaged pointers for C interop (Carbon API)
- SwiftUI handles view lifecycle automatically

## Performance Considerations

- Timer interval: 2 seconds (balance between responsiveness and CPU usage)
- Notification queries are async (non-blocking)
- Menu bar updates batched to avoid excessive redraws
- No database or disk I/O except UserDefaults

## Security & Privacy

### Sandbox Restrictions
- App Sandbox enabled for App Store compliance
- No network access required
- No file system access beyond standard containers
- Apple Events entitlement for global hotkeys

### Permissions Required
- **Notifications**: Read and remove delivered notifications
- No camera, microphone, contacts, or location access

### Data Collection
- Zero telemetry or analytics
- No user data leaves the device
- Only local preferences stored in UserDefaults

## Build Configuration

### Deployment Target
- macOS 12.0 (Monterey) minimum
- Compatible with macOS 13+ (Ventura) for modern SMAppService API

### Build Settings
- Swift 5.0
- Hardened Runtime enabled
- Automatic code signing
- App Sandbox enabled

### Dependencies
- UserNotifications.framework (system)
- Carbon.framework (system, for hotkeys)
- ServiceManagement.framework (system, for launch at login)
- SwiftUI (system)
- AppKit (system)

## Testing Considerations

### Manual Testing Checklist
- [ ] Menu bar icon appears on launch
- [ ] Badge shows correct notification count
- [ ] Click "Clear All" removes all notifications
- [ ] Hotkey (Cmd+Option+N) works from any app
- [ ] Preferences window opens and displays current settings
- [ ] Launch at login toggle persists across app restarts
- [ ] Hotkey customization saves and applies correctly
- [ ] App survives sleep/wake cycle
- [ ] Multiple notification sources (Mail, Messages, etc.) all clear

### Known Limitations
1. **No Undo**: Cleared notifications cannot be recovered
2. **No Selective Clearing**: Cannot clear specific apps
3. **Polling Delay**: Up to 2 seconds latency on count updates
4. **macOS API Restriction**: Can only clear delivered notifications, not scheduled ones
5. **Permission Required**: Must be granted notification access in System Settings

## Debugging Tips

### Enable Console Logging
Add print statements in:
- `NotificationManager.updateNotificationCount()` - Track count changes
- `HotKeyManager.registerHotKey()` - Verify hotkey registration
- `AppDelegate.setupMenuBar()` - Debug menu creation

### Common Issues
- **Badge not updating**: Check Timer is running, verify permissions
- **Hotkey not working**: Confirm entitlements, check for conflicts with other apps
- **Launch at login fails**: Verify bundle identifier matches, check macOS version

### Xcode Instruments
- **Time Profiler**: Verify timer isn't consuming excessive CPU
- **Allocations**: Check for memory leaks in closures
- **Energy Log**: Ensure low power consumption

## Future Enhancement Ideas (Not Implemented)

Per the product requirements, these are intentionally omitted:
- Notification history or undo
- Per-app filtering
- Scheduling or automation
- Statistics/analytics dashboard
- Dark mode toggle (uses system appearance automatically)
- Sound effects or animations
- Cloud sync or multi-device support

## Code Style

- Swift naming conventions (camelCase, PascalCase for types)
- Singleton pattern for managers (`.shared`)
- Completion handlers for async callbacks (`onCountChanged`, `onHotKeyPressed`)
- SwiftUI for modern UI components
- AppKit for menu bar and system integration
- Minimal comments (self-documenting code)

## Distribution Checklist

Before releasing:
- [ ] Test on multiple macOS versions (12, 13, 14+)
- [ ] Add real app icon to Assets.xcassets
- [ ] Update bundle identifier to your domain
- [ ] Set Development Team in Xcode
- [ ] Archive and notarize with Apple
- [ ] Test on clean Mac without Xcode installed
- [ ] Verify permissions dialogs appear correctly
- [ ] Check menu bar icon in both light and dark mode
- [ ] Test hotkey doesn't conflict with common apps

---

This documentation covers the technical implementation of NotificationNuke as of version 1.0.
