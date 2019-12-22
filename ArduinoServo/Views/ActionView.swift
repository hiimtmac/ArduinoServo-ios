//
//  ActionView.swift
//  ArduinoServo
//
//  Created by Taylor McIntyre on 2019-12-21.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import SwiftUI

struct ActionView: View {
    @State var text = "hello"
    @ObservedObject var ble: BLEManager
    
    var body: some View {
        VStack {
            TextField("Type Here", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button(action: { self.ble.writeValue(message: self.text) }) {
                Text("Send")
            }.disabled(text.isEmpty || !ble.canSend)
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
