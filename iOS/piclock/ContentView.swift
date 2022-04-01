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

public enum ImageSizeType: String, CaseIterable {
    case large  = "Large"
    case medium = "Medium"
    case small  = "Small"
}


struct ContentView: View {
    @State private var selectedTab = "One"

    @State private var timezone: Timezones = Timezones.central
    @State private var profileImageSize: ImageSizeType = ImageSizeType.medium
    
    @State private var hh: String=""
    @State private var mm: String=""
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            GroupBox() {
                VStack {
                    
                    Form {
                        Section(header: Text("time")) {
                            HStack {
                                Text("Hour")
                                TextField("Hour", text: $hh, prompt: Text("HH"))
                                    .multilineTextAlignment(.trailing)
                                
                                TextField("Minute", text: $mm, prompt: Text("MM"))
                                    .fixedSize()
                                    .multilineTextAlignment(.trailing)
                            }
                        }
    
                        Section(header: Text("Timezone")) {
                            Picker("Timezone", selection: $timezone) {
                                ForEach(Timezones.allCases, id: \.self) { value in
                                    Text(value.localizedName).tag(value).padding()
                                }
                            }   .pickerStyle(.wheel)
                                .padding(.leading, 78.0)
                                .frame(width: 200.0, height: 50)
                        }.alignmentGuide(.trailing) { d in d[.trailing] }
                       
                        Button("Submit") {}
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
