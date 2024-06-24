import SwiftUI

enum StoreTab {
    case factories
    case upgrades
}


struct StoreView: View {
    @ObservedObject var gameState: GameState
    @State private var selectedTab: StoreTab = .factories

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    StoreTopBar(resource: gameState.resources[0], gameState: gameState)
                        .frame(width: geometry.size.width, height: geometry.safeAreaInsets.top + 60)
                        .background(Color.blue.opacity(0.5))
                    
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
            ForEach(gameState.factories.indices, id: \.self) { index in
                FactoryRow(gameState: gameState, factory: gameState.factories[index], index: index)
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct StoreTopBar: View {
    let resource: Resource
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

    var body: some View {
        List {
            ForEach(gameState.upgrades.filter { $0.name != "Ram Upgrade" && $0.name != "CPU Upgrade" && $0.name != "Cooling System Upgrade" && $0.name != "Storage Upgrade"} , id: \.id) { upgrade in
                UpgradeRow(upgrade: upgrade,
                           canBuy: gameState.resources[0].amount >= upgrade.cost) {
                    if let index = gameState.upgrades.firstIndex(where: { $0.id == upgrade.id }) {
                        gameState.buyUpgrade(index)
                    }
                }
            }
            
            if gameState.PersonalComputerUnlocked {
                if let PersonalComputerUpgrade = gameState.upgrades.first(where: { $0.name == "Ram Upgrade" }) {
                    UpgradeRow(upgrade: PersonalComputerUpgrade,
                               canBuy: gameState.resources[0].amount >= PersonalComputerUpgrade.cost) {
                        if let index = gameState.upgrades.firstIndex(where: { $0.id == PersonalComputerUpgrade.id }) {
                            gameState.buyUpgrade(index)
                        }
                    }
                }
            }
            
            if gameState.PersonalComputerCount >= 5 {
                if let PersonalComputerUpgrade = gameState.upgrades.first(where: { $0.name == "CPU Upgrade" }) {
                    UpgradeRow(upgrade: PersonalComputerUpgrade,
                               canBuy: gameState.resources[0].amount >= PersonalComputerUpgrade.cost) {
                        if let index = gameState.upgrades.firstIndex(where: { $0.id == PersonalComputerUpgrade.id }) {
                            gameState.buyUpgrade(index)
                        }
                    }
                }
            }
            
            if gameState.PersonalComputerCount >= 10 {
                if let PersonalComputerUpgrade = gameState.upgrades.first(where: { $0.name == "Cooling System Upgrade" }) {
                    UpgradeRow(upgrade: PersonalComputerUpgrade,
                               canBuy: gameState.resources[0].amount >= PersonalComputerUpgrade.cost) {
                        if let index = gameState.upgrades.firstIndex(where: { $0.id == PersonalComputerUpgrade.id }) {
                            gameState.buyUpgrade(index)
                        }
                    }
                }
            }
            
            if gameState.PersonalComputerCount >= 15 {
                if let PersonalComputerUpgrade = gameState.upgrades.first(where: { $0.name == "Storage Upgrade" }) {
                    UpgradeRow(upgrade: PersonalComputerUpgrade,
                               canBuy: gameState.resources[0].amount >= PersonalComputerUpgrade.cost) {
                        if let index = gameState.upgrades.firstIndex(where: { $0.id == PersonalComputerUpgrade.id }) {
                            gameState.buyUpgrade(index)
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct UpgradeRow: View {
    let upgrade: Upgrade
    let canBuy: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: upgrade.icon)
                .font(.title)
            VStack(alignment: .leading) {
                
                Text(upgrade.name).font(.headline)
                Text(upgrade.description).font(.subheadline)
            }
            Spacer()
            VStack{
                Button("Buy", action: action)
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
    let factory: Factory
    let index: Int
    @State private var quantity = 1
    
    var canBuy: Bool {
        let totalCost = factory.cost * (1 - pow(1.5, Double(quantity))) / (1 - 1.5)
        return gameState.resources[0].amount >= totalCost
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: factory.icon)
                .font(.title)
            Text(factory.name).font(.headline)
            Text(factory.description).font(.subheadline)
            Text("Owned: \(factory.count)").font(.caption)
            
            HStack {
                Stepper("Quantity: \(quantity)", value: $quantity, in: 1...100)
                    .frame(width: 200)
            }
            
            Button("Buy") {
                gameState.buyFactory(index, quantity: quantity)
            }
            .disabled(!canBuy)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(canBuy ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(5)
            
            let totalCost = factory.cost * (1 - pow(1.5, Double(quantity))) / (1 - 1.5)
            Text("\(Int(totalCost)) bits")
                .font(.caption)
                .foregroundColor(canBuy ? .blue : .gray)
        }
    }
}

#Preview {
    StoreView(gameState: GameState())
}
