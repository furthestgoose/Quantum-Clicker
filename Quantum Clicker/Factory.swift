//
//  Factory.swift
//  Quantum Clicker
//
//  Created by Adam Byford on 24/06/2024.
//

import Foundation
import SwiftData

@Model
class FactoryModel: Identifiable{
    let id: UUID
    var icon: String
    var name: String
    var cost: Double
    var count: Int
    var OverView: String
    
    init(id: UUID = UUID(), icon: String, name: String, cost: Double, count: Int, description: String) {
        self.id = id
        self.icon = icon
        self.name = name
        self.cost = cost
        self.count = count
        self.OverView = description
    }
}
