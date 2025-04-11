import CoreBluetooth
import Foundation
import Combine

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var isPoweredOn: Bool = false
    @Published var isBluetoothEnabled: Bool = false
    @Published var discoveredDevices: [BLEDevice] = []
    @Published var discoveredDevicesCount = 0
    @Published var connectedPeripheral: CBPeripheral?
    @Published var connectingDeviceID: String?
    @Published var isScanning = false

    private var centralManager: CBCentralManager!

    // Whitelist of known devices
    private let knownDevices: [String: String] = [
        "BlueCharm_199298": "LIB317 - Senior Seminar"
    ]

    override init() {
        super.init()
        #if !targetEnvironment(simulator)
        self.centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        #endif
    }

    // MARK: - Bluetooth Status Tracking
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async {
            switch central.state {
            case .unknown: print("❓ Bluetooth state is unknown")
            case .resetting: print("🔄 Bluetooth is resetting")
            case .unsupported: print("🚫 Bluetooth is not supported")
            case .unauthorized: print("❌ Bluetooth permission not granted")
            case .poweredOff: print("🔴 Bluetooth is OFF")
            case .poweredOn: print("🟢 Bluetooth is ON")
            @unknown default: print("⚠️ Unknown Bluetooth state")
            }
            self.isBluetoothEnabled = (central.state == .poweredOn)
        }
    }

    // MARK: - Scanning for Devices
    func startScanning() {
        guard centralManager.state == .poweredOn else {
            print("❌ Cannot scan: Bluetooth is OFF")
            return
        }
        print("🔎 Scanning for BLE devices...")
        discoveredDevices.removeAll()
        discoveredDevicesCount = discoveredDevices.count
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        // Optional: Stop scan after 5-10 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                self.centralManager.stopScan()
                print("⛔️ Scan stopped")
            }
    }

    func centralManager(
        _ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any], rssi RSSI: NSNumber
    ) {
        DispatchQueue.main.async {
            guard let deviceName = peripheral.name, !deviceName.isEmpty else {
                return
            }

            let displayName = self.knownDevices[deviceName] ?? deviceName

            if !self.discoveredDevices.contains(where: { $0.id == "\(peripheral.identifier)"}) {
                let newDevice = BLEDevice(
                    id: "\(peripheral.identifier)", name: displayName,
                    peripheral: peripheral, rssi: RSSI.intValue
                )
                self.discoveredDevices.append(newDevice)
                self.discoveredDevicesCount = self.discoveredDevices.count
                print("📡 Found Device: \(displayName) - RSSI: \(RSSI)")
            }
        }
    }

    // MARK: - Connecting and Disconnecting Devices
    func connectToDevice(_ device: BLEDevice) {
        guard let peripheral = device.peripheral else {
            print("⚠️ Cannot connect: Peripheral is nil")
            return
        }
        print("🧷 Connecting to \(device.name)...")
        self.connectingDeviceID = "\(device.id)"
        self.connectedPeripheral = nil
        centralManager.connect(peripheral, options: nil)
    }

    func disconnectDevice() {
        guard let connectedPeripheral = connectedPeripheral else {
            print("⚠️ No device connected")
            return
        }
        print("🔌 Disconnecting from \(connectedPeripheral.name ?? "Unknown Device")...")
        self.centralManager.cancelPeripheralConnection(connectedPeripheral)
        self.connectingDeviceID = nil
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("✅ Connected to \(peripheral.name ?? "Unknown")")
        self.connectingDeviceID = nil
        self.connectedPeripheral = peripheral
        peripheral.delegate = self
        peripheral.readRSSI()
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("🔌 Disconnected from \(peripheral.name ?? "Unknown")")
        self.connectedPeripheral = nil
        self.connectingDeviceID = nil
    }
}
