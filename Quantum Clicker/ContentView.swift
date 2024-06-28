import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var gameStateModels: [GameStateModel]
    @State private var gameState: GameState?
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Group {
            if let gameState = gameState {
                TabView {
                    ClickerView(gameState: gameState)
                        .tabItem {
                            Label("Clicker", systemImage: "hand.tap.fill")
                        }
                    
                    StoreView(gameState: gameState)
                        .tabItem {
                            Label("Store", systemImage: "storefront.fill")
                        }
                    
                    StatsView(gameState: gameState)
                        .tabItem {
                            Label("Stats", systemImage: "chart.bar.fill")
                        }
                }
                .accentColor(gameState.model.quantumUnlocked ? .purple : .blue)
                .onReceive(timer) { _ in
                    gameState.update()
                    try? modelContext.save()
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if gameState == nil {
                let gameStateModel: GameStateModel
                if let existingModel = gameStateModels.first {
                    gameStateModel = existingModel
                } else {
                    gameStateModel = GameStateModel()
                    modelContext.insert(gameStateModel)
                }
                gameState = GameState(model: gameStateModel)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: GameStateModel.self, inMemory: true)
}
