import CoreBluetooth

struct BLEDevice: Identifiable {
    let id: String
    let name: String
    let peripheral: CBPeripheral?
    let rssi: Int
}
