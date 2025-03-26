import CoreBluetooth
import Combine

protocol BLEManagerProtocol: AnyObject {
    var isBluetoothEnabled: Bool { get }
    var discoveredDevices: [BLEDevice] { get }
    var connectedPeripheral: CBPeripheral? { get }
    var connectingDeviceID: UUID? { get }

    func startScanning()
    func connectToDevice(_ device: BLEDevice)
    func disconnectDevice()
}
