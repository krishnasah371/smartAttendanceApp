import SwiftUI

struct BLEScanView: View {
    @ObservedObject var bleManager: BLEManager

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
                        .background(Color.primaryColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.bottom)
//                .disabled(!bleManager.isBluetoothEnabled)
                if bleManager.isScanning {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text("Scanning for devices...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom)
                } else {
                    Text("Not scanning currently...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                // ✅ list of discovered devices
                if bleManager.discoveredDevicesCount > 0 {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(0..<bleManager.discoveredDevicesCount, id: \.self) { index in
                            if index < bleManager.discoveredDevices.count {
                                BLEDeviceRowView(
                                    device: bleManager.discoveredDevices[index],
                                    isConnecting: bleManager.connectingDeviceID == bleManager.discoveredDevices[index].id,
                                    isConnected: bleManager.connectedPeripheral?.identifier == bleManager.discoveredDevices[index].id,
                                    connectAction: {
                                        bleManager.connectToDevice(bleManager.discoveredDevices[index])
                                    },
                                    disconnectAction: {
                                        bleManager.disconnectDevice()
                                    }
                                )
                            }
                        }
                    }
                } else {
                    Text("No devices found yet.")
                        .foregroundColor(.gray)
                        .padding(.top)
                }
            }
            .padding()
        }
    
}

//#Preview {
//    BLEScanView()
//        .environmentObject(BLEManager.mock)
//}
