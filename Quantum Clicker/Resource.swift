//
//  Resource.swift
//  Quantum Clicker
//
//  Created by Adam Byford on 24/06/2024.
//

import Foundation

struct Resource: Identifiable {
    let id = UUID()
    let name: String
    var amount: Double
    var perClick: Double
    var perSecond: Double
}
