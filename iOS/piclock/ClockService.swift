//
//  ClockService.swift
//  piclock
//
//  Created by wade ryan on 4/4/22.
//

import Foundation
import CoreBluetooth
import BlueCapKit

public class ClockService {
    var timeModel: TimeModel?
    var wifiModel: WifiModel?
    
    let manager = CentralManager()
    var peripheral: Peripheral?

    var tempCharacteristic : Characteristic?
    var unitCharacteristic : Characteristic?
    var timeCharacteristic : Characteristic?
    var formatCharacteristic : Characteristic?
    var timezoneCharacteristic : Characteristic?
    var hh24Characteristic : Characteristic?
    var timeUpdateCharacteristic : Characteristic?
    var wifiUpdateCharacteristic : Characteristic?
    var wifiListCharacteristic : Characteristic?

    var units = TemperatureUnitType.celsius
    



    public static let uuid = "00000001-9233-face-8d75-3e5b444bc3cf"
    public static let name = "PiClock"
    
    public static let tempCharacteristicUUID = "00000002-9233-face-8d75-3e5b444bc3cf"
    public static let unitCharacteristicUUID = "00000003-9233-face-8d75-3e5b444bc3cf"
    public static let timeCharacteristicUUID = "00000004-9233-face-8d75-3e5b444bc3cf"
    public static let formatCharacteristicUUID = "00000005-9233-face-8d75-3e5b444bc3cf"
    public static let timezoneCharacteristicUUID = "00000006-9233-face-8d75-3e5b444bc3cf"
    public static let hh24CharacteristicUUID = "00000007-9233-face-8d75-3e5b444bc3cf"
    public static let timeUpdateCharacteristicUUID = "00000008-9233-face-8d75-3e5b444bc3cf"
    public static let wifiUpdateCharacteristicUUID = "00000009-9233-face-8d75-3e5b444bc3cf"
    public static let wifiListCharacteristicUUID = "00000010-9233-face-8d75-3e5b444bc3cf"

    public static let serviceCBUUID = CBUUID(string:uuid)
    public static let tempCharacteristicCBUUID = CBUUID(string:tempCharacteristicUUID)
    public static let unitCharacteristicCBUUID = CBUUID(string:unitCharacteristicUUID)
    public static let timeCharacteristicCBUUID = CBUUID(string:timeCharacteristicUUID)
    public static let formatCharacteristicCBUUID = CBUUID(string:formatCharacteristicUUID)
    public static let timezoneCharacteristicCBUUID = CBUUID(string:timezoneCharacteristicUUID)
    public static let hh24CharacteristicCBUUID = CBUUID(string:hh24CharacteristicUUID)
    public static let timeUpdateCharacteristicCBUUID = CBUUID(string:timeUpdateCharacteristicUUID)
    public static let wifiUpdateCharacteristicCBUUID = CBUUID(string:wifiUpdateCharacteristicUUID)
    public static let wifiListCharacteristicCBUUID = CBUUID(string:wifiListCharacteristicUUID)

    
    public static let characteristics = [
        timeCharacteristicCBUUID,
        tempCharacteristicCBUUID,
        unitCharacteristicCBUUID,
        formatCharacteristicCBUUID,
        timezoneCharacteristicCBUUID,
        hh24CharacteristicCBUUID,
        timeUpdateCharacteristicCBUUID,
        wifiUpdateCharacteristicCBUUID,
        wifiListCharacteristicCBUUID
    ]
    
    
    func message(msg: String) {
        print(msg)
    }

    var lastTime = ""
    func messageTime(msg: String) {
        if (msg != lastTime) {
            print(msg)
            lastTime=msg
            timeModel?.piTime = msg
        }
    }
    
    func adjustTime() {
        print("adjust time...")
        
        let hh24 = Int(timeModel?.adjustHH.rawValue ?? "0") ?? 0
        let mm   = Int(timeModel?.adjustMM.rawValue ?? "0") ?? 0
        var hh   = hh24
        
        if (timeModel?.timeMeridiem == MeridiemType.pm) {
            hh = hh24 + 12
            if (hh>23) {
                hh=0
            }
        }
        
        
        //read a value from the characteristic
        let newTime = String(format: "%02d:%02d", hh, mm)

        print("adjusting newTime=\(newTime)")
        
        if (peripheral != nil) {
            print("updte time characteristic: "+newTime)

            let writeFuture = self.timeUpdateCharacteristic?.write(data:newTime.data(using: .ascii)!)

            writeFuture?.onSuccess(completion: { (_) in
                self.readTimezone()
            })
        }
    }



