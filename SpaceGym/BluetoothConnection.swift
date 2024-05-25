//
//  BluetoothConnection.swift
//  SpaceGym
//
//  Created by Doni Pebruwantoro on 20/05/24.
//

import Cocoa
import CoreBluetooth

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
//    var discoveredPeripheral: CBPeripheral!
    let serviceUUID = CBUUID(string: "49d67131-f8d8-4305-915c-11b60e84233d")
    let characteristicUUID = CBUUID(string: "143d0be0-f68d-4f67-8c5f-53830d3d58d2")
    var devicePeripheral: CBPeripheral!
    var discoveredServices: Set<CBService> = []
    var gyroData: String = ""
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: .global())
    }
    
    // Start scanning for devices
    func startScanning() {
        print("Start scanning for devices")
        
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
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
    
    func getDataGyroscopeFromDevice() -> [Double] {
        var result: [Double] = []
        let temp = self.gyroData.split(separator: ",")
        result = temp.compactMap {Double($0)}
//        print("result ini", result)
        return result
    }
    
    // CBCentralManagerDelegate method - discovered peripheral
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print("Discovered \(peripheral.name ?? "unknown device") at \(RSSI)")
        peripheral.delegate = self
        devicePeripheral = peripheral
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
        
    }
    
    // CBCentralManagerDelegate method - connected to peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "unknown device")")
        
        // Set the peripheral delegate and discover services
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
        devicePeripheral.discoverServices([serviceUUID])
        devicePeripheral.delegate = self
    }
    
    // CBCentralManagerDelegate method - failed to connect to peripheral
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.name ?? "unknown device"): \(error?.localizedDescription ?? "unknown error")")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            let receivedString = String(data: data, encoding: .utf8)
            self.gyroData = receivedString!
//            print("Received: \(receivedString ?? "No Data")")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        
        if let services = peripheral.services {
            for service in services {
                if !discoveredServices.contains(service) {
                    discoveredServices.insert(service)
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == characteristicUUID {
                    peripheral.setNotifyValue(true, for: characteristic)
                    peripheral.readValue(for: characteristic)
                }
            }
        }
    }
}
