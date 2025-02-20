import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        NavigationSplitView {
            Text("Hello World")
                .bold()
                .font(.title)
        } detail: {
        }
    }


}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
