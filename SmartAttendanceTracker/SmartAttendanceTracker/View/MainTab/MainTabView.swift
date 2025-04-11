import Foundation
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var selectedTab = 0
    @State private var classes: [ClassModel] = []
    @State private var isLoading = true
    @State private var fetchError: String?

    @Environment(\.dismiss) var dismiss

    var body: some View {
        if let user = AuthManager.shared.getUser() {
            if isLoading {
                ProgressView("Fetching your classes...")
                    .task {
                        await fetchUserClasses()
                    }
            } else if let error = fetchError {
                VStack {
                    Text("Failed to load classes.")
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            } else {
                TabView(selection: $selectedTab) {
                    DashboardView(user: user, classes: classes,updateClassStatus: {Task {
                        await fetchUserClasses() // <-- async function
                    }})
                        .tabItem {
                            Label("Dashboard", systemImage: "rectangle.grid.2x2")
                        }
                        .tag(0)

                    BLEMainView(user: user, enrolledClasses: classes, updateClassStatus: {Task {
                        await fetchUserClasses() // <-- async function
                    }})
                        .tabItem {
                            Label("Attendance", systemImage: "calendar")
                        }
                        .tag(1)

                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gearshape")
                        }
                        .tag(2)
                }
                .tabViewStyle(DefaultTabViewStyle())
            }
        } else {
            WelcomeView()
        }
    }
    func updateClassStatus() async {
        await fetchUserClasses()
    }

    private func fetchUserClasses() async {
        do {
            let fetched = try await ClassService.shared.fetchEnrolledClasses()
            self.classes = fetched ?? []
//            self.fetchError = nil
        } catch let error as NetworkError {
            self.fetchError = error.localizedDescription
            self.classes = []

            if case .unauthorized = error {
                print("🚪 Unauthorized: Logging out")
                AuthManager.shared.removeToken()
                sessionManager.isLoggedIn = false
                dismiss() // Automatically returns to login view if root is protected
            }
        } catch {
            self.fetchError = error.localizedDescription
            self.classes = []
        }

        self.isLoading = false
    }
    
    private func fetchUserDetails() async {
        do {
            let fetched = try await ClassService.shared.fetchEnrolledClasses()
            self.classes = fetched ?? []
//            self.fetchError = nil
        } catch let error as NetworkError {
            self.fetchError = error.localizedDescription
            self.classes = []

            if case .unauthorized = error {
                print("🚪 Unauthorized: Logging out")
                AuthManager.shared.removeToken()
                sessionManager.isLoggedIn = false
                dismiss() // Automatically returns to login view if root is protected
            }
        } catch {
            self.fetchError = error.localizedDescription
            self.classes = []
        }

        self.isLoading = false
    }

}
