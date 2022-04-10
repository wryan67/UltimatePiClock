//
//  piclockApp.swift
//  piclock
//
//  Created by wade ryan on 3/30/22.
//

import SwiftUI

@main
struct piclockApp: App {
    @StateObject private var model = ClockService()
    
    var body: some Scene {
        WindowGroup {
            ContentView(clockService: model)
        }
    }
}
