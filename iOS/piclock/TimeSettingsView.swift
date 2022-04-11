//
//  TimeSettings.swift
//  piclock
//
//  Created by wade ryan on 4/9/22.
//

import Foundation
import SwiftUI


struct TimeSettingsView: View  {
    @ObservedObject var model:    TimeModel
    var clockService: ClockService
    


    var body: some View {
        VStack {
            Form {
                Section(header: Text("Pi Clock")) {
                    VStack {
                        HStack {
                            Text("Current Time:")
                            Spacer()
                            Text(model.piTime)
                        }
                        HStack {
                            Text("Name:")
                            Spacer()
                            Text(model.hostname)
                        }
                    }
                }
                
                Section(header: Text("Adjust")) {
                    VStack {
                        HStack {
                            HStack (spacing:.zero){
                                Picker("", selection: $model.adjustHH) {
                                        ForEach(HourType.allCases, id: \.self) { value in
                                            Text(value.localizedName)
                                                .tag(value)
                                        }
                                    }   .pickerStyle(.wheel)
                                        .labelsHidden()

                                    Text(":")//.frame(width: 10,  height:60, alignment: .center)

                                Picker(selection: $model.adjustMM, label: Text("")) {
                                            ForEach(MinuteType.allCases, id: \.self) { value in
                                                Text(value.localizedName)
                                                    .tag(value)
                                            }
                                        }   .pickerStyle(.wheel)
                                            .labelsHidden()
                                }.frame(height:60)
                                 .clipped()

                            Spacer().frame(width:50)
                            Picker("Meridiem", selection: $model.timeMeridiem) {
                                ForEach(MeridiemType.allCases, id: \.self) { value in
                                    Text(value.localizedName)
                                        .tag(value)
                                }
                            }.pickerStyle(.segmented)
                        }
                        
                        HStack {
                            Spacer()
                            Button("Adjust") { clockService.adjustTime() }
                                .buttonStyle(.borderedProminent)
                            Spacer()
                        }
                        HStack {
                            Text("Note:  Manually adjusting the time will disable automatic time updates")
                                .foregroundColor(.blue)
                                .fontWeight(Font.Weight.thin)
                        }
                    }
                }

                
                Section(header: Text("Timezone")) {
                    HStack {
                        Picker("Timezone", selection: $model.timezone) {
                            ForEach(Timezones.allCases, id: \.self) { value in
                                Text(value.localizedName).tag(value)
                            }
                        }.pickerStyle(.segmented)
                            .onChange(of: model.timezone, perform: {(value) in clockService.modifyTimezone()})

                    }
                }
                
                Section(header: Text("Time Format")) {
                    HStack {
                        Picker("Time Format", selection: $model.timeFormat) {
                            ForEach(TimeFormat.allCases, id: \.self) { value in
                                Text(value.localizedName).tag(value)
                            }
                        }.pickerStyle(.segmented)
                            .onChange(of: model.timeFormat, perform: {(value) in clockService.modifyTimeFormat()})
                    }
                }
                
           } .navigationTitle("Timezone Tab")
        }

    }
}
