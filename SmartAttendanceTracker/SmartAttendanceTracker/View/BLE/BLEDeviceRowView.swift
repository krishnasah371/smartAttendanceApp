import SwiftUI

struct BLEDeviceRowView: View {
    let device: BLEDevice
    let isConnecting: Bool
    let isConnected: Bool
    var connectAction: () -> Void
    var disconnectAction: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(device.name)
                    .font(.headline)
                Text("RSSI: \(device.rssi) dBm")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            
            if isConnecting {
                Button("Connecting") {}
                    .disabled(true)
                    .foregroundColor(.gray)
            } else if isConnected {
                Button("Disconnect") {
                    disconnectAction()
                }
                .foregroundColor(.red)
            } else {
                Button("Connect") {
                    connectAction()
                }
                .foregroundStyle(Color.primaryColor)
            }
        }
    }
}

#Preview {
    BLEDeviceRowView(
        device: BLEDevice(id: UUID(), name: "Mock Device", peripheral: nil, rssi: -50),
        isConnecting: false,
        isConnected: false,
        connectAction: {},
        disconnectAction: {})
}

