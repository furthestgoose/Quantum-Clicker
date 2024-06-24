import SwiftUI


struct ContentView: View {
    @StateObject private var gameState = GameState()
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        TabView {
            ClickerView(gameState: gameState)
                .tabItem {
                    Label("Clicker", systemImage: "hand.tap.fill")
                }
            
            UpgradesView(gameState: gameState)
                .tabItem {
                    Label("Upgrades", systemImage: "arrow.up.circle.fill")
                }
            
            FactoriesView(gameState: gameState)
                .tabItem {
                    Label("Factories", systemImage: "building.2.fill")
                }
            
            StatsView(gameState: gameState)
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
        }
        .onReceive(timer) { _ in
            gameState.update()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
