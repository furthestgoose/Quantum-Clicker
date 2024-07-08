import SwiftUI

enum StoreTab {
    case factories
    case upgrades
}




struct StoreView: View {
    @ObservedObject var gameState: GameState
    @State private var selectedTab: StoreTab = .factories

    var body: some View {
        
        NavigationStack {
            
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    if let bitsResource = gameState.model.resources.first(where: { $0.name == "Bits" }) {
                                        let qubitsResource = gameState.model.resources.first(where: { $0.name == "Qubits" })
                                        StoreTopBar(bitsResource: bitsResource, qubitsResource: qubitsResource, gameState: gameState)
                                    }
                    
                    Picker("Store Tab", selection: $selectedTab) {
                        Text("Computers").tag(StoreTab.factories)
                        Text("Upgrades").tag(StoreTab.upgrades)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

                    if selectedTab == .factories {
                        FactoriesList(gameState: gameState)
                    } else {
                        UpgradesList(gameState: gameState)
                    }
                }
                .ignoresSafeArea(edges: .top)
            }
            .navigationBarHidden(true)
        }
    }
}
struct StoreTopBar: View {
    let bitsResource: ResourceModel
    let qubitsResource: ResourceModel?
    @ObservedObject var gameState: GameState
    
    var body: some View {
        VStack(spacing: 0) {
            // Spacer to account for dynamic island
            Spacer()
                .frame(height: 50)
            Text ("Era: \(gameState.model.quantumUnlocked ? "Quantum" : "Classical")")
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .bold))
            HStack {
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 5)
            
            HStack(spacing: 20) {
                resourceDisplay(amount: bitsResource.amount, perSecond: bitsResource.perSecond, label: "Bits", icon: "square")
                if gameState.model.quantumUnlocked, let qubits = qubitsResource {
                    Divider().background(Color.white.opacity(0.3))
                    resourceDisplay(amount: qubits.amount, perSecond: qubits.perSecond, label: "Qubits", icon: "atom")
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
        .frame(height: 140) // Adjusted height for store view
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    gameState.model.quantumUnlocked ? Color.purple : Color.blue,
                    gameState.model.quantumUnlocked ? Color.purple.opacity(0.7) : Color.blue.opacity(0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private func resourceDisplay(amount: Double, perSecond: Double, label: String, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(gameState.formatNumber(amount))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                HStack(spacing: 4) {
                    Text(label)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(gameState.formatNumber(perSecond))/s")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }
}

struct UpgradesList: View {
    @ObservedObject var gameState: GameState

    var sortedUpgrades: [UpgradeModel] {
        gameState.model.upgrades.sorted(by: { $0.cost < $1.cost })
    }

    var body: some View {
        List {
            ForEach(filteredUpgrades) { upgrade in
                UpgradeRow(gameState: gameState,upgrade: upgrade,
                           canBuy: canBuy(upgrade)) {
                    gameState.buyUpgrade(gameState.model.upgrades.firstIndex(of: upgrade)!)
                }
            }
        }
        .listStyle(PlainListStyle())
    }

    private var filteredUpgrades: [UpgradeModel] {
            sortedUpgrades.filter { upgrade in
                switch upgrade.name {
                case "RAM Upgrade":
                    return gameState.model.personalComputerUnlocked
                case "CPU Upgrade":
                    return gameState.personalComputerCount >= 5
                case "Cooling System Upgrade":
                    return gameState.personalComputerCount >= 10
                case "Storage Upgrade":
                    return gameState.personalComputerCount >= 15
                case "Processor Overclock":
                    return gameState.workstationCount >= 10
                case "RAM Expansion":
                    return gameState.workstationCount >= 25
                case "Graphics Accelerator":
                    return gameState.workstationCount >= 50
                case "High-Speed Network Interface":
                    return gameState.workstationCount >= 100
                default:
                    return true
                }
            }
        }

    private func canBuy(_ upgrade: UpgradeModel) -> Bool {
        return gameState.model.resources.first(where: { $0.name == "Bits" })?.amount ?? 0 >= upgrade.cost
    }
}

struct UpgradeRow: View {
    @ObservedObject var gameState: GameState
    let upgrade: UpgradeModel
    let canBuy: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: upgrade.icon)
                .font(.title)
            VStack(alignment: .leading) {
                Text(upgrade.name).font(.headline)
                Text(upgrade.OverView).font(.subheadline)
            }
            Spacer()
            VStack {
                Button("Buy", action: action)
                    .buttonStyle(BorderlessButtonStyle())
                    .disabled(!canBuy)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(canBuy ? (gameState.model.quantumUnlocked ? Color.purple : Color.blue) : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(5)
                
                // Conditional text for "bit" or "bits"
                Text("\(gameState.formatNumber(upgrade.cost + 0.1)) \(upgrade.cost + 0.1 == 1 ? "bit" : "bits")")
                    .font(.caption)
                    .foregroundColor(canBuy ? (gameState.model.quantumUnlocked ? .purple : .blue) : .gray)
            }
        }
    }
}

struct FactoriesList: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        List {
            ForEach(sortedFactories, id: \.self) { factory in
                if let index = gameState.model.factories.firstIndex(where: { $0.id == factory.id }) {
                    FactoryRow(gameState: gameState, factory: factory, index: index)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    var sortedFactories: [FactoryModel] {
        let classicalFactories = gameState.model.factories.filter { $0.name != "Basic Quantum Computer" }
        let sortedClassical = classicalFactories.sorted(by: { $0.initialCost < $1.initialCost })
        
        if gameState.model.quantumUnlocked, let quantumComputer = gameState.model.factories.first(where: { $0.name == "Basic Quantum Computer" }) {
            return sortedClassical + [quantumComputer]
        } else {
            return sortedClassical
        }
    }
}

struct FactoryRow: View {
    @ObservedObject var gameState: GameState
    let factory: FactoryModel
    let index: Int
    @State private var quantity = 1
    
    var canBuy: Bool {
        let totalCost = (factory.cost * (1 - pow(1.2, Double(quantity))) / (1 - 1.2)) - 0.1
        if factory.costResourceType == "Qubits" {
            return gameState.model.resources.first(where: { $0.name == "Qubits" })?.amount ?? 0 >= totalCost
        } else {
            return gameState.model.resources.first(where: { $0.name == "Bits" })?.amount ?? 0 >= totalCost
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: factory.icon)
                .font(.title)
            Text(factory.name).font(.headline)
            Text(factory.OverView).font(.subheadline)
            Text("Owned: \(factory.count)").font(.caption)
            
            HStack {
                Stepper("Quantity: \(quantity)", value: $quantity, in: 1...100)
                    .frame(width: 200)
            }
            
            Button("Buy") {
                gameState.buyFactory(index, quantity: quantity)
            }
            .buttonStyle(BorderlessButtonStyle())
            .disabled(!canBuy)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(canBuy ? (gameState.model.quantumUnlocked ? Color.purple : Color.blue) : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(5)
            
            let totalCost = factory.cost * (1 - pow(1.2, Double(quantity))) / (1 - 1.2)
            Text("\(gameState.formatNumber(totalCost)) \(factory.costResourceType)")
                .font(.caption)
                .foregroundColor(canBuy ? (gameState.model.quantumUnlocked ? .purple : .blue) : .gray)
        }
    }
}
