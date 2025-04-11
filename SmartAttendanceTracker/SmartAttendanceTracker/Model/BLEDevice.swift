import CoreBluetooth

struct BLEDevice: Identifiable {
    let id: String
    let name: String
    let peripheral: CBPeripheral?
    let rssi: Int
}


struct UpdateBLEPayload: Codable {
    let ble_id: String
}

struct BLEResponse: Codable {
    let message: String?
}
