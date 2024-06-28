//
//  Factory.swift
//  Quantum Clicker
//
//  Created by Adam Byford on 24/06/2024.
//

import Foundation
import SwiftData

@Model
class FactoryModel: Identifiable {
    let id: UUID
    var icon: String
    var name: String
    var cost: Double
    var initialCost: Double // Add this property
    var costResourceType: String
    var count: Int
    var OverView: String
    
    init(icon: String, name: String, cost: Double, costResourceType: String, count: Int, OverView: String) {
        self.id = UUID()
        self.icon = icon
        self.name = name
        self.cost = cost
        self.initialCost = cost // Initialize this property
        self.costResourceType = costResourceType
        self.count = count
        self.OverView = OverView
    }
}
