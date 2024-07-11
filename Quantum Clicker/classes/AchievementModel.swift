import Foundation
import SwiftData

@Model
class AchievementModel: Identifiable {
    let id: String
    let title: String
    let overview: String
    var isUnlocked: Bool
    let order: Int

    init(id: String, title: String, description: String, isUnlocked: Bool,  order: Int) {
        self.id = id
        self.title = title
        self.overview = description
        self.isUnlocked = isUnlocked
        self.order = order
    }
}
