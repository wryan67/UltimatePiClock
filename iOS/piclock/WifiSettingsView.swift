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

    @State private var contentSize: CGSize = .zero

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
                    Section("Networks") {
                        ScrollView {
                            VStack {
                                List(model.networks, id: \.self) { network in
                                    Button(network){print(network)}
                                        .buttonStyle(.plain)
                                        .frame(height:60)
                                }
                            }.frame(height:(60.0*CGFloat(Float(model.networks.count))))
                         
                        }
                            .frame(height:200, alignment: .leading)
                            .padding(0)
                            
                    }
                }
            }
        }
    }
}
