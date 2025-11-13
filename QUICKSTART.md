# NotificationNuke - Quick Start Guide

## Getting Started in 3 Steps

### 1. Open in Xcode
```bash
open NotificationNuke.xcodeproj
```

### 2. Configure Signing
- Click on the project in the left sidebar
- Select the "NotificationNuke" target
- Go to "Signing & Capabilities" tab
- Select your development team from the dropdown
- Xcode will automatically configure signing

### 3. Build & Run
- Press Cmd+R or click the Play button
- The app will launch and appear in your menu bar (top-right corner)
- Look for a bell icon 🔔

## First Launch

1. **Grant Permissions**: macOS will ask for notification access. Click "OK" and open System Settings if prompted.

2. **Test the App**:
   - Click the bell icon in your menu bar
   - Click "Clear All Notifications" to test
   - Try the keyboard shortcut: Cmd+Option+N

3. **Customize** (Optional):
   - Click the bell icon → "Preferences"
   - Enable "Launch at Login"
   - Customize keyboard shortcut if desired

## Features at a Glance

| Feature | How to Use |
|---------|------------|
| Clear notifications | Click menu bar icon → "Clear All Notifications" |
| Keyboard shortcut | Press Cmd+Option+N (default) |
| View count | Check the number next to the bell icon |
| Preferences | Click menu bar icon → "Preferences..." |
| Launch at login | Enable in Preferences |

## Troubleshooting

**Can't see the app?**
- Look in the top-right menu bar (it won't appear in the Dock)
- Check Activity Monitor for "NotificationNuke"

**Notifications not clearing?**
- Open System Settings → Notifications
- Ensure NotificationNuke has permissions

**Build errors?**
- Ensure you selected a development team in Signing & Capabilities
- Target macOS 12.0+ is required
- Clean build folder: Shift+Cmd+K, then rebuild

## File Locations

- **Source Code**: `NotificationNuke/`
- **Xcode Project**: `NotificationNuke.xcodeproj`
- **Built App**: `~/Library/Developer/Xcode/DerivedData/.../Build/Products/Debug/NotificationNuke.app`

## Next Steps

- Read [README.md](README.md) for full documentation
- Customize the app icon in `Assets.xcassets/AppIcon.appiconset`
- Review code in individual Swift files for specific functionality

## Code Overview

| File | Purpose |
|------|---------|
| `NotificationNukeApp.swift` | App entry point |
| `AppDelegate.swift` | Menu bar UI and coordination |
| `NotificationManager.swift` | Clears notifications, tracks count |
| `HotKeyManager.swift` | Global keyboard shortcuts |
| `LaunchAtLoginManager.swift` | Auto-start functionality |
| `PreferencesView.swift` | Settings window UI |

---

**Questions?** Check the full [README.md](README.md) or review the inline code comments.
