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
    @State private var selectedTab   = "One"

    
    let clockService = ClockService()

    var body: some View {
        TabView(selection: $selectedTab) {
            
            GroupBox() {
                TimeSettingsView(timeModel: clockService.timeModel, clockService: clockService)
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


        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.portraitUpsideDown)
    }
}

