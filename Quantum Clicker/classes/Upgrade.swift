import Foundation
import SwiftData

enum UpgradeType: Codable {
    case factoryEfficiency(String, Double)
    case resourcePerClick(String, Double)
    case resourcePerSecond(String, Double)
    case unlockResource(String)
    case other(String)
}

@Model
class UpgradeModel: Identifiable {

    
    let id: UUID
    var icon: String
    var name: String
    var cost: Double
    var costResourceType: String
    var overview: String
    var upgradeType: UpgradeType
    
    init(id: UUID = UUID(), icon: String, name: String, cost: Double, costResourceType: String, description: String, upgradeType: UpgradeType) {
        self.id = id
        self.icon = icon
        self.name = name
        self.cost = cost
        self.costResourceType = costResourceType
        self.overview = description
        self.upgradeType = upgradeType
    }
}
