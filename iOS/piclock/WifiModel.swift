//
//  WifiModel.swift
//  piclock
//
//  Created by wade ryan on 4/10/22.
//

import Foundation

class WifiModel:ObservableObject {
    
    @Published var ssid          = "unknown"

    @Published var statusMessage = "Unknown..."
    
    @Published var networks: [String] = []
    
}


