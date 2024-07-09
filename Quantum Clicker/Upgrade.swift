//
//  Upgrade.swift
//  Quantum Clicker
//
//  Created by Adam Byford on 24/06/2024.
//

import Foundation
import SwiftData

@Model
class UpgradeModel: Identifiable{
    let id: UUID
    var icon: String
    var name: String
    var cost: Double
    var costResourceType: String
    var OverView: String
    
    init(id: UUID = UUID(), icon: String, name: String, cost: Double,costResourceType: String, description: String) {
        self.id = id
        self.icon = icon
        self.name = name
        self.cost = cost
        self.costResourceType = costResourceType
        self.OverView = description
    }
}
