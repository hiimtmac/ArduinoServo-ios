//
//  BLEManager.swift
//  ArduinoServo
//
//  Created by Taylor McIntyre on 2019-12-21.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import Foundation
import Combine
import CoreBluetooth

class BLEManager: NSObject, ObservableObject {
    lazy var manager: CBCentralManager = {
        let m = CBCentralManager(delegate: self, queue: nil)
        return m
    }()
    
    @Published var peripherals: [CBPeripheral] = []
    @Published var isScanning = false
    @Published var connectedPeripheral: CBPeripheral? {
        didSet {
            connectedPeripheral?.delegate = self
            discoverServices()
        }
    }
    
    var txCharacteristic: CBCharacteristic?
    var rxCharacteristic: CBCharacteristic?
    
    var canSend: Bool {
        return txCharacteristic != nil
    }
    
    func startScanning() {
        print("Started scanning")
        isScanning = true
        manager.scanForPeripherals(withServices: [BLEService_UUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            self?.stopScanning()
        }
    }
    
    func stopScanning() {
        print("Stopped scanning")
        isScanning = false
        manager.stopScan()
        peripherals = []
    }
    
    func connect(to peripheral: CBPeripheral) {
        manager.connect(peripheral, options: nil)
    }
    
    func disconnect(peripheral: CBPeripheral) {
        connectedPeripheral = nil
        txCharacteristic = nil
        rxCharacteristic = nil
        if let connected = connectedPeripheral {
            manager.cancelPeripheralConnection(connected)
        }
    }
    
    func writeValue(message: String) {
        let data = Data(message.utf8)
        if let connected = connectedPeripheral, let tx = txCharacteristic {
            connected.writeValue(data, for: tx, type: .withResponse)
        }
    }
    
    func discoverServices() {
        connectedPeripheral?.discoverServices([BLEService_UUID])
    }
    
    func discoverCharacteristics(for service: CBService) {
        connectedPeripheral?.discoverCharacteristics(nil, for: service)
    }
}

extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Manager did update state:", central.state.rawValue, central.state)
        guard central.state == .poweredOn else {
            return
        }
        
        startScanning()
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("didDiscover: \(peripheral.name ?? "")")
        self.peripherals.append(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("didConnect: \(peripheral.name ?? "")")
        stopScanning()
        
        connectedPeripheral = peripheral
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("didFailToConnect: \(peripheral.name ?? ""), error: \(error?.localizedDescription ?? "")")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == connectedPeripheral {
            connectedPeripheral = nil
        }
        print("didDisconnectPeripheral: \(peripheral.name ?? ""), error: \(error?.localizedDescription ?? "")")
    }
}

extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("didDiscoverServices: error \(error)")
            return
        }
        
        guard let services = peripheral.services else {
            print("no services")
            return
        }
        
        print("didDiscoverServices: \(services.count)")
        services.forEach { discoverCharacteristics(for: $0) }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("didDiscoverDescriptorsFor")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("didDiscoverCharacteristicsFor: error \(error)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            print("no characteristics")
            return
        }
        
        for characteristic in characteristics {
            if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Rx)  {
                rxCharacteristic = characteristic
                
                connectedPeripheral?.setNotifyValue(true, for: characteristic)
                connectedPeripheral?.readValue(for: characteristic)
                print("Rx Characteristic: \(characteristic.uuid)")
            }
            
            if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Tx) {
                txCharacteristic = characteristic
                
                print("Tx Characteristic: \(characteristic.uuid)")
            }
            
            connectedPeripheral?.discoverDescriptors(for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic == rxCharacteristic {
            if let value = characteristic.value {
                let string = String(decoding: value, as: UTF8.self)
                print("Value Recieved: \(string)")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("didWriteValueFor: error \(error)")
            return
        }
        
        print("Message sent")
    }
}
