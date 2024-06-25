import SwiftUI
import SwiftData

struct StatsView: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    if let bitsResource = gameState.model.resources.first(where: { $0.name == "Bits" }) {
                        StoreTopBar(resource: bitsResource, gameState: gameState)
                            .frame(width: geometry.size.width, height: geometry.safeAreaInsets.top + 60)
                            .background(Color.blue.opacity(0.5))
                    }
                    
                    List {
                        ForEach(gameState.model.resources) { resource in
                            Section(header: Text(resource.name)) {
                                Text("Total: \(gameState.formatNumber(resource.amount))")
                                Text("Per click: \(gameState.formatNumber(resource.perClick))")
                                Text("Per second: \(gameState.formatNumber(resource.perSecond))")
                            }
                        }
                    }
                    .listStyle(GroupedListStyle())
                }
                .ignoresSafeArea(edges: .top)
            }
            .navigationBarHidden(true)
        }
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        let previewGameState = GameState(model: GameStateModel())
        StatsView(gameState: previewGameState)
    }
}
