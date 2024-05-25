//
//  Bluetooth.swift
//  iOSController
//
//  Created by Doni Pebruwantoro on 25/05/24.
//

import SwiftUI
import CoreMotion
import CoreBluetooth

class GyroscopeViewController: UIViewController, CBPeripheralDelegate, CBPeripheralManagerDelegate {
    
    var centralManager =  CMMotionManager()
    var peripheralManager: CBPeripheralManager!
    var characteristic: CBMutableCharacteristic!
    var discoveredPeripheral: [CBPeripheral] = []
    private var motionManager: CMMotionManager = CMMotionManager()
    private var rotationRate: CMRotationRate = CMRotationRate()
    let serviceUUID = CBUUID(string: "49d67131-f8d8-4305-915c-11b60e84233d")
    let characteristicUUID = CBUUID(string: "143d0be0-f68d-4f67-8c5f-53830d3d58d2")
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Initialize CoreBluetooth peripheral manager
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        
        // Initialize CoreMotion motion manager
        motionManager = CMMotionManager()
        motionManager.startGyroUpdates()
    }
    
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
                        
            let service = CBMutableService(type: serviceUUID, primary: true)
            characteristic = CBMutableCharacteristic(type: characteristicUUID, properties: [.notify, .read, .write], value: nil, permissions: [.readable])
            service.characteristics = [characteristic]
            peripheralManager.add(service)
            
            peripheralManager.startAdvertising([
                CBAdvertisementDataServiceUUIDsKey: [serviceUUID],
                CBAdvertisementDataLocalNameKey: "MyPeripheral"
            ])
        }
    }
    
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            print("Error adding service: \(error.localizedDescription)")
            return
        } else {
            sendGyroscopeData()
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("Error advertising: \(error.localizedDescription)")
        } else {
            print("Peripheral advertising")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("Central subscribed to characteristic")
        sendGyroscopeData()
    }
    
    func sendGyroscopeData() {
        getGyroscopeData { [weak self] dataStr in
            guard let self = self else { return }
            
            print("data di send gyro", dataStr)
            if let data = dataStr.data(using: .utf8) {
                let success = self.peripheralManager.updateValue(data, for: self.characteristic, onSubscribedCentrals: nil)
                if success {
                    print("Characteristic value updated successfully.")
                } else {
                    print("Failed to update characteristic value.")
                }
                
            }
        }
    }
    
    func getGyroscopeData(completion: @escaping (String) -> Void) {
        var data: String = ""
        if motionManager.isGyroActive || motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = 0.1
            motionManager.startGyroUpdates(to: OperationQueue.main) { [weak self] (gyroData, error) in
                guard let self = self else { return }
                
                if let gyroData = gyroData {
                    self.rotationRate = gyroData.rotationRate
                    let gyroX = gyroData.rotationRate.x
                    let gyroY = gyroData.rotationRate.y
                    let gyroZ = gyroData.rotationRate.z
                    data = "\(gyroX),\(gyroY),\(gyroZ)"
                }
                
                completion(data) // Call the completion handler with the gyro data
            }
        } else {
            completion(data) // Call the completion handler with an empty string if gyroscope is not active or available
        }
    }
}

struct GyroscopeViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> GyroscopeViewController {
        return GyroscopeViewController()
    }
    
    func updateUIViewController(_ uiViewController: GyroscopeViewController, context: Context) {
        // Do nothing
    }
}
