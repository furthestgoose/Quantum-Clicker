//
//  Quantum_ClickerApp.swift
//  Quantum Clicker
//
//  Created by Adam Byford on 23/06/2024.
//

import SwiftUI
import SwiftData

@main
struct Quantum_ClickerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: GameStateModel.self)
    }
}
