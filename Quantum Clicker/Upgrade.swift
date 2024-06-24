//
//  Upgrade.swift
//  Quantum Clicker
//
//  Created by Adam Byford on 24/06/2024.
//

import Foundation

struct Upgrade: Identifiable {
    let id = UUID()
    let icon: String
    let name: String
    var cost: Double
    let effect: (GameState) -> Void
    let description: String
}
