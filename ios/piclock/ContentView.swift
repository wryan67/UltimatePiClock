//
//  ContentView.swift
//  piclock
//
//  Created by wade ryan on 3/30/22.
//

import SwiftUI

public enum Timezones: String, Equatable, CaseIterable {
    case eastern  = "Eastern"
    case central  = "Central"
    case mountain = "Mountain"
    case pacific  = "Pacific"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue)}
}

public enum TimeType: String, CaseIterable {
    case hour   = "HH"
    case minute = "MM"

    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue)}
}

public enum TimeFormat: String, CaseIterable {
    case hour12 = "24-Hour"
    case hour24 = "12-Hour"

    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue)}
}


struct ContentView: View {
    @State private var selectedTab = "One"

    @State private var timezone: Timezones = Timezones.central
    
    @State private var piTime: String="HH:MM TZ"
    @State private var timeControl: TimeType = TimeType.minute
    @State private var timeFormat: TimeFormat = TimeFormat.hour12
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            GroupBox() {
                VStack {
                    
                    Form {
                        Section(header: Text("Pi Clock")) {
                            HStack {
                                Text("Current Time:")
                                Spacer()
                                Text(piTime)
                            }
                            
                        }
                        
                        Section(header: Text("Adjust")) {
                            HStack {
                                Picker("Adjust", selection: $timeControl) {
                                    ForEach(TimeType.allCases, id: \.self) { value in
                                        Text(value.localizedName)
                                            .tag(value)
                                    }
                                }.pickerStyle(.segmented)
                                Spacer().frame(width:50)
                                Button("+") {}.frame(width: 50).buttonStyle(.bordered)
                                Button("-") {}.frame(width: 50).buttonStyle(.bordered)
                            }
                            
                        }

                        
                        Section(header: Text("Timezone")) {
                            HStack {
                                Picker("Timezone", selection: $timezone) {
                                    ForEach(Timezones.allCases, id: \.self) { value in
                                        Text(value.localizedName).tag(value)
                                    }
                                }.pickerStyle(.segmented)
                            }
                        }
                        
                        Section(header: Text("Time Format")) {
                            HStack {
                                Picker("Time Format", selection: $timeFormat) {
                                    ForEach(TimeFormat.allCases, id: \.self) { value in
                                        Text(value.localizedName).tag(value)
                                    }
                                }.pickerStyle(.segmented)
                            }
                        }
                        
                   } .navigationTitle("Timezone Tab")
                }
            }.tabItem {
                    Label("Time", systemImage: "clock")
            }.tag("One")

            GroupBox() {
                VStack {
                    Text("tab 2")
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
    }}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.portraitUpsideDown)
    }
}

