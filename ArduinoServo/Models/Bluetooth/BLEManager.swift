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
    
    @Published var peripherals: [Peripheral] = []
    @Published var isScanning = false
    
    var connectedPeripheral: CBPeripheral?
    var txCharacteristic: CBCharacteristic?
    var rxCharacteristic: CBCharacteristic?
    var characteristicASCIIValue = NSString()
    
    func startScanning() {
        isScanning = true
        manager.scanForPeripherals(withServices: [BLEService_UUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            self?.stopScanning()
        }
    }
    
    func stopScanning() {
        isScanning = false
        manager.stopScan()
    }
    
    func connect(to peripheral: Peripheral) {
        manager.connect(peripheral.peripheral, options: nil)
    }
    
    func disconnect(peripheral: Peripheral) {
        connectedPeripheral = nil
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
        
        print("didDiscover: \(peripheral)")
        print ("Advertisement Data: \(advertisementData)")
        
        self.peripherals.append(peripheral)
        self.rssis.append(RSSI)
        
        peripheral.delegate = self
        peripheral.discoverServices([BLEService_UUID])
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("didConnect: \(peripheral)")
        stopScanning()
        
        connectedPeripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices([BLEService_UUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("didFailToConnect: \(peripheral), error: \(error?.localizedDescription ?? "")")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == connectedPeripheral {
            connectedPeripheral = nil
        }
        print("didDisconnectPeripheral: \(peripheral), error: \(error?.localizedDescription ?? "")")
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
        
        print("didDiscoverServices: error \(services)")
        services.forEach { peripheral.discoverCharacteristics(nil, for: $0) }
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
                
                peripheral.setNotifyValue(true, for: characteristic)
                peripheral.readValue(for: characteristic)
                print("Rx Characteristic: \(characteristic.uuid)")
            }
            
            if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Tx) {
                txCharacteristic = characteristic
                
                print("Tx Characteristic: \(characteristic.uuid)")
            }
            
            peripheral.discoverDescriptors(for: characteristic)
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
