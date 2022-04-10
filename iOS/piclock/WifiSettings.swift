//
//  TimeSettings.swift
//  piclock
//
//  Created by wade ryan on 4/9/22.
//

import Foundation
import SwiftUI
import CoreBluetooth
import BlueCapKit

struct WifiSettings: View  {

    @State var ssid: String

    var body: some View {
        GeometryReader { geometry in
            HStack {
                Text("Wifi Settings")
                Text(ssid)
            }
        }
    }
}
