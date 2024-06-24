//
//  Factory.swift
//  Quantum Clicker
//
//  Created by Adam Byford on 24/06/2024.
//

import Foundation

struct Factory: Identifiable {
    let id = UUID()
    let icon: String
    let name: String
    var cost: Double
    var count: Int = 0
    let effect: (GameState) -> Void
    var description: String
}
