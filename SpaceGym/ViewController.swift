//
//  ViewController.swift
//  SpaceGym
//
//  Created by Doni Pebruwantoro on 20/05/24.
//

import Cocoa
import SpriteKit
import GameplayKit
import CoreBluetooth

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, BluetoothManagerDelegate{
    @IBOutlet var skView: SKView!
    @IBOutlet weak var tableView: NSTableView!
    
    var bluetoothManager: BluetoothManager!
    var discoveredPeripherals: [CBPeripheral] = []
    
    func didUpdateDevices() {
        discoveredPeripherals = bluetoothManager.discoveredPeripheral
        tableView.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return discoveredPeripherals.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DeviceCell"), owner: self) as? NSTableCellView else {
            return nil
        }
        let peripheral = discoveredPeripherals[row]
        cell.textField?.stringValue = peripheral.name ?? "Unknown device"
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        bluetoothManager = BluetoothManager()
//        bluetoothManager.delegate = self
//        tableView.dataSource = self
//        tableView.delegate = self
//        bluetoothManager.startScanning()
        
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "GameScene") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene? {
                
                // Copy gameplay related content over to the scene
                sceneNode.entities = scene.entities
                sceneNode.graphs = scene.graphs
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                
                // Present the scene
                if let view = self.skView {
                    view.presentScene(sceneNode)
                    
//                    view.ignoresSiblingOrder = true
//                    
//                    view.showsFPS = true
//                    view.showsNodeCount = true
                }
            }
        }
    }
}