    func modifyTimezone() {
        print("user clicked timezone: \(timeModel!.timezone.rawValue)")
        var tz: String
        
        switch (timeModel!.timezone) {
        case .eastern:  tz = "America/New_York"
        case .central:  tz = "America/Chicago"
        case .mountain: tz = "America/Denver"
        case .pacific:  tz = "America/Los_Angeles"
        }
        
        if (peripheral != nil) {
            print("modifying timezone characteristic: "+tz)

            let writeFuture = self.timezoneCharacteristic?.write(data:tz.data(using: .ascii)!)

            writeFuture?.onSuccess(completion: { (_) in
                self.readTimezone()
            })
            
        }
    }
    
    func modifyTimeFormat() {
        print("user clicked time format: \(timeModel!.timeFormat.rawValue)")
        var format: String

        if (timeModel!.timeFormat==TimeFormat.hour12) {
            format="2"
        } else {
            format="1"
        }

        
        if (peripheral != nil) {
            print("modifying format characteristic: "+format)
                       
            let writeFuture = self.formatCharacteristic?.write(data:format.data(using: .ascii)!)

            writeFuture?.onSuccess(completion: { (_) in
                self.readTime()
            })
            
        }
    }
    
    
    func readTime(){
        //read a value from the characteristic
        let readFuture = self.timeCharacteristic?.read(timeout: 5)
        readFuture?.onSuccess { (_) in
            //the value is in the dataValue property
            
            let s = String(data:(self.timeCharacteristic?.dataValue)!, encoding: .utf8) ?? "unknown"
            
            DispatchQueue.main.async {
                self.messageTime(msg: s)
            }
        }
        readFuture?.onFailure { (_) in
            self.message(msg: "read error")
        }
    }

    func readFormat(){
        if (peripheral != nil) {
            guard let discoveredPeripheral = peripheral else {
                print("e602: unknown error")
                return
            }
            guard let dataCharacteristic = discoveredPeripheral.services(withUUID:ClockService.serviceCBUUID)?.first?.characteristics(withUUID:ClockService.formatCharacteristicCBUUID)?.first else {
                print("e605 format characteristic not found")
                return
            }
            formatCharacteristic = dataCharacteristic
        }
        
        
        //read a value from the characteristic
        let readFuture = self.formatCharacteristic?.read(timeout: 5)
        readFuture?.onSuccess { (_) in
            //the value is in the dataValue property
            
            let s = String(data:(self.formatCharacteristic?.dataValue)!, encoding: .ascii) ?? "unknown"
            
            DispatchQueue.main.async {
                print("current time format="+s)
                if (s=="1") {
                    self.timeModel!.timeFormat = TimeFormat.hour24
                } else {
                    self.timeModel!.timeFormat = TimeFormat.hour12
                }
            }
        }
    }

    func readTimezone(){
        if (peripheral != nil) {
            guard let discoveredPeripheral = peripheral else {
                print("e602: unknown error")
                return
            }
            guard let dataCharacteristic = discoveredPeripheral.services(withUUID:ClockService.serviceCBUUID)?.first?.characteristics(withUUID:ClockService.timezoneCharacteristicCBUUID)?.first else {
                print("e605 timezone characteristic not found")
                return
            }
            timezoneCharacteristic = dataCharacteristic
        }
        
        
        //read a value from the characteristic
        let readFuture = self.timezoneCharacteristic?.read(timeout: 5)
        readFuture?.onSuccess { (_) in
            //the value is in the dataValue property
            
            let s = String(data:(self.timezoneCharacteristic?.dataValue)!, encoding: .ascii) ?? "unknown"
            
            print("current timezone="+s)

            DispatchQueue.main.async {
                switch (s) {
                case "America/New_York":    self.timeModel!.timezone=Timezones.eastern
                case "America/Chicago":     self.timeModel!.timezone=Timezones.central
                case "America/Denver":      self.timeModel!.timezone=Timezones.mountain
                case "America/Los_Angeles": self.timeModel!.timezone=Timezones.pacific
                default: self.timeModel!.timezone=Timezones.eastern
                }
            }
        }
    }
    func readHH24Update(){
        if (peripheral != nil) {
            guard let discoveredPeripheral = peripheral else {
                print("e602: unknown error")
                return
            }
            guard let dataCharacteristic = discoveredPeripheral.services(withUUID:ClockService.serviceCBUUID)?.first?.characteristics(withUUID:ClockService.timeUpdateCharacteristicCBUUID)?.first else {
                print("e605 hh24 characteristic not found")
                return
            }
            timeUpdateCharacteristic = dataCharacteristic
        }
    }

