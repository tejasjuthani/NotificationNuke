import SwiftUI
import ServiceManagement

struct PreferencesView: View {
    @State private var launchAtLogin = LaunchAtLoginManager.shared.isEnabled

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Preferences")
                .font(.title2)
                .fontWeight(.semibold)

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                Text("General")
                    .font(.headline)

                Toggle("Launch at Login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { newValue in
                        LaunchAtLoginManager.shared.setEnabled(newValue)
                    }

                Text("Automatically start NotificationNuke when you log in to your Mac.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                Text("About")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Version:")
                        Spacer()
                        Text("2.0 (App Store Edition)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Compatibility:")
                        Spacer()
                        Text("macOS 13.0+")
                            .foregroundColor(.secondary)
                    }
                }
                .font(.subheadline)

                Text("NotificationNuke clears all delivered notifications from macOS Notification Center. Global keyboard shortcuts have been removed for App Store compatibility.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }

            Spacer()
        }
        .padding(20)
        .frame(width: 400, height: 300)
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
