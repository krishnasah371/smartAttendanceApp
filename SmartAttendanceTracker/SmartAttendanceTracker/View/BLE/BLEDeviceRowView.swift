import SwiftUI

struct BLEDeviceRowView: View {
    let device: BLEDevice
    let isSelected: Bool
    let selectAction: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(device.name)
                    .font(.headline)
                Text("RSSI: \(device.rssi) dBm")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()

            Button(action: {
                selectAction()
            }) {
                Text(isSelected ? "Selected" : "Select")
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(isSelected ? Color.green.opacity(0.2) : Color.primaryColor.opacity(0.1))
                    .foregroundColor(isSelected ? .green : .primaryColorDark)
                    .cornerRadius(8)
            }
        }
        .padding(10)
        .background(isSelected ? Color.green.opacity(0.05) : Color.gray.opacity(0.05))
        .cornerRadius(10)
    }
}

//#Preview {
//    BLEDeviceRowView(
//        device: BLEDevice(id: UUID(), name: "Mock Device", peripheral: nil, rssi: -50),
//        isConnecting: false,
//        isConnected: false,
//        connectAction: {},
//        disconnectAction: {})
//}

