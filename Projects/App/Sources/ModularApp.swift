//
//  ModularApp.swift
//  Shared
//
//  Created by und3fined on 10/21/20.
//

import SwiftUI
import M1

@main
struct ModularApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.onChange(of: scenePhase) { phase in
            print("scenePhase change \(phase)")
            M1.hello()
        }
    }
}
