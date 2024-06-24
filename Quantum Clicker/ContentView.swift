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
            
            StoreView(gameState: gameState)
                .tabItem {
                    Label("Store", systemImage: "storefront.fill")
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
