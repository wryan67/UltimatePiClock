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

    @StateObject var timeModel     = TimeModel()
    @StateObject var wifiModel     = WifiModel()
    var clockService               = ClockService()

    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            GroupBox() {
                TimeSettingsView(model: timeModel, clockService: clockService)
            }.tabItem {
                    Label("Time", systemImage: "clock")
            }.tag("One")

            GroupBox() {
                VStack {
                    WifiSettings(model: wifiModel, clockService: clockService)
                }
            }.tabItem {
                    Label("Wifi", systemImage: "network")
            }.tag("One")


            GroupBox() {
                VStack {
                    Image("under-construction")
                        .resizable()
                        .scaledToFit()
                }
            }.tabItem {
                    Label("Photos", systemImage: "photo")
            }.tag("One")


        }.onAppear(){ clockService.activate(timeModel:timeModel, wifiModel:wifiModel)}
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.portraitUpsideDown)
    }
}