    func readHH24Init(){
        readHH24Update()
        //read a value from the characteristic
        let readFuture = self.timeUpdateCharacteristic?.read(timeout: 5)
        readFuture?.onSuccess { (_) in
            //the value is in the dataValue property
            
            let s = String(data:(self.timeUpdateCharacteristic?.dataValue)!, encoding: .ascii) ?? "unknown"
            
            print("timeUpdate="+s)

            let parts = s.components(separatedBy: ":")
            
            print("timeUpdate parts[0]=\(parts[0])")
            print("timeUpdate parts[1]=\(parts[1])")

            var hh24=Int(parts[0]) ?? -1
            let mm=Int(parts[1]) ?? -1

            print("timeUpdate tt=\(hh24):\(mm)")
            
            if (hh24>12) {
                hh24-=12
                self.timeModel!.timeMeridiem = MeridiemType.pm
            }
            
            
            self.timeModel!.adjustHH = HourType(rawValue: String(format:"%02d",hh24)) ?? HourType.hh01
            self.timeModel!.adjustMM = MinuteType(rawValue: parts[1]) ?? MinuteType.mm01
        }
    }

    
    func getWifiUpdateCharacteristic(){
        if (peripheral != nil) {
            guard let discoveredPeripheral = peripheral else {
                print("e602: unknown error")
                return
            }
            guard let dataCharacteristic = discoveredPeripheral.services(withUUID:ClockService.serviceCBUUID)?.first?.characteristics(withUUID:ClockService.wifiUpdateCharacteristicCBUUID)?.first else {
                print("e605 hh24 characteristic not found")
                return
            }
            wifiUpdateCharacteristic = dataCharacteristic
        }
    }
    func getWifiListCharacteristic(){
        if (peripheral != nil) {
            guard let discoveredPeripheral = peripheral else {
                print("e602: unknown error")
                return
            }
            guard let dataCharacteristic = discoveredPeripheral.services(withUUID:ClockService.serviceCBUUID)?.first?.characteristics(withUUID:ClockService.wifiListCharacteristicCBUUID)?.first else {
                print("e605 hh24 characteristic not found")
                return
            }
            wifiListCharacteristic = dataCharacteristic
        }
    }

    
    func readWifiSSID(){
        
        getWifiUpdateCharacteristic()
        //read a value from the characteristic
        let readFuture = self.wifiUpdateCharacteristic?.read(timeout: 5)
        readFuture?.onSuccess { (_) in
            //the value is in the dataValue property
            
            let s = String(data:(self.wifiUpdateCharacteristic?.dataValue)!, encoding: .ascii) ?? "unknown"
            
            print("wifiUpdate="+s)


            self.wifiModel!.ssid = s
            
        }
    }

    func readWifiListFuture(readFuture: Future<Void>) {


            
        readFuture.onSuccess { (_) in
            let s = String(data:(self.wifiListCharacteristic?.dataValue)!, encoding: .ascii) ?? "unknown"

            print("wifiList: "+s)

            if (s == "###end-transmission###") {
                print("read list terminated")
                self.wifiModel?.isScanning = false;
                self.wifiModel?.networks.removeFirst()
            
                return
            } else {
                self.wifiModel?.networks.append(s)
                let readFuture = self.wifiListCharacteristic?.read(timeout: 20)
                self.readWifiListFuture(readFuture: readFuture!)
            }
        }

        
    }
    
    
    func readWifiList() {
        self.wifiModel?.isScanning = true;
        self.wifiModel?.networks.removeAll()
        self.wifiModel?.networks.append(String("Scanning..."))

        getWifiListCharacteristic()
        print("reading wifi list")
        let format = "scan"

        if (peripheral != nil) {
            print("wifi list characteristic: "+format)

            let writeFuture = self.wifiListCharacteristic?.write(data:format.data(using: .ascii)!, timeout: 30)

            writeFuture?.onSuccess(completion: { (_) in
                print("reading wifi list...")
                let readFuture = self.wifiListCharacteristic?.read(timeout: 20)
                self.readWifiListFuture(readFuture: readFuture!)                
            })
            
        }


    }
    
    

    
    
