import SwiftUI

/// App Store compliant preferences window for NotificationNuke
/// Follows macOS Human Interface Guidelines and accessibility standards
struct MainWindowView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var showingClearConfirmation = false
    @State private var showingClearSuccess = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var launchAtLogin = LaunchAtLoginManager.shared.isEnabled
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header Section
                VStack(spacing: 12) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .accessibilityHidden(true)

                    Text("NotificationNuke")
                        .font(.title)
                        .fontWeight(.bold)
                        .accessibilityAddTraits(.isHeader)

                    Text("Clear all macOS notifications instantly")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .accessibilityLabel("NotificationNuke app description")
                }
                .padding(.top, 40)
                .padding(.bottom, 30)

                Divider()

                // Notification Count Section
                VStack(spacing: 16) {
                    // Status display with colorblind-friendly indicator
                    HStack(spacing: 12) {
                        Image(systemName: "number.circle.fill")
                            .foregroundColor(.blue)
                            .accessibilityHidden(true)

                        Text("Current Notifications")
                            .font(.headline)

                        Spacer()

                        HStack(spacing: 8) {
                            Text("\(notificationManager.notificationCount)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(notificationManager.notificationCount > 0 ? .red : .green)

                            // Add symbol for colorblind accessibility
                            Image(systemName: notificationManager.notificationCount > 0 ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
                                .foregroundColor(notificationManager.notificationCount > 0 ? .red : .green)
                                .accessibilityHidden(true)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .accessibilityLabel("Notification Status")
                    .accessibilityValue("\(notificationManager.notificationCount) notification\(notificationManager.notificationCount != 1 ? "s" : "")")
                    .accessibilityHint(notificationManager.notificationCount > 0 ? "You have pending notifications" : "All notifications cleared")

                    // Clear Button with standard macOS styling
                    Button(action: {
                        if notificationManager.notificationCount > 0 {
                            showingClearConfirmation = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .accessibilityHidden(true)
                            Text("Clear All Notifications")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(notificationManager.notificationCount == 0)
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .accessibilityLabel("Clear All Notifications")
                    .accessibilityHint(notificationManager.notificationCount > 0 ? "Remove all \(notificationManager.notificationCount) notification(s)" : "No notifications to clear")
                    .alert("Clear All Notifications?", isPresented: $showingClearConfirmation) {
                        Button("Cancel", role: .cancel) { }
                        Button("Clear", role: .destructive) {
                            notificationManager.clearAllNotifications()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showingClearSuccess = true
                            }
                        }
                    } message: {
                        Text("This will remove all \(notificationManager.notificationCount) notification\(notificationManager.notificationCount != 1 ? "s" : ""). This action cannot be undone.")
                    }
                    .alert("Notifications Cleared", isPresented: $showingClearSuccess) {
                        Button("OK") { }
                    } message: {
                        Text("All notifications have been successfully removed.")
                    }
                }
                .padding()

                Divider()

                // Settings Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Settings")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)

                    // Launch at Login Toggle
                    Toggle("Launch at Login", isOn: $launchAtLogin)
                        .accessibilityLabel("Launch at Login")
                        .accessibilityHint("Enable or disable starting NotificationNuke automatically when you log in")
                        .onChange(of: launchAtLogin) { newValue in
                            LaunchAtLoginManager.shared.setEnabled(newValue)
                        }

                    // Help/About Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                                .accessibilityHidden(true)
                            Text("About")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .accessibilityAddTraits(.isHeader)
                        }

                        Text("NotificationNuke automatically monitors and manages macOS notifications. Clear individual notifications from the menu bar or use this window to clear all at once. Launch at Login ensures the app runs whenever you start your Mac.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                            .accessibilityLabel("About NotificationNuke")
                    }
                    .padding(.top, 8)
                }
                .padding()

                Spacer(minLength: 20)

                // Footer with Version
                HStack(spacing: 12) {
                    Text("Version 2.0 - App Store Edition")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .accessibilityLabel("App version")

                    Spacer()

                    Button("Quit") {
                        NSApplication.shared.terminate(nil)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Quit NotificationNuke")
                    .accessibilityHint("Close the preferences window and exit the application")
                }
                .padding()
            }
        }
        .frame(maxWidth: 500)
        .frame(minHeight: 500, maxHeight: 700)
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
}

// MARK: - Preview Variants for App Store Testing
#Preview("Light Mode") {
    MainWindowView()
        .environmentObject(NotificationManager.shared)
        .preferredColorScheme(.light)
        .frame(width: 500, height: 600)
}

#Preview("Dark Mode") {
    MainWindowView()
        .environmentObject(NotificationManager.shared)
        .preferredColorScheme(.dark)
        .frame(width: 500, height: 600)
}

#Preview("With Notifications") {
    let mockManager = NotificationManager.shared
    mockManager.notificationCount = 5

    return MainWindowView()
        .environmentObject(mockManager)
        .preferredColorScheme(.light)
        .frame(width: 500, height: 600)
}

#Preview("No Notifications") {
    let mockManager = NotificationManager.shared
    mockManager.notificationCount = 0

    return MainWindowView()
        .environmentObject(mockManager)
        .preferredColorScheme(.dark)
        .frame(width: 500, height: 600)
}
