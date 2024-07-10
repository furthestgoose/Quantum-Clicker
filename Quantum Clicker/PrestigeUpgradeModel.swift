
import Foundation
import SwiftData

@Model
class PrestigeUpgradeModel: Identifiable {
    let id: UUID
    let icon: String
    let name: String
    let overview: String
    var cost: Int
    var bought: Bool
    
    init(id: UUID = UUID(), icon: String, name: String, description: String, cost: Int) {
        self.id = id
        self.icon = icon
        self.name = name
        self.overview = description
        self.cost = cost
        self.bought = false
    }
}
