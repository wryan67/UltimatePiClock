//
//  WifiModel.swift
//  piclock
//
//  Created by wade ryan on 4/10/22.
//

import Foundation

class WifiModel:ObservableObject {
    @Published var isScanning     = true
    
    @Published var isUpdatingWifi = false
    
    @Published var ssid          = "unknown"

    @Published var statusMessage = "Unknown..."
    
    @Published var networks: [String] = []
    
    @Published var newSSID       = ""
    
    @Published var passwd        = ""
    
    @Published var autoTimeUpdate = true
}


