# App Store Submission Guide - NotificationNuke v2.0

## Pre-Submission Checklist

### ✅ Code Complete
- [x] All deprecated APIs removed (Carbon Event Manager)
- [x] Global keyboard shortcuts removed
- [x] Main window UI implemented
- [x] Entitlements minimized for App Store
- [x] Info.plist updated with required keys
- [x] macOS 13.0+ target set
- [x] SMAppService used for launch at login

### ✅ Testing
- [ ] Test on clean macOS 13.0 system
- [ ] Test on macOS 14.0 (Sonoma)
- [ ] Verify notification clearing works
- [ ] Check notification count updates (5s interval)
- [ ] Test launch at login toggle
- [ ] Verify menu bar icon functionality
- [ ] Check Energy Impact (should be "Low")
- [ ] Test main window UI
- [ ] Verify app survives sleep/wake
- [ ] Test with 0, 1, and 50+ notifications

### ✅ Build Configuration
- [ ] Development team selected
- [ ] Bundle identifier set: `com.notificationnuke.app` (or your custom ID)
- [ ] Version: 2.0
- [ ] Build number: 1 (or increment from previous)
- [ ] Code signing: Automatic
- [ ] Hardened Runtime: Enabled
- [ ] App Sandbox: Enabled

---

## Step-by-Step Submission

### 1. Archive the App

```bash
# Open Xcode
open NotificationNuke.xcodeproj

# Set scheme to "Any Mac"
# Product → Archive

# Wait for archive to complete
# Xcode Organizer will open automatically
```

### 2. Validate Archive

In Xcode Organizer:
1. Select your archive
2. Click "Validate App"
3. Choose "App Store Connect"
4. Follow prompts
5. Fix any errors/warnings

**Common validation errors:**
- Missing bundle identifier
- Code signing issues → Check development team
- Entitlements issues → Verify entitlements file is correct

### 3. Upload to App Store Connect

1. Click "Distribute App"
2. Choose "App Store Connect"
3. Select "Upload"
4. Choose distribution options:
   - ✅ Upload your app's symbols
   - ✅ Manage Version and Build Number
5. Review and submit

**Upload takes 5-15 minutes.**

### 4. Create App Record in App Store Connect

Visit: https://appstoreconnect.apple.com

**App Information:**
- **Name:** NotificationNuke
- **Bundle ID:** com.notificationnuke.app (must match Xcode)
- **SKU:** notificationnuke-001
- **Primary Language:** English (U.S.)

**Category:**
- **Primary:** Utilities
- **Secondary:** Productivity (optional)

**Pricing:**
- **Price:** Free (or your choice)
- **Availability:** All territories

---

## App Store Metadata

### App Name
```
NotificationNuke
```

### Subtitle (30 chars max)
```
Clear All Notifications
```

### Promotional Text (170 chars)
```
Tired of notification clutter? Clear all macOS notifications instantly with one click. Native design, privacy-focused, no data collection. Available now on macOS 13+.
```

### Description
```
NotificationNuke - Clear All Notifications Instantly

Tired of notification clutter overwhelming your Mac? NotificationNuke is the simplest way to clear all macOS notifications with just one click.

FEATURES:
• Clear all notifications instantly with one button
• Real-time notification count display
• Menu bar quick access for convenience
• Launch at login option for automatic startup
• Native macOS design with light/dark mode support
• Privacy-focused: zero data collection, no network access
• Battery-efficient: optimized polling every 5 seconds

PERFECT FOR:
• Power users managing dozens of daily notifications
• Professionals who need a clean notification center
• Anyone tired of manually clearing notification stacks
• Users who value privacy and simplicity

HOW IT WORKS:
1. Launch NotificationNuke (appears in menu bar)
2. See your current notification count in the main window
3. Click "Clear All Notifications" button
4. All notifications disappear instantly

REQUIREMENTS:
• macOS 13.0 (Ventura) or later
• Notification permissions (granted on first launch)

PRIVACY:
• No data collection or analytics
• No network connection
• Fully sandboxed for security
• All operations happen locally on your Mac

WHAT'S NEW IN v2.0:
• App Store Edition with full compliance
• Improved main window interface
• Better battery efficiency (5-second polling)
• Modern launch-at-login using SMAppService
• Removed global keyboard shortcuts for App Store compatibility

Note: This version is optimized for App Store distribution. Global keyboard shortcuts have been removed to comply with App Store guidelines. You can still clear notifications instantly via the main window or menu bar icon.

SUPPORT:
For questions or feedback, contact [your support email].

Download NotificationNuke today and take control of your notification center!
```

### Keywords (100 chars max)
```
notifications,clear,utility,menu bar,productivity,clean,notification center,mac,macos,efficiency
```

### Support URL
```
https://your-website.com/notificationnuke/support
```

### Privacy Policy URL (REQUIRED)
```
https://your-website.com/notificationnuke/privacy
```

**Sample Privacy Policy:**
```
NotificationNuke Privacy Policy

NotificationNuke respects your privacy. The app:
- Does NOT collect any personal data
- Does NOT track usage or analytics
- Does NOT connect to the internet
- Does NOT share data with third parties

The only data stored is:
- Your launch-at-login preference (stored locally in macOS UserDefaults)

All notification operations happen locally on your Mac using Apple's UNUserNotificationCenter API.

For questions: [your email]
Last updated: [date]
```

---

## Screenshots (REQUIRED)

### Required Sizes
- **macOS:** 1280x800 or 1440x900 or 2560x1600 or 2880x1800

### Screenshot Ideas

**Screenshot 1: Main Window**
- Show main window with notification count
- "Clear All Notifications" button prominent
- Caption: "Clear all notifications with one click"

**Screenshot 2: Menu Bar**
- Show menu bar icon with badge
- Dropdown menu visible
- Caption: "Quick access from your menu bar"

