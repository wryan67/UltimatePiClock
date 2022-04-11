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
    @ObservedObject var model:    WifiModel
    var clockService: ClockService


    var body: some View {
        GeometryReader { geometry in
            HStack {
                Form {
                    Section("WI-FI") {
                        HStack {
                            Text("Current:")
                            Spacer()
                            Text(model.ssid)
                        }
                    }
                }
            }
        }
    }
}
