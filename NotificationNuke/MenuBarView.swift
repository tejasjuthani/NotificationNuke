import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var notificationManager: NotificationManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notifications: \(notificationManager.notificationCount)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Divider()

            Button("Clear All Notifications") {
                notificationManager.clearAllNotifications()
            }

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(8)
    }
}

struct MenuBarView_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarView().environmentObject(NotificationManager.shared)
    }
}
