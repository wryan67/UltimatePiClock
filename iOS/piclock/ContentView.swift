//
//  ContentView.swift
//  piclock
//
//  Created by wade ryan on 3/30/22.
//

import SwiftUI
import CoreBluetooth
import BlueCapKit


extension UIPickerView {
  open override var intrinsicContentSize: CGSize {
      return CGSize(width: UIView.noIntrinsicMetric, height: super.intrinsicContentSize.height)
  }
}

struct ContentView: View {
    @State       var selectedTab   = "One"

    @StateObject var model         = TimeModel()
    var clockService               = ClockService()

    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            GroupBox() {
                TimeSettingsView(timeModel: model, clockService: clockService)
            }.tabItem {
                    Label("Time", systemImage: "clock")
            }.tag("One")

            GroupBox() {
                VStack {
                    WifiSettings(ssid: "monkey")
                }
            }.tabItem {
                    Label("Wifi", systemImage: "network")
            }.tag("One")


            GroupBox() {
                VStack {
                    Text("tab 3")
                }
            }.tabItem {
                    Label("Photos", systemImage: "photo")
            }.tag("One")


        }.onAppear(){ clockService.activate(timeModel:model)}
    }
}


//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(model)
//            .previewInterfaceOrientation(.portraitUpsideDown)
//    }
//}

