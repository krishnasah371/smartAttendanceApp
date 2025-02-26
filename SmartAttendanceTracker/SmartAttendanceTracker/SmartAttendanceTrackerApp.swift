import SwiftData
import SwiftUI

@main
struct SmartAttendanceTrackerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([])
        let modelConfiguration = ModelConfiguration(
            schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(
                for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            SplashScreenView() 
        }
        .modelContainer(sharedModelContainer)
    }
}
