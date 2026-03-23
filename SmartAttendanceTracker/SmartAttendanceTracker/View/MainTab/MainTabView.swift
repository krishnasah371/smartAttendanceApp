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
            var loadedClasses = fetched ?? []
            
            // For student role — fetch attendance percentage for each class
            if let user = AuthManager.shared.getUser(), user.role == .student {
                for i in 0..<loadedClasses.count {
                    do {
                        let attendanceData = try await AttendenceService.shared.getMyAttendance(
                            classId: loadedClasses[i].id
                        )
                        // Update the attendance percentage on the class
                        loadedClasses[i].attendancePercentage = attendanceData.percentage
                    } catch {
                        // If fetch fails for one class, just leave it at 0%
                        print("⚠️ Could not fetch attendance for class \(loadedClasses[i].id)")
                    }
                }
            }
            
            // For teacher role — calculate class average attendance for each class
            if let user = AuthManager.shared.getUser(), user.role == .teacher {
                for i in 0..<loadedClasses.count {
                    do {
                        // Fetch all attendance records for this class
                        let response = try await AttendenceService.shared.getClassAttendance(
                            classId: loadedClasses[i].id
                        )
                        let records = response.attendance ?? []
                        
                        // Calculate average: present records / total records
                        let total = records.count
                        let present = records.filter { $0.status == "present" }.count
                        
                        if total > 0 {
                            loadedClasses[i].attendancePercentage = (present * 100) / total
                        }
                    } catch {
                        print("⚠️ Could not fetch attendance for class \(loadedClasses[i].id)")
                    }
                }
            }
            
            self.classes = loadedClasses
        } catch let error as NetworkError {
            self.fetchError = error.localizedDescription
            self.classes = []

            if case .unauthorized = error {
                print("🚪 Unauthorized: Logging out")
                AuthManager.shared.removeToken()
                sessionManager.isLoggedIn = false
                dismiss()
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
