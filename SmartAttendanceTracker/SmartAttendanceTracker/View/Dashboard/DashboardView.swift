import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            Text("Dashboard View")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 50)
            Spacer()
        }
    }
}

#Preview {
    DashboardView()
}
