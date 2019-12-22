//
//  Peripheral.swift
//  ArduinoServo
//
//  Created by Taylor McIntyre on 2019-12-21.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import Foundation
import Combine
import CoreBluetooth

struct Peripheral: Identifiable {
    let rssi: NSNumber
    let peripheral: CBPeripheral
    
    var id: UUID {
        return peripheral.identifier
    }
}
