import SwiftUI

// MARK: - Models

struct Resource: Identifiable {
    let id = UUID()
    let name: String
    var amount: Double
    var perClick: Double
    var perSecond: Double
}

struct Upgrade: Identifiable {
    let id = UUID()
    let name: String
    var cost: Double
    let effect: (GameState) -> Void
    let description: String
    let type: UpgradeType
}

enum UpgradeType {
    case click, automate, unlock
}

// MARK: - Game State

class GameState: ObservableObject {
    @Published var resources: [Resource]
    @Published var upgrades: [Upgrade]
    @Published var quantumUnlocked = false
    
    init() {
        resources = [
            Resource(name: "Bits", amount: 0, perClick: 1, perSecond: 0),
            Resource(name: "Qubits", amount: 0, perClick: 0, perSecond: 0)
        ]
        
        upgrades = [
            Upgrade(name: "Faster Fingers", cost: 10, effect: { state in
                state.resources[0].perClick += 1
            }, description: "Increase bits per click", type: .click),
            Upgrade(name: "Auto-Clicker", cost: 50, effect: { state in
                state.resources[0].perSecond += 1
            }, description: "Generate 1 bit per second", type: .automate),
            Upgrade(name: "Quantum Research", cost: 1000, effect: { state in
                state.quantumUnlocked = true
                state.resources[1].perClick = 0.001  // 1 qubit per 1000 clicks
            }, description: "Unlock Quantum Computing", type: .unlock)
        ]
    }
    
    func click() {
        resources[0].amount += resources[0].perClick
        if quantumUnlocked {
            resources[1].amount += resources[1].perClick
        }
    }
    
    func buyUpgrade(_ upgradeIndex: Int) {
        guard upgradeIndex < upgrades.count else { return }
        let upgrade = upgrades[upgradeIndex]
        if resources[0].amount >= upgrade.cost {
            resources[0].amount -= upgrade.cost
            upgrade.effect(self)
            upgrades[upgradeIndex].cost *= 1.5
        }
    }
    
    func update() {
        for i in 0..<resources.count {
            resources[i].amount += resources[i].perSecond / 10
        }
    }
}

// MARK: - Views

struct ResourceView: View {
    let resource: Resource
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(resource.name): \(Int(resource.amount))")
            Text("Per click: \(String(format: "%.3f", resource.perClick))")
            Text("Per second: \(String(format: "%.2f", resource.perSecond))")
        }
    }
}

struct UpgradeView: View {
    let upgrade: Upgrade
    let canBuy: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(upgrade.name).font(.headline)
            Text(upgrade.description).font(.subheadline)
            Text("Cost: \(Int(upgrade.cost)) bits").font(.caption)
            Button("Buy", action: action)
                .disabled(!canBuy)
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .background(canBuy ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(5)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}

struct ContentView: View {
    @StateObject private var gameState = GameState()
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        TabView {
            MainGameView(gameState: gameState)
                .tabItem {
                    Label("Clicker", systemImage: "hand.tap.fill")
                }
            
            UpgradesView(gameState: gameState)
                .tabItem {
                    Label("Store", systemImage: "storefront.fill")
                }
            
            StatsView(gameState: gameState)
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
        }
        .onReceive(timer) { _ in
            gameState.update()
        }
    }
}

struct MainGameView: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TopBar(resource: gameState.resources[0])
                
                TappableArea(perClick: gameState.resources[0].perClick) {
                    gameState.click()
                }
            }
            .edgesIgnoringSafeArea(.top)
            .navigationTitle("Quantum Clicker")
            .navigationBarHidden(true)
        }
    }
}

struct TopBar: View {
    let resource: Resource
    
    var body: some View {
        VStack {
            Image(systemName: "desktopcomputer")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .foregroundColor(.white)
                .overlay(
                    VStack {
                        Text("\(Int(resource.amount)) \(Int(resource.amount) == 1 ? "bit" : "bits")")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("\(String(format: "%.0f", resource.perSecond))/s")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                        .padding(.bottom, 30)
                )
        }
        .padding(.top, 30)
        .frame(height: 250)
        .frame(maxWidth: .infinity)
        .background(Color.blue.opacity(0.5))
        .clipShape(RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 20))
        .padding(.bottom, 10)
    }
}

struct RoundedCornersShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct TappableArea: View {
    let perClick: Double
    let action: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                    .opacity(0.5)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    
                
                VStack {
                    Image(systemName: "hand.tap.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.black)
                    Text("Click here to earn \(Int(perClick)) \(Int(perClick) == 1 ? "bit" : "bits")")
                        .foregroundColor(.black)
                        .font(.headline)
                }
                
            }
            .onTapGesture {
                action()
            }
        }
    }
}

struct UpgradesView: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(gameState.upgrades.indices, id: \.self) { index in
                        UpgradeView(
                            upgrade: gameState.upgrades[index],
                            canBuy: gameState.resources[0].amount >= gameState.upgrades[index].cost
                        ) {
                            gameState.buyUpgrade(index)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Upgrades")
        }
    }
}

struct StatsView: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        NavigationView {
            List {
                ForEach(gameState.resources) { resource in
                    Section(header: Text(resource.name)) {
                        Text("Total: \(Int(resource.amount))")
                        Text("Per click: \(String(format: "%.3f", resource.perClick))")
                        Text("Per second: \(String(format: "%.2f", resource.perSecond))")
                    }
                }
            }
            .navigationTitle("Statistics")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
