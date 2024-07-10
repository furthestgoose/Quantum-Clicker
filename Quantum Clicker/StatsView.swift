import SwiftUI
import SwiftData

struct StatsView: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    if let bitsResource = gameState.model.resources.first(where: { $0.name == "Bits" }) {
                                        let qubitsResource = gameState.model.resources.first(where: { $0.name == "Qubits" })
                                        StoreTopBar(bitsResource: bitsResource, qubitsResource: qubitsResource, gameState: gameState)
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

