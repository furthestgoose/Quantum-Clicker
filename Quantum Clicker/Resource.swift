//
//  Resource.swift
//  Quantum Clicker
//
//  Created by Adam Byford on 24/06/2024.
//

import Foundation
import SwiftData

@Model
class ResourceModel: Identifiable{
    let id: UUID
    var name: String
    var amount: Double
    var perClick: Double
    var perSecond: Double
    
    init(id: UUID = UUID(), name: String, amount: Double, perClick: Double, perSecond: Double) {
        self.id = id
        self.name = name
        self.amount = amount
        self.perClick = perClick
        self.perSecond = perSecond
    }
}
