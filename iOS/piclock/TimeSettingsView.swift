//
//  TimeSettings.swift
//  piclock
//
//  Created by wade ryan on 4/9/22.
//

import Foundation
import SwiftUI


struct TimeSettingsView: View  {
    @ObservedObject var timeModel:    TimeModel
    var clockService: ClockService
    


    var body: some View {
        VStack {
            Form {
                Section(header: Text("Pi Clock")) {
                    HStack {
                        Text("Current Time:")
                        Spacer()
                        Text(timeModel.piTime)
                    }
                }
                
                Section(header: Text("Adjust")) {
                    VStack {
                        HStack {
                            HStack (spacing:.zero){
                                Picker("", selection: $timeModel.adjustHH) {
                                        ForEach(HourType.allCases, id: \.self) { value in
                                            Text(value.localizedName)
                                                .tag(value)
                                        }
                                    }   .pickerStyle(.wheel)
                                        .labelsHidden()

                                    Text(":")//.frame(width: 10,  height:60, alignment: .center)

                                Picker(selection: $timeModel.adjustMM, label: Text("")) {
                                            ForEach(MinuteType.allCases, id: \.self) { value in
                                                Text(value.localizedName)
                                                    .tag(value)
                                            }
                                        }   .pickerStyle(.wheel)
                                            .labelsHidden()
                                }.frame(height:60)
                                 .clipped()

                            Spacer().frame(width:50)
                            Picker("Meridiem", selection: $timeModel.timeMeridiem) {
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
                    }
                }

                
                Section(header: Text("Timezone")) {
                    HStack {
                        Picker("Timezone", selection: $timeModel.timezone) {
                            ForEach(Timezones.allCases, id: \.self) { value in
                                Text(value.localizedName).tag(value)
                            }
                        }.pickerStyle(.segmented)
                            .onChange(of: timezone, perform: {(value) in clockService.modifyTimezone()})

                    }
                }
                
                Section(header: Text("Time Format")) {
                    HStack {
                        Picker("Time Format", selection: $timeModel.timeFormat) {
                            ForEach(TimeFormat.allCases, id: \.self) { value in
                                Text(value.localizedName).tag(value)
                            }
                        }.pickerStyle(.segmented)
                            .onChange(of: timeModel.timeFormat, perform: {(value) in clockService.modifyTimeFormat()})
                    }
                }
                
           } .navigationTitle("Timezone Tab")
        }

    }
}