    func activate(timeModel: TimeModel, wifiModel: WifiModel) {
        self.timeModel=timeModel
        self.wifiModel=wifiModel
        
        message(msg: "Activating...")
        

        
        let stateChangeFuture = manager.whenStateChanges()
        print("tag10...")

        let scanFuture = stateChangeFuture.flatMap {
            state -> FutureStream<Peripheral> in switch state {
                case .poweredOn:
                    DispatchQueue.main.async {
                        self.message(msg:"Scanning<\(ClockService.serviceCBUUID.uuidString)>...")
                    }
                    //scan for peripherlas that advertise the ec00 service
                return self.manager.startScanning(forServiceUUIDs: [ClockService.serviceCBUUID], capacity: 10)
                case .poweredOff:
                    print("powered off")
                    throw AppError.poweredOff
                case .unauthorized:
                    print("unauthorized")
                    throw AppError.unauthorized
                case .unsupported:
                    print("unsupported")
                    throw AppError.unsupported
                case .resetting:
                    print("resetting")
                    throw AppError.resetting
                case .unknown:
                    print("state is unknown")
                    //generally this state is ignored
                    throw AppError.unknown
            }
        }
        
        print("tag20...")
        scanFuture.onFailure { error in
            guard let appError = error as? AppError else {
                return
            }
            switch appError {
            case .invalidState:
                print("e201: invalid state")
                break
            case .resetting:
                print("e202: resetting")
                self.manager.reset()
            case .poweredOff:
                print("e203: powered off")
                break
            case .unknown:
                print("e204: unknown")
                break
            default:
                break;
            }
        }
        
        
        print("tag30...")
        
        //We will connect to the first scanned peripheral
        let connectionFuture = scanFuture.flatMap { p -> FutureStream<Void> in
            //stop the scan as soon as we find the first peripheral
            self.manager.stopScanning()
            self.peripheral = p
            guard let peripheral = self.peripheral else {
                throw AppError.unknown
            }
            DispatchQueue.main.async {
                self.message(msg: "Found peripheral \(peripheral.name)\nwith \(peripheral.services.count) services\nconnecting...")
                timeModel.hostname = peripheral.name
            }
            //connect to the peripheral in order to trigger the connected mode
            return peripheral.connect(connectionTimeout: 20, capacity: 5)
//            return peripheral.connect(connectionTimeout: 20)
        }
        
        
        print("tag40...")
        let discoveryFuture = connectionFuture.flatMap { _ -> Future<Void> in
            guard let peripheral = self.peripheral else {
                print("e401: unknown error")
                throw AppError.unknown
            }
            return peripheral.discoverServices([ClockService.serviceCBUUID])
        }
            
        let temp = discoveryFuture.flatMap { _ -> Future<Void> in
            guard let discoveredPeripheral = self.peripheral else {
                print("e402: unknown error")
                throw AppError.unknown
            }
            guard let service = discoveredPeripheral.services(withUUID:ClockService.serviceCBUUID)?.first else {
                print("e403: servcie not found")
                throw AppError.serviceNotFound
            }
            self.peripheral = discoveredPeripheral
            DispatchQueue.main.async {
                self.message(msg: "Discovered service \(service.uuid.uuidString). Trying to discover chracteristics")
            }
            //we have discovered the service, the next step is to discover the "ec0e" characteristic
            return service.discoverCharacteristics(ClockService.characteristics)
        }
        
        
        
        print("tag50...")
        /**
         1- checks if the characteristic is correctly discovered
         2- Register for notifications using the dataFuture variable
        */
        let dataFuture = temp.flatMap { _ -> Future<Void> in
            guard let discoveredPeripheral = self.peripheral else {
                throw AppError.unknown
            }
            guard let dataCharacteristic = discoveredPeripheral.services(withUUID:ClockService.serviceCBUUID)?.first?.characteristics(withUUID:ClockService.timeCharacteristicCBUUID)?.first else {
                throw AppError.dataCharactertisticNotFound
            }
            self.timeCharacteristic = dataCharacteristic
            DispatchQueue.main.async {
                self.message(msg: "Discovered characteristic \(dataCharacteristic.uuid.uuidString)")
            }
            //when we successfully discover the characteristic, we can show the characteritic view
//            DispatchQueue.main.async {
//                self.loadingView.isHidden = true
//                self.characteristicView.isHidden = false
//            }
            //read the data from the characteristic
            self.readTimezone()
            self.readFormat()
            self.readTime()
            self.readHH24Init()
            self.readWifiSSID()
            self.readWifiList()
            
            //Ask the characteristic to start notifying for value change
            return dataCharacteristic.startNotifying()
            }.flatMap { _ -> FutureStream<Data?> in
                guard let discoveredPeripheral = self.peripheral else {
                    throw AppError.unknown
                }
                guard let characteristic = discoveredPeripheral.services(withUUID:ClockService.serviceCBUUID)?.first?.characteristics(withUUID:ClockService.timeCharacteristicCBUUID)?.first else {
                    throw AppError.dataCharactertisticNotFound
                }
                //regeister to recieve a notifcation when the value of the characteristic changes and return a future that handles these notifications
                return characteristic.receiveNotificationUpdates(capacity: 10)
        }
        
        //The onSuccess method is called every time the characteristic value changes
        dataFuture.onSuccess { data in
//            let s = String(data:data!, encoding: .utf8)
            let s = String(data:data!, encoding: .utf8) ?? "unknown"
            
            DispatchQueue.main.async {
                self.messageTime(msg: s)
            }
        }

    }


    
}
