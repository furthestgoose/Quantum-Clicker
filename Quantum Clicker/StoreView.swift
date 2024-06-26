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
                        StoreTopBar(resource: bitsResource, gameState: gameState)
                            .frame(width: geometry.size.width, height: geometry.safeAreaInsets.top + 60)
                            .background(Color.blue.opacity(0.5))
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

struct FactoriesList: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        List {
            ForEach(gameState.model.factories.sorted(by: { $0.cost < $1.cost }), id: \.self) { factory in
                if let index = gameState.model.factories.firstIndex(where: { $0.id == factory.id }) {
                    FactoryRow(gameState: gameState, factory: factory, index: index)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct StoreTopBar: View {
    let resource: ResourceModel
    @ObservedObject var gameState: GameState
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Spacer()
                    Text("\(gameState.formatNumber(resource.amount)) bits")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("\(gameState.formatNumber(resource.perSecond))/s")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    Spacer()
                }
                Spacer()
            }
            .frame(width: geometry.size.width)
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
                UpgradeRow(upgrade: upgrade,
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
            VStack{
                Button("Buy", action: action)
                    .buttonStyle(BorderlessButtonStyle())
                    .disabled(!canBuy)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(canBuy ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(5)
                
                Text("\(Int(upgrade.cost + 0.1)) bits")
                    .font(.caption)
                    .foregroundColor(canBuy ? .blue : .gray)
            }
        }
    }
}

struct FactoryRow: View {
    @ObservedObject var gameState: GameState
        let factory: FactoryModel
        let index: Int
        @State private var quantity = 1
    
    var canBuy: Bool {
            let totalCost = factory.cost * (1 - pow(1.2, Double(quantity))) / (1 - 1.2)
            return gameState.model.resources.first(where: { $0.name == "Bits" })?.amount ?? 0 >= totalCost
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
            .background(canBuy ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(5)
            
            let totalCost = factory.cost * (1 - pow(1.2, Double(quantity))) / (1 - 1.2)
            Text("\(Int(totalCost)) bits")
                .font(.caption)
                .foregroundColor(canBuy ? .blue : .gray)
        }
    }
}
