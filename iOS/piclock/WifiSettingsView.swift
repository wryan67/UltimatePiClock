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
    @State private var showPasswd = false
    
    let networkHeight = 50.0

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
                        HStack {
                            Text("New network:")
                            Spacer()
                            TextField("SSID", text: $model.newSSID)
                        }
                        HStack {
                            Text("password:")
                            Spacer()
                            if showPasswd {
                                TextField("Password", text: $model.passwd)
                                    .autocapitalization(.none)
                            } else {
                                SecureField("Password", text: $model.passwd)
                            }
                            Button(action: {
                                showPasswd.toggle()
                            }, label: {
                                Image(systemName: !showPasswd ? "eye.slash" : "eye" )
                            }).foregroundColor( !showPasswd ? .gray : .white)
                        }
                        HStack {
                            HStack(spacing:0) {
                                Text("Time: auto\nupdate")
                                    .multilineTextAlignment(.trailing)
                                Spacer().frame(width:5)
                                Toggle("", isOn: $model.autoTimeUpdate)
                                    .padding(0)
                                    .labelsHidden()
                                    .onChange(of: model.autoTimeUpdate) { value in
                                        print("set auto-time-update: ", value)
                                        clockService.updateAutoTimeCharacteristic()
                                    }
                                    
                            }
                            Spacer()
                            Button ("Submit") {
                                clockService.updateWifiSSID();
                            }   .buttonStyle(.bordered)
                                .foregroundColor(.white)
                                .disabled(model.isUpdatingWifi)

                        }.frame(alignment: .trailing)
                    }
                    

                    Section("Networks") {
                        VStack {
                            ScrollView {
                                VStack(spacing:0) {
                                    ForEach(Array(model.networks.enumerated()), id: \.offset) { index, network in
                                        
                                        if (index==0) {
                                            Text("first").hidden()
                                        } else {
                                            Text("-")
                                                .frame(minWidth:geometry.size.width * 0.60, maxHeight:1)
                                                .clipped()
                                                .border(Color.gray)
                                        }


                                        VStack(spacing:0) {
                                            Button(network) {
                                                print("User selected: "+network)
                                                model.newSSID = network
                                            }
                                                .buttonStyle(.plain)
                                                .frame(height:networkHeight)

                                        }
                                    }

                                }   .padding(0)
                                    .frame(maxWidth: .infinity)
                             
                            }   .padding(0)
                                .frame(height:(networkHeight*4.02))


                            Button("Refresh") {
                                print("refresh netowks....")
                                clockService.readWifiSSID()
                                clockService.readWifiList()
                            }   .buttonStyle(.bordered)
                                .padding(.top, 5.0)
                                .foregroundColor(.white)
                                .disabled(model.isScanning)
                        }
                    }
                }
            }
        }
    }
}


struct WifiSettings_Previews: PreviewProvider {
    static let clockService = ClockService()
    static let model: WifiModel = {
        let model = WifiModel()
        model.networks.append("tatooine")
        model.networks.append("dantooine")
        model.networks.append("yavin4")
        model.networks.append("naboo")
        model.networks.append("gonosis")
        return model
    }()
    
    static var previews: some View {

        WifiSettings(model: model, clockService: clockService)
            .previewInterfaceOrientation(.portraitUpsideDown)
    }
}
