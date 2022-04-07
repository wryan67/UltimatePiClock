//
//  ContentView.swift
//  piclock
//
//  Created by wade ryan on 3/30/22.
//

import SwiftUI
import CoreBluetooth
import BlueCapKit

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
    case hour24 = "12-Hour"
    case hour12 = "24-Hour"

    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue)}
}


struct ContentView: View {

    let manager = CentralManager()
    @State var peripheral: Peripheral?

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

    @State private var selectedTab   = "One"
    @State private var timezone      = Timezones.eastern
    @State private var piTime        = Text("HH:MM TZ")
    @State private var timeControl   = TimeType.minute
    @State private var timeFormat    = TimeFormat.hour12
    @State private var statusMessage = Text("Scanning...")
    @State private var hh24:Int      = 0
    @State private var mm:Int      = 0
    
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
        TabView(selection: $selectedTab) {
            
            GroupBox() {
                VStack {
                    
                    Form {
                        Section(header: Text("Pi Clock")) {
                            HStack {
                                Text("Current Time:")
                                Spacer()
                                piTime
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
                                Button("+") {increment()}.frame(width: 50).buttonStyle(.bordered)
                                Button("-") {decrement()}.frame(width: 50).buttonStyle(.bordered)
                            }
                        }

                        
                        Section(header: Text("Timezone")) {
                            HStack {
                                Picker("Timezone", selection: $timezone) {
                                    ForEach(Timezones.allCases, id: \.self) { value in
                                        Text(value.localizedName).tag(value)
                                    }
                                }.pickerStyle(.segmented)
                                 .onChange(of: timezone, perform: {(value) in modifyTimezone()})

                            }
                        }
                        
                        Section(header: Text("Time Format")) {
                            HStack {
                                Picker("Time Format", selection: $timeFormat) {
                                    ForEach(TimeFormat.allCases, id: \.self) { value in
                                        Text(value.localizedName).tag(value)
                                    }
                                }.pickerStyle(.segmented)
                                 .onChange(of: timeFormat, perform: {(value) in modifyTimeFormat()})
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


        }.onAppear(perform: activate)
    }
    
    func message(msg: String) {
        print(msg)
    }

    func messageTime(msg: String) {
        print(msg)
        piTime = Text(msg)
    }
    
    func increment() {
        readHH24Update()
        switch (timeControl) {
        case .hour:
            hh24+=1
            if (hh24>23) {
                hh24=0;
            }
        case .minute:
            mm+=1
            if (mm>59) {
                mm=0
            }
        }
        let newTime = String(format: "%02d:%02d", hh24, mm)

        print("increment "+timeControl.rawValue+" newTime=\(newTime)")
        
        if (peripheral != nil) {
            print("updte time characteristic: "+newTime)

            let writeFuture = self.timeUpdateCharacteristic?.write(data:newTime.data(using: .ascii)!)

            writeFuture?.onSuccess(completion: { (_) in
                readTimezone()
            })
        }
    }

    func decrement() {
        readHH24Update()
        switch (timeControl) {
        case .hour:
            hh24-=1
            if (hh24<0) {
                hh24=23;
            }
        case .minute:
            mm-=1
            if (mm<0) {
                mm=59
            }
        }
        let newTime = String(format: "%02d:%02d", hh24, mm)
        print("decrement "+timeControl.rawValue+" newTime=\(newTime)")
        
        if (peripheral != nil) {
            print("updte time characteristic: "+newTime)

            let writeFuture = self.timeUpdateCharacteristic?.write(data:newTime.data(using: .ascii)!)

            writeFuture?.onSuccess(completion: { (_) in
                readTimezone()
            })
        }
    }


    func modifyTimezone() {
        print("user clicked timezone: \(timezone.rawValue)")
        var tz: String
        
        switch (timezone) {
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
        print("user clicked time format: \(timeFormat.rawValue)")
        var format: String

        if (timeFormat==TimeFormat.hour12) {
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
                    timeFormat = TimeFormat.hour24
                } else {
                    timeFormat = TimeFormat.hour12
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
                case "America/New_York":    timezone=Timezones.eastern
                case "America/Chicago":     timezone=Timezones.central
                case "America/Denver":      timezone=Timezones.mountain
                case "America/Los_Angeles": timezone=Timezones.pacific
                default: timezone=Timezones.eastern
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
        
        
        //read a value from the characteristic
        let readFuture = self.timeUpdateCharacteristic?.read(timeout: 5)
        readFuture?.onSuccess { (_) in
            //the value is in the dataValue property
            
            let s = String(data:(self.timeUpdateCharacteristic?.dataValue)!, encoding: .ascii) ?? "unknown"
            
            print("timeUpdate="+s)

            let parts = s.components(separatedBy: ":")
            
            hh24=Int(parts[0]) ?? -1
            mm=Int(parts[1]) ?? -1
        }
    }

    func readHH24(){
        if (peripheral != nil) {
            guard let discoveredPeripheral = peripheral else {
                print("e602: unknown error")
                return
            }
            guard let dataCharacteristic = discoveredPeripheral.services(withUUID:ClockService.serviceCBUUID)?.first?.characteristics(withUUID:ClockService.hh24CharacteristicCBUUID)?.first else {
                print("e605 hh24 characteristic not found")
                return
            }
            hh24Characteristic = dataCharacteristic
        }
        
        
        //read a value from the characteristic
        let readFuture = self.hh24Characteristic?.read(timeout: 5)
        readFuture?.onSuccess { (_) in
            //the value is in the dataValue property
            
            let s = String(data:(self.hh24Characteristic?.dataValue)!, encoding: .ascii) ?? "unknown"
            
            print("hh24="+s)

            hh24=Int(s) ?? -1
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



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.portraitUpsideDown)
    }
}

