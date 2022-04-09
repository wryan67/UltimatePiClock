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

extension UIPickerView {
  open override var intrinsicContentSize: CGSize {
      return CGSize(width: UIView.noIntrinsicMetric, height: super.intrinsicContentSize.height)
  }
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
    @State private var timeMeridiem  = MeridiemType.am
    @State private var timeFormat    = TimeFormat.hour12
    @State private var statusMessage = Text("Scanning...")
//    @State private var hh24:Int      = 0
//    @State private var mm:Int        = 0
    
    @State var tempCharacteristic : Characteristic?
    @State var unitCharacteristic : Characteristic?
    @State var timeCharacteristic : Characteristic?
    @State var formatCharacteristic : Characteristic?
    @State var timezoneCharacteristic : Characteristic?
    @State var hh24Characteristic : Characteristic?
    @State var timeUpdateCharacteristic : Characteristic?

    @State var hostname = Text("Hostname: unknown")
    @State var units = TemperatureUnitType.celsius
    
    @State var adjustHH = HourType.hh01
    @State var adjustMM = MinuteType.mm01

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
                            VStack {
                                HStack {
                                    HStack (spacing:.zero){
                                            Picker("", selection: $adjustHH) {
                                                ForEach(HourType.allCases, id: \.self) { value in
                                                    Text(value.localizedName)
                                                        .tag(value)
                                                }
                                            }   .pickerStyle(.wheel)
                                                .labelsHidden()

                                            Text(":")//.frame(width: 10,  height:60, alignment: .center)

                                            Picker(selection: $adjustMM, label: Text("")) {
                                                    ForEach(MinuteType.allCases, id: \.self) { value in
                                                        Text(value.localizedName)
                                                            .tag(value)
                                                    }
                                                }   .pickerStyle(.wheel)
                                                    .labelsHidden()
                                        }.frame(height:60)
                                         .clipped()

                                    Spacer().frame(width:50)
                                    Picker("Meridiem", selection: $timeMeridiem) {
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

    @State var lastTime = ""
    func messageTime(msg: String) {
        if (msg != lastTime) {
            print(msg)
            lastTime=msg
        }
        piTime = Text(msg)
    }
    
    func adjustTime() {
        print("adjust time...")
        
        let hh24 = Int(adjustHH.rawValue) ?? 0
        let mm   = Int(adjustMM.rawValue) ?? 0
        var hh   = hh24
        
        if (timeMeridiem == MeridiemType.pm) {
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
                timeMeridiem = MeridiemType.pm
            }
            
            
            adjustHH = HourType(rawValue: String(format:"%02d",hh24)) ?? HourType.hh01
            adjustMM = MinuteType(rawValue: parts[1]) ?? MinuteType.mm01
        }
    }

    
    
//    func readHH24(){
//        if (peripheral != nil) {
//            guard let discoveredPeripheral = peripheral else {
//                print("e602: unknown error")
//                return
//            }
//            guard let dataCharacteristic = discoveredPeripheral.services(withUUID:ClockService.serviceCBUUID)?.first?.characteristics(withUUID:ClockService.hh24CharacteristicCBUUID)?.first else {
//                print("e605 hh24 characteristic not found")
//                return
//            }
//            hh24Characteristic = dataCharacteristic
//        }
//
//
//        //read a value from the characteristic
//        let readFuture = self.hh24Characteristic?.read(timeout: 5)
//        readFuture?.onSuccess { (_) in
//            //the value is in the dataValue property
//
//            let s = String(data:(self.hh24Characteristic?.dataValue)!, encoding: .ascii) ?? "unknown"
//
//        }
//    }

    
    
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



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.portraitUpsideDown)
    }
}

