import SwiftUI

struct NotificationsView: View {
    let notifications = [
        "🔔 Your 9AM class is about to start!",
        "✅ You marked present in Mobile Dev.",
        "📌 Tomorrow’s attendance is mandatory.",
        "📣 New announcement from Prof. James.",
        "📅 Test scheduled for next Tuesday."
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                SettingsHeaderView()

                List(notifications, id: \.self) { note in
                    Label(note, systemImage: "bell.fill")
                }
                .listStyle(.plain)
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}

#Preview {
    NotificationsView()
}
