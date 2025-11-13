# NotificationNuke v2.0 - App Store Edition

A lightweight macOS app that clears all notifications instantly with one click from the main window or menu bar.

## Features

- **One-Click Clearing**: Click "Clear All Notifications" in the main window or menu bar to instantly clear all macOS notifications
- **Main Window Interface**: Professional UI showing notification count and clear button
- **Menu Bar Access**: Quick access from menu bar icon with real-time badge
- **Real-Time Updates**: Notification count updates every 5 seconds
- **Launch at Login**: Optional auto-start using modern SMAppService API
- **Native macOS**: Built with SwiftUI and AppKit for optimal performance
- **App Store Ready**: Fully sandboxed and compliant with App Store guidelines

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later (for building)

> **Note:** v2.0 is App Store compliant. Global keyboard shortcuts have been removed for compatibility. See [MIGRATION_V2.md](MIGRATION_V2.md) for details.

## Building the App

1. Open `NotificationNuke.xcodeproj` in Xcode
2. Select your development team in the project settings (Signing & Capabilities)
3. Build and run the project (Cmd+R)

The app will appear in your menu bar as a bell icon with a notification count badge.

## How It Works

NotificationNuke uses the macOS `UNUserNotificationCenter` API to:
- Monitor delivered notifications every 5 seconds (battery-efficient)
- Clear all notifications with `removeAllDeliveredNotifications()`
- Update both the main window and menu bar badge in real-time
- Use NSBackgroundActivityScheduler for efficient background polling

The app is fully App Store compliant with no deprecated APIs or restricted entitlements.

## Project Structure

```
NotificationNuke/
├── NotificationNuke.xcodeproj/
│   └── project.pbxproj
├── NotificationNuke/
│   ├── NotificationNukeApp.swift      # App entry point
│   ├── AppDelegate.swift              # Menu bar and window coordination
│   ├── MainWindowView.swift           # Main application window (NEW v2.0)
│   ├── NotificationManager.swift      # Notification clearing and monitoring
│   ├── LaunchAtLoginManager.swift     # Launch at login (SMAppService)
│   ├── PreferencesView.swift          # Preferences window UI
│   ├── MenuBarView.swift              # Menu bar view (reference)
│   ├── Assets.xcassets/               # App icon and assets
│   ├── Info.plist                     # App Store compatible configuration
│   └── NotificationNuke.entitlements  # Minimal sandbox permissions
├── README.md
├── QUICKSTART.md
├── TECHNICAL.md
└── MIGRATION_V2.md                    # v1.0 → v2.0 migration guide
```

## Distribution & Notarization

### Preparing for App Store

1. **Set up App Store Connect**:
   - Create an app record in App Store Connect
   - Set bundle identifier to `com.notificationnuke.app` (or your custom ID)

2. **Configure Code Signing**:
   - In Xcode, select your target
   - Go to "Signing & Capabilities"
   - Select your development team
   - Enable "Automatically manage signing"

3. **Archive the App**:
   - Select "Any Mac" as the build destination
   - Product → Archive
   - In Organizer, select your archive
   - Click "Distribute App"
   - Choose "App Store Connect"
   - Follow the wizard to upload

### Notarizing for Distribution Outside App Store

1. **Archive with Hardened Runtime**:
   - Ensure "Enable Hardened Runtime" is checked in Build Settings (already configured)
   - Archive the app as above

2. **Export Notarized App**:
   - In Organizer, click "Distribute App"
   - Choose "Developer ID"
   - Select "Upload" to notarize
   - Wait for Apple's notarization service to complete

3. **Staple the Notarization**:
   ```bash
   xcrun stapler staple "NotificationNuke.app"
   ```

4. **Create DMG** (optional):
   ```bash
   hdiutil create -volname "NotificationNuke" -srcfolder "NotificationNuke.app" -ov -format UDZO "NotificationNuke.dmg"
   ```

## Permissions

The app requires:
- **Notification Access**: To read and clear delivered notifications (prompted on first launch)

No accessibility permissions required in v2.0 (keyboard shortcuts removed for App Store compliance).

## Configuration

### Launch at Login
- Toggle in main window or Preferences
- Uses modern SMAppService framework (macOS 13+ only)
- Syncs with System Settings automatically

### Keyboard Shortcuts
- ⚠️ Global keyboard shortcuts removed in v2.0 for App Store compliance
- See [MIGRATION_V2.md](MIGRATION_V2.md) for details

## License

Copyright © 2024 NotificationNuke. All rights reserved.

## Troubleshooting

**Notifications not clearing?**
- Ensure you've granted notification permissions in System Settings → Notifications → NotificationNuke

**Notification count not updating?**
- Wait 5 seconds (polling interval)
- Restart the app if count seems stuck

**Main window not appearing?**
- Check menu bar for bell icon, click "Preferences"
- Press Cmd+N to reopen main window
- The app now appears in Dock (v2.0 change)

## Contributing

This is a focused, minimal app. Feature requests should align with the core purpose: instant notification clearing.
