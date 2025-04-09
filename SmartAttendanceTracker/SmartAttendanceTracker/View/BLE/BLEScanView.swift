import SwiftUI

struct BLEScanView: View {
    @ObservedObject var bleManager: BLEManager
    var onBeaconSelected: (BLEDevice) -> Void
    @State private var selectedDeviceID: String? = nil
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
                        ForEach(Array(0..<bleManager.discoveredDevicesCount), id: \.self) { index in
                            let device = bleManager.discoveredDevices[index]
                            BLEDeviceRowView(
                                device: device,
                                isSelected: selectedDeviceID == device.id,
                                selectAction: {
                                    selectedDeviceID = device.id
                                    onBeaconSelected(device)
                                }
                            )
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
