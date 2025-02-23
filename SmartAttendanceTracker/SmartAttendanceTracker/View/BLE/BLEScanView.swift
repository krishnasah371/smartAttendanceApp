import SwiftUI

struct BLEScanView: View {
    @StateObject private var bleManager = BLEManager()

//    init() {
//        #if debug
//            if processinfo.processinfo.environment["xcode_running_for_previews"]
//                == "1"
//            {
//                _bleManager = StateObject(wrappedValue: BLEManager.mock)
//            } else {
//                _bleManager = StateObject(wrappedValue: BLEManager())
//            }
//        #else
//        _bleManager = StateObject(wrappedValue: BLEManager())
//        #endif
//    }

    var body: some View {
        NavigationStack {
            VStack {
                BLEStatusView(isBluetoothEnabled: bleManager.isBluetoothEnabled)

                // ✅ scan button
                Button(action: {
                    bleManager.startScanning()
                }) {
                    Text("Scan for Devices")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.primaryAccentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.bottom)
//                .disabled(!bleManager.isBluetoothEnabled)

                // ✅ list of discovered devices
                List(bleManager.discoveredDevices, id: \.id) { device in
                    BLEDeviceRowView(
                        device: device,
                        isConnecting: bleManager.connectingDeviceID
                            == device.id,
                        isConnected: bleManager.connectedPeripheral?.identifier
                            == device.id,
                        connectAction: { bleManager.connectToDevice(device) },
                        disconnectAction: { bleManager.disconnectDevice() }

                    )
                }
            }
            .padding()
            .navigationTitle("Connect to your class.")
        }
    }
}

#Preview {
    BLEScanView()
        .environmentObject(BLEManager.mock)
}
