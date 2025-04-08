import CoreBluetooth

extension BLEManager {
    static let mock: BLEManager = {
        let mockManager = BLEManager()
        mockManager.isBluetoothEnabled = true
        mockManager.discoveredDevices = [
            BLEDevice(id: UUID(), name: "LIB-317", peripheral: nil, rssi: -50),
            BLEDevice(id: UUID(), name: "PJ-307", peripheral: nil, rssi: -60),
        ]
        return mockManager
    }()
}
