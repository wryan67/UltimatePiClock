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
                            Spacer()
                            Button ("Submit") {
                                print("submit new network credentials..")
                            }   .buttonStyle(.bordered)
                                .foregroundColor(.white)
                        }.frame(alignment: .trailing)
                    }
                    

                    Section("Networks") {
                        VStack {
//                            if model.isScanning {
//                                
//                            }
                            ScrollView {
                                VStack {
                                    List(model.networks, id: \.self) { network in
                                        Button(network){
                                            print("User selected: "+network)
                                            model.newSSID = network
                                        }
                                            .buttonStyle(.plain)
                                            .frame(height:60)
                                    }
                                }   .padding(0)
                                // .frame(height:(60.0*CGFloat(Float(model.networks.count))))
                                    .frame(height:(60.0*CGFloat(
                                        Float(model.networks.count+1)
                                    )))
                             
                            }   .padding(0)
                                .frame(height:(60.0*4))

                            Button("Refresh") {
                                print("refresh netowks....")
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
