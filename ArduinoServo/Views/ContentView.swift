//
//  ContentView.swift
//  ArduinoServo
//
//  Created by Taylor McIntyre on 2019-12-21.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var tag = 0
    @State var ble = BLEManager()
    
    var body: some View {
        TabView(selection: $tag) {
            NavigationView {
                ActionView(ble: ble)
            }
            .tag(0)
            .tabItem {
                VStack {
                    Image(systemName: "cloud")
                    Text("Actions")
                }
            }
            NavigationView {
                PeripheralView(ble: ble)
            }
            .tag(1)
            .tabItem {
                VStack {
                    Image(systemName: "gear")
                    Text("Settings")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