**Screenshot 3: Settings**
- Show launch-at-login toggle
- Caption: "Customize your experience"

**Screenshot 4: Before/After**
- Split screen showing Notification Center before/after
- Caption: "Instant results"

**Screenshot 5: Clean UI**
- Show app in light and dark mode
- Caption: "Native macOS design"

### Taking Screenshots
```bash
# Run the app
# Press Cmd+Shift+4 + Space
# Click window to capture
# Resize to required dimensions in Preview if needed
```

---

## App Review Information

### Contact Information
- **First Name:** [Your name]
- **Last Name:** [Your name]
- **Phone:** [Your phone]
- **Email:** [Your email]

### Demo Account
Not required for NotificationNuke (no login)

### Notes for Review
```
NotificationNuke v2.0 - App Store Edition

This version has been fully refactored for App Store compliance:

REMOVED FEATURES:
- Global keyboard shortcuts (Carbon Event Manager) - deprecated API
- Accessibility permissions requirement - no longer needed

NEW FEATURES:
- Main window UI (standard macOS app)
- Improved battery efficiency (5-second polling)
- Modern SMAppService for launch-at-login

TESTING INSTRUCTIONS:
1. Grant notification permissions when prompted
2. Send yourself test notifications (Mail, Messages, Calendar, etc.)
3. Open NotificationNuke main window
4. Click "Clear All Notifications" button
5. Verify all notifications are cleared from Notification Center

PERMISSIONS:
- Notification access only (no accessibility or other special permissions)

The app is fully sandboxed with minimal entitlements. No network access, no data collection, no third-party SDKs.

Thank you for reviewing NotificationNuke!
```

### Attachment (Optional)
Upload a brief demo video (< 30 seconds) showing:
1. App launch
2. Notification count display
3. Clicking "Clear All"
4. Notifications disappearing

---

## Export Compliance

### Does your app use encryption?
**Answer: NO**

Set in Info.plist:
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

This skips the lengthy export compliance review process.

---

## Age Rating

**Age Rating:** 4+
- No objectionable content
- No gambling, violence, or mature themes
- Safe for all ages

---

## Post-Submission

### Review Timeline
- **Typical:** 1-3 days
- **Peak times:** Up to 7 days
- **Expedited review:** Available for urgent issues (not recommended for initial submission)

### Possible Rejection Reasons & Fixes

**1. "App uses private or undocumented APIs"**
- Fix: Verify no Carbon Event Manager code remains
- Action: Re-check codebase, resubmit

**2. "App doesn't function as expected"**
- Fix: Ensure notification permissions are requested properly
- Action: Add clearer permission prompt explanation, resubmit

**3. "Privacy policy missing or incomplete"**
- Fix: Add comprehensive privacy policy URL
- Action: Host policy on web, update App Store Connect

**4. "App crashes on launch"**
- Fix: Test on clean macOS 13.0 system
- Action: Fix crash, increment build number, resubmit

**5. "App uses excessive battery"**
- Fix: Verify polling is 5 seconds (not 2 seconds)
- Action: Test Energy Impact, resubmit if needed

### If Approved
1. Choose release option:
   - **Manual:** You control release date
   - **Automatic:** Goes live immediately after approval
   - **Scheduled:** Release on specific date

2. Monitor reviews and ratings
3. Respond to user feedback
4. Plan updates based on user requests

### If Rejected
1. Read rejection notes carefully
2. Fix issues as described
3. Increment build number
4. Resubmit with "Resolution Center" notes explaining fixes

---

## Version Updates

### For Future Versions (2.1, 2.2, etc.)

1. Increment version in Xcode:
   - Marketing Version: 2.1
   - Build number: Auto-increment or manual

2. Archive and upload as above

3. In App Store Connect:
   - Click "+ Version or Platform"
   - Enter new version number
   - Add "What's New" notes
   - Submit for review

**What's New Template:**
```
Version 2.1 Release Notes:

NEW:
• [New feature description]

IMPROVED:
• [Improvement description]

FIXED:
• [Bug fix description]

Thank you for using NotificationNuke! Please rate and review if you enjoy the app.
```

---

## Marketing Checklist

After approval:
- [ ] Tweet about launch
- [ ] Post on Product Hunt
- [ ] Share on Reddit (r/macapps)
- [ ] Update personal website
- [ ] Add "Download on App Store" badge
- [ ] Email existing users (if any)
- [ ] Monitor reviews and respond

---

## Support Resources

### Apple Documentation
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [macOS App Distribution](https://developer.apple.com/distribute/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)

### NotificationNuke Docs
- [README.md](README.md) - General documentation
- [MIGRATION_V2.md](MIGRATION_V2.md) - v1.0 → v2.0 changes
- [TECHNICAL.md](TECHNICAL.md) - Architecture details

---

## Final Checklist

Before clicking "Submit for Review":

- [ ] App tested on macOS 13.0+
- [ ] Screenshots uploaded (5 required)
- [ ] Description written and spell-checked
- [ ] Keywords optimized (< 100 chars)
- [ ] Privacy policy URL added
- [ ] Support URL added
- [ ] Price and availability set
- [ ] Age rating: 4+
- [ ] Export compliance: No encryption
- [ ] Review notes written
- [ ] Contact information complete
- [ ] All metadata in English (or your language)

---

## 🚀 Ready to Submit!

Once everything above is complete:

1. Go to App Store Connect
2. Select your app
3. Click "Submit for Review"
4. Wait for email notification

**Good luck with your submission!**

---

## Contact & Support

If you have questions about this submission guide:
- Open an issue on GitHub
- Email: [your email]
- Twitter: [your handle]

**Version:** 2.0
**Last Updated:** 2024-11-13
