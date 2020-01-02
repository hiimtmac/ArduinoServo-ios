//
//  DialView.swift
//  ArduinoServo
//
//  Created by Taylor McIntyre on 2020-01-01.
//  Copyright © 2020 hiimtmac. All rights reserved.
//

import SwiftUI

struct DialView: View {
    @GestureState private var dragOffset = CGSize.zero
    
    var body: some View {
        VStack {
            Text("\(dragOffset.width), \(dragOffset.height)")
            Spacer()
            Circle()
                .stroke(Color.red, lineWidth: 100)
                .frame(width: 200, height: 200)
                .gesture(
                    DragGesture()
                        .updating($dragOffset, body: { (value, state, transaction) in
                            state = value.translation
                        })
            )
        }
    }
}

struct DialView_Previews: PreviewProvider {
    static var previews: some View {
        DialView()
    }
}
