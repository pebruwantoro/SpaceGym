//
//  BluetoothConnection.swift
//  SpaceGym
//
//  Created by Doni Pebruwantoro on 20/05/24.
//

import Cocoa
import CoreBluetooth

protocol BluetoothManagerDelegate: AnyObject {
    func didUpdateDevices()
}

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var discoveredPeripheral: [CBPeripheral] = []
    weak var delegate: BluetoothManagerDelegate?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // Start scanning for devices
    func startScanning() {
        print("Start scanning for devices")
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(value: false)])
    }

    // CBCentralManagerDelegate method - check Bluetooth state
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is powered on")
            startScanning()
        case .poweredOff:
            print("Bluetooth is powered off")
        case .resetting:
            print("Bluetooth is resetting")
        case .unauthorized:
            print("Bluetooth is unauthorized")
        case .unsupported:
            print("Bluetooth is unsupported")
        case .unknown:
            print("Bluetooth state is unknown")
        @unknown default:
            fatalError("A new state is available that is not handled")
        }
    }

    // CBCentralManagerDelegate method - discovered peripheral
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print("Discovered \(peripheral.name ?? "unknown device") at \(RSSI)")
        
        // Save the discovered peripheral and stop scanning
        if !discoveredPeripheral.contains(peripheral) {
            discoveredPeripheral.append(peripheral)
            delegate?.didUpdateDevices()
        }
//        discoveredPeripheral = peripheral
        if discoveredPeripheral.count == 10 {
            centralManager.stopScan()
        }
        
        // Connect to the peripheral
        print("ini list bluetooth",discoveredPeripheral)
//        centralManager.connect(peripheral, options: nil)
    }

    // CBCentralManagerDelegate method - connected to peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "unknown device")")
        
        // Set the peripheral delegate and discover services
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    // CBCentralManagerDelegate method - failed to connect to peripheral
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.name ?? "unknown device"): \(error?.localizedDescription ?? "unknown error")")
    }

    // CBPeripheralDelegate method - discovered services
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else { return }
        for service in services {
            print("Discovered service \(service)")
            // Discover characteristics for the service
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    // CBPeripheralDelegate method - discovered characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            print("Discovered characteristic \(characteristic)")
        }
    }
}
