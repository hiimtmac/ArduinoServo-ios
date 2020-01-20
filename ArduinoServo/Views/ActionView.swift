//
//  ActionView.swift
//  ArduinoServo
//
//  Created by Taylor McIntyre on 2019-12-21.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import SwiftUI
import Combine

struct ActionView: View {
    @ObservedObject var ble: BLEManager
    
    var body: some View {
        VStack {
            VStack {
                Toggle(isOn: $ble.automatic) {
                    Text("Automatic")
                }.disabled(!ble.canSend)
                
                Button(action: { self.ble.reset() }) {
                    Text("Reset")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }.disabled(ble.automatic || !ble.canSend)
            }
            
            Spacer()
            
            HStack {
                VStack {
                    Text("Top")
                        .font(.headline)
                    Text("Angle: \(Int(ble.servo1Angle))")
                    Slider(value: Binding(get: {
                        self.ble.servo1Angle
                    }, set: { newValue in
                        self.ble.setBySlider(for: 1, value: newValue)
                    }), in: 0.0...100.0, step: 3) {
                        Text("Motor 1")
                    }
                    HStack {
                        Button(action: { self.ble.setByButton(for: 1, value: 0) }) {
                            Text("0°")
                        }
                        Spacer()
                        Button(action: { self.ble.setByButton(for: 1, value: 60) }) {
                            Text("60°")
                        }
                        Spacer()
                        Button(action: { self.ble.setByButton(for: 1, value: 100) }) {
                            Text("100°")
                        }
                    }
                }.disabled(ble.automatic || !ble.canSend)
                
                Spacer(minLength: 100)
                
                VStack {
                    Text("Bottom")
                        .font(.headline)
                    Text("Angle: \(Int(ble.servo2Angle))")
                    Slider(value: Binding(get: {
                        self.ble.servo2Angle
                    }, set: { newValue in
                        self.ble.setBySlider(for: 2, value: newValue)
                    }), in: 0.0...90.0, step: 3) {
                        Text("Motor 2")
                    }
                    HStack {
                        Button(action: { self.ble.setByButton(for: 2, value: 0) }) {
                            Text("0°")
                        }
                        Spacer()
                        Button(action: { self.ble.setByButton(for: 2, value: 60) }) {
                            Text("60°")
                        }
                        Spacer()
                        Button(action: { self.ble.setByButton(for: 2, value: 90) }) {
                            Text("90°")
                        }
                    }
                }.disabled(ble.automatic || !ble.canSend)
            }
            
            Spacer()
        }
        .navigationBarTitle("Bluetooth")
        .padding()
    }
}

struct ActionView_Previews: PreviewProvider {
    static var previews: some View {
        ActionView(ble: BLEManager())
    }
}
