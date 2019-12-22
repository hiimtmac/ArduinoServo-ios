//
//  BLEKeys.swift
//  ArduinoServo
//
//  Created by Taylor McIntyre on 2019-12-21.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import CoreBluetooth

private let kBLEService_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
private let kBLE_Characteristic_uuid_Tx = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"
private let kBLE_Characteristic_uuid_Rx = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"
let MaxCharacters = 20

let BLEService_UUID = CBUUID(string: kBLEService_UUID)
/// Write without response
let BLE_Characteristic_uuid_Tx = CBUUID(string: kBLE_Characteristic_uuid_Tx)
/// Read/Notify
let BLE_Characteristic_uuid_Rx = CBUUID(string: kBLE_Characteristic_uuid_Rx)
