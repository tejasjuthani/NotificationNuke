import SwiftUI

struct MainWindowView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var showingClearConfirmation = false
    @State private var launchAtLogin = LaunchAtLoginManager.shared.isEnabled

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                Text("NotificationNuke")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Clear all macOS notifications instantly")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            .padding(.bottom, 30)

            Divider()

            // Notification Count Section
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "number.circle.fill")
                        .foregroundColor(.blue)
                    Text("Current Notifications")
                        .font(.headline)
                    Spacer()
                    Text("\(notificationManager.notificationCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(notificationManager.notificationCount > 0 ? .red : .green)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)

                // Clear Button
                Button(action: {
                    if notificationManager.notificationCount > 0 {
                        showingClearConfirmation = true
                    }
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("Clear All Notifications")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(notificationManager.notificationCount > 0 ? Color.red : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .disabled(notificationManager.notificationCount == 0)
                .alert("Clear All Notifications?", isPresented: $showingClearConfirmation) {
                    Button("Cancel", role: .cancel) { }
                    Button("Clear", role: .destructive) {
                        notificationManager.clearAllNotifications()
                    }
                } message: {
                    Text("This will remove all \(notificationManager.notificationCount) notification(s). This action cannot be undone.")
                }
            }
            .padding()

            Divider()

            // Settings Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Settings")
                    .font(.headline)

                Toggle("Launch at Login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { newValue in
                        LaunchAtLoginManager.shared.setEnabled(newValue)
                    }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("About")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Text("NotificationNuke uses the macOS notification system to clear delivered notifications. You can also clear notifications from the menu bar icon.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 8)
            }
            .padding()

            Spacer()

            // Footer
            HStack {
                Text("Version 2.0 - App Store Edition")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            }
            .padding()
        }
        .frame(width: 500, height: 400)
    }
}

struct MainWindowView_Previews: PreviewProvider {
    static var previews: some View {
        MainWindowView()
            .environmentObject(NotificationManager.shared)
    }
}
