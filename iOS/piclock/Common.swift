//
//  Common.swift
//  piclock
//
//  Created by wade ryan on 4/9/22.
//

import Foundation
import SwiftUI

public enum AppError : Error {
    case dataCharactertisticNotFound
    case enabledCharactertisticNotFound
    case updateCharactertisticNotFound
    case serviceNotFound
    case invalidState
    case resetting
    case poweredOff
    case unauthorized
    case unsupported
    case unknown
    case unlikely
    case tag10
}

public enum Timezones: String, Equatable, CaseIterable {
    case eastern  = "Eastern"
    case central  = "Central"
    case mountain = "Mountain"
    case pacific  = "Pacific"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue)}
}

public enum MeridiemType: String, CaseIterable {
    case am = "am"
    case pm = "pm"

    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue)}
}

public enum TimeFormat: String, CaseIterable {
    case hour24 = "12-Hour"
    case hour12 = "24-Hour"

    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue)}
}

public enum HourType: String, CaseIterable {
    case hh01 = "01"
    case hh02 = "02"
    case hh03 = "03"
    case hh04 = "04"
    case hh05 = "05"
    case hh06 = "06"
    case hh07 = "07"
    case hh08 = "08"
    case hh09 = "09"
    case hh10 = "10"
    case hh11 = "11"
    case hh12 = "12"
//    case hh13 = "13"
//    case hh14 = "14"
//    case hh15 = "15"
//    case hh16 = "16"
//    case hh17 = "17"
//    case hh18 = "18"
//    case hh19 = "19"
//    case hh20 = "20"
//    case hh21 = "21"
//    case hh22 = "22"
//    case hh23 = "23"
    

    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue)}
}
public enum MinuteType: String, CaseIterable {
    case mm01 = "01"
    case mm02 = "02"
    case mm03 = "03"
    case mm04 = "04"
    case mm05 = "05"
    case mm06 = "06"
    case mm07 = "07"
    case mm08 = "08"
    case mm09 = "09"
    case mm10 = "10"
    case mm11 = "11"
    case mm12 = "12"
    case mm13 = "13"
    case mm14 = "14"
    case mm15 = "15"
    case mm16 = "16"
    case mm17 = "17"
    case mm18 = "18"
    case mm19 = "19"
    case mm20 = "20"
    case mm21 = "21"
    case mm22 = "22"
    case mm23 = "23"
    case mm24 = "24"
    case mm25 = "25"
    case mm26 = "26"
    case mm27 = "27"
    case mm28 = "28"
    case mm29 = "29"
    case mm30 = "30"
    case mm31 = "31"
    case mm32 = "32"
    case mm33 = "33"
    case mm34 = "34"
    case mm35 = "35"
    case mm36 = "36"
    case mm37 = "37"
    case mm38 = "38"
    case mm39 = "39"
    case mm40 = "40"
    case mm41 = "41"
    case mm42 = "42"
    case mm43 = "43"
    case mm44 = "44"
    case mm45 = "45"
    case mm46 = "46"
    case mm47 = "47"
    case mm48 = "48"
    case mm49 = "49"
    case mm50 = "50"
    case mm51 = "51"
    case mm52 = "52"
    case mm53 = "53"
    case mm54 = "54"
    case mm55 = "55"
    case mm56 = "56"
    case mm57 = "57"
    case mm58 = "58"
    case mm59 = "59"

    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue)}
}
