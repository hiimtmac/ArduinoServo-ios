//
//  PeripheralView.swift
//  ArduinoServo
//
//  Created by Taylor McIntyre on 2019-12-21.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import SwiftUI
import Combine
import CoreBluetooth

struct PeripheralView: View {
    @ObservedObject var ble: BLEManager
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {}) {
                    Text("Stop Scanning")
                }.disabled(!ble.isScanning)
                Spacer()
                Button(action: {}) {
                    Text("Start Scanning")
                }.disabled(ble.isScanning)
                Spacer()
            }
            List {
                ble.connectedPeripheral.map { peripheral in
                    Section(header: Text("Connected")) {
                        Button(action: { self.ble.disconnect(peripheral: peripheral) }) {
                            HStack {
                                Text(peripheral.name ?? "unknown")
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                Section(header: Text("Peripherals")) {
                    ForEach(ble.peripherals, id: \.name) { peripheral in
                        Button(action: { self.ble.connect(to: peripheral) }) {
                            Text(peripheral.name ?? "unknown")
                        }
                    }
                }
            }
        }
    }
}

struct PeripheralView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PeripheralView(ble: BLEManager())
        }
    }
}
