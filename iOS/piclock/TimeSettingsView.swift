//
//  TimeSettings.swift
//  piclock
//
//  Created by wade ryan on 4/9/22.
//

import Foundation
import SwiftUI
import CoreBluetooth
import BlueCapKit

struct TimeModel {
    var piTime        = Text("HH:MM TZ")

    var adjustHH      = HourType.hh01
    var adjustMM      = MinuteType.mm01

    var timeMeridiem  = MeridiemType.am
    var timezone      = Timezones.eastern
    var timeFormat    = TimeFormat.hour12

    var statusMessage = Text("Scanning...")
}

struct TimeSettingsView: View  {
    @State var timeModel:    TimeModel
    let clockService: ClockService
    
    
    let manager = CentralManager()
    @State var peripheral: Peripheral?



    @State var tempCharacteristic : Characteristic?
    @State var unitCharacteristic : Characteristic?
    @State var timeCharacteristic : Characteristic?
    @State var formatCharacteristic : Characteristic?
    @State var timezoneCharacteristic : Characteristic?
    @State var hh24Characteristic : Characteristic?
    @State var timeUpdateCharacteristic : Characteristic?

    @State var hostname = Text("Hostname: unknown")
    @State var units = TemperatureUnitType.celsius
    



    var body: some View {
        VStack {
            Form {
                Section(header: Text("Pi Clock")) {
                    HStack {
                        Text("Current Time:")
                        Spacer()
                        timeModel.piTime
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
                            Button("Adjust") { adjustTime() }
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
                            .onChange(of: timezone, perform: {(value) in modifyTimezone()})

                    }
                }
                
                Section(header: Text("Time Format")) {
                    HStack {
                        Picker("Time Format", selection: $timeModel.timeFormat) {
                            ForEach(TimeFormat.allCases, id: \.self) { value in
                                Text(value.localizedName).tag(value)
                            }
                        }.pickerStyle(.segmented)
                            .onChange(of: timeModel.timeFormat, perform: {(value) in modifyTimeFormat()})
                    }
                }
                
           } .navigationTitle("Timezone Tab")
        }.onAppear(perform: activate)

    }
    
    func message(msg: String) {
        print(msg)
    }

    @State var lastTime = ""
    func messageTime(msg: String) {
        if (msg != lastTime) {
            print(msg)
            lastTime=msg
        }
        timeModel.piTime = Text(msg)
    }
    
    func adjustTime() {
        print("adjust time...")
        
        let hh24 = Int(timeModel.adjustHH.rawValue) ?? 0
        let mm   = Int(timeModel.adjustMM.rawValue) ?? 0
        var hh   = hh24
        
        if (timeModel.timeMeridiem == MeridiemType.pm) {
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
                readTimezone()
            })
        }
    }



    func modifyTimezone() {
        print("user clicked timezone: \(timeModel.timezone.rawValue)")
        var tz: String
        
        switch (timeModel.timezone) {
        case .eastern:  tz = "America/New_York"
        case .central:  tz = "America/Chicago"
        case .mountain: tz = "America/Denver"
        case .pacific:  tz = "America/Los_Angeles"
        }
        
        if (peripheral != nil) {
            print("modifying timezone characteristic: "+tz)

            let writeFuture = self.timezoneCharacteristic?.write(data:tz.data(using: .ascii)!)

            writeFuture?.onSuccess(completion: { (_) in
                readTimezone()
            })
            
        }
    }
    
    func modifyTimeFormat() {
        print("user clicked time format: \(timeModel.timeFormat.rawValue)")
        var format: String

        if (timeModel.timeFormat==TimeFormat.hour12) {
            format="2"
        } else {
            format="1"
        }

        
        if (peripheral != nil) {
            print("modifying format characteristic: "+format)
                       
            let writeFuture = self.formatCharacteristic?.write(data:format.data(using: .ascii)!)

            writeFuture?.onSuccess(completion: { (_) in
                readTime()
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
                messageTime(msg: s)
            }
        }
        readFuture?.onFailure { (_) in
            message(msg: "read error")
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
                    timeModel.timeFormat = TimeFormat.hour24
                } else {
                    timeModel.timeFormat = TimeFormat.hour12
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
                case "America/New_York":    timeModel.timezone=Timezones.eastern
                case "America/Chicago":     timeModel.timezone=Timezones.central
                case "America/Denver":      timeModel.timezone=Timezones.mountain
                case "America/Los_Angeles": timeModel.timezone=Timezones.pacific
                default: timeModel.timezone=Timezones.eastern
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
                timeModel.timeMeridiem = MeridiemType.pm
            }
            
            
            timeModel.adjustHH = HourType(rawValue: String(format:"%02d",hh24)) ?? HourType.hh01
            timeModel.adjustMM = MinuteType(rawValue: parts[1]) ?? MinuteType.mm01
        }
    }

    

    
    
    func activate() {
        message(msg: "Activating...")
        

        
        let stateChangeFuture = manager.whenStateChanges()
        print("tag10...")

        let scanFuture = stateChangeFuture.flatMap {
            state -> FutureStream<Peripheral> in switch state {
                case .poweredOn:
                    DispatchQueue.main.async {
                        message(msg:"Scanning...")
                    }
                    //scan for peripherlas that advertise the ec00 service
                return manager.startScanning(forServiceUUIDs: [ClockService.serviceCBUUID], capacity: 10)
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
                manager.reset()
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
            manager.stopScanning()
            peripheral = p
            guard let peripheral = peripheral else {
                throw AppError.unknown
            }
            DispatchQueue.main.async {
                message(msg: "Found peripheral \(peripheral.name)\nwith \(peripheral.services.count) services\nconnecting...")
                hostname = Text("Hostname: "+peripheral.name)
            }
            //connect to the peripheral in order to trigger the connected mode
            return peripheral.connect(connectionTimeout: 20, capacity: 5)
//            return peripheral.connect(connectionTimeout: 20)
        }
        
        
        print("tag40...")
        let discoveryFuture = connectionFuture.flatMap { _ -> Future<Void> in
            guard let peripheral = peripheral else {
                print("e401: unknown error")
                throw AppError.unknown
            }
            return peripheral.discoverServices([ClockService.serviceCBUUID])
        }
            
        let temp = discoveryFuture.flatMap { _ -> Future<Void> in
            guard let discoveredPeripheral = peripheral else {
                print("e402: unknown error")
                throw AppError.unknown
            }
            guard let service = discoveredPeripheral.services(withUUID:ClockService.serviceCBUUID)?.first else {
                print("e403: servcie not found")
                throw AppError.serviceNotFound
            }
            peripheral = discoveredPeripheral
            DispatchQueue.main.async {
                message(msg: "Discovered service \(service.uuid.uuidString). Trying to discover chracteristics")
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
            guard let discoveredPeripheral = peripheral else {
                throw AppError.unknown
            }
            guard let dataCharacteristic = discoveredPeripheral.services(withUUID:ClockService.serviceCBUUID)?.first?.characteristics(withUUID:ClockService.timeCharacteristicCBUUID)?.first else {
                throw AppError.dataCharactertisticNotFound
            }
            timeCharacteristic = dataCharacteristic
            DispatchQueue.main.async {
                message(msg: "Discovered characteristic \(dataCharacteristic.uuid.uuidString)")
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
            //Ask the characteristic to start notifying for value change
            return dataCharacteristic.startNotifying()
            }.flatMap { _ -> FutureStream<Data?> in
                guard let discoveredPeripheral = peripheral else {
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
                messageTime(msg: s)
            }
        }

    }

}
