import SwiftUI

struct BLEStatusView: View {
    let isBluetoothEnabled: Bool

    var body: some View {
        HStack {
            Text("Bluetooth Status: \(isBluetoothEnabled ? "🟢 ON" : "🔴 OFF")")
                .font(.headline)
            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    BLEStatusView(isBluetoothEnabled: true)
}
