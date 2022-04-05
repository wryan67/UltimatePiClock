//
//  ClockService.swift
//  piclock
//
//  Created by wade ryan on 4/4/22.
//

import Foundation
import CoreBluetooth

public struct ClockService {
    public static let uuid = "00000001-9233-face-8d75-3e5b444bc3cf"
    public static let name = "PiClock"
    
    public static let tempCharacteristicUUID = "00000002-9233-face-8d75-3e5b444bc3cf"
    public static let unitCharacteristicUUID = "00000003-9233-face-8d75-3e5b444bc3cf"
    public static let timeCharacteristicUUID = "00000004-9233-face-8d75-3e5b444bc3cf"
    public static let formatCharacteristicUUID = "00000005-9233-face-8d75-3e5b444bc3cf"
    public static let timezoneCharacteristicUUID = "00000006-9233-face-8d75-3e5b444bc3cf"
   
    public static let serviceCBUUID = CBUUID(string:uuid)
    public static let tempCharacteristicCBUUID = CBUUID(string:tempCharacteristicUUID)
    public static let unitCharacteristicCBUUID = CBUUID(string:unitCharacteristicUUID)
    public static let timeCharacteristicCBUUID = CBUUID(string:timeCharacteristicUUID)
    public static let formatCharacteristicCBUUID = CBUUID(string:formatCharacteristicUUID)
    public static let timezoneCharacteristicCBUUID = CBUUID(string:timezoneCharacteristicUUID)

    
    public static let characteristics = [
        timeCharacteristicCBUUID,
        tempCharacteristicCBUUID,
        unitCharacteristicCBUUID,
        formatCharacteristicCBUUID,
        timezoneCharacteristicCBUUID
    ]
    
}
