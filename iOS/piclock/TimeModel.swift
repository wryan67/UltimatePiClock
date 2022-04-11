//
//  TimeModel.swift
//  piclock
//
//  Created by wade ryan on 4/10/22.
//

import Foundation

class TimeModel:ObservableObject {
    
    @Published var piTime        = "HH:MM TZ"
    @Published var hostname      = "Unknown"

    @Published var adjustHH      = HourType.hh01
    @Published var adjustMM      = MinuteType.mm01

    @Published var timeMeridiem  = MeridiemType.am
    @Published var timezone      = Timezones.eastern
    @Published var timeFormat    = TimeFormat.hour12

    @Published var statusMessage = "Unknown..."
    
}

