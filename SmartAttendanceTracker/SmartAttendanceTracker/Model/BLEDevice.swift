import CoreBluetooth

struct BLEDevice: Identifiable {
    let id: UUID
    let name: String
    let peripheral: CBPeripheral?
    let rssi: Int
}
