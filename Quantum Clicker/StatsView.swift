import SwiftUI
import SwiftData

struct StatsView: View {
    @ObservedObject var gameState: GameState
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    if let bitsResource = gameState.model.resources.first(where: { $0.name == "Bits" }) {
                        let qubitsResource = gameState.model.resources.first(where: { $0.name == "Qubits" })
                        StoreTopBar(bitsResource: bitsResource, qubitsResource: qubitsResource, gameState: gameState)
                    }
                    
                    Picker("", selection: $selectedTab) {
                        Text("Resources").tag(0)
                        Text("Factories").tag(1)
                        Text("Achievements").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    TabView(selection: $selectedTab) {
                        ResourcesTab(gameState: gameState)
                            .tag(0)
                        FactoriesTab(gameState: gameState)
                            .tag(1)
                        AchievementsTab(gameState: gameState)
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
                .ignoresSafeArea(edges: .top)
            }
            .navigationBarHidden(true)
        }
    }
}

struct ResourcesTab: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        List {
            ForEach(gameState.model.resources) { resource in
                Section(header: Text(resource.name)) {
                    StatRow(title: "Total", value: gameState.formatNumber(resource.amount))
                    StatRow(title: "Per click", value: gameState.formatNumber(resource.perClick))
                    StatRow(title: "Per second", value: gameState.formatNumber(resource.perSecond))
                    if resource.name == "Bits" {
                        StatRow(title: "Total earned", value: gameState.formatNumber(gameState.model.totalBitsEarned))
                    } else if resource.name == "Qubits" {
                        StatRow(title: "Total earned", value: gameState.formatNumber(gameState.model.totalQubitsEarned))
                    }
                }
            }
            Section(header: Text("Prestige")){
                StatRow(title: "Prestige Points", value: String(gameState.model.prestigePoints))
                StatRow(title: "Prestige Multiplier", value: String(gameState.model.prestigeMultiplier) + "%")
            }
        }
        .listStyle(GroupedListStyle())
    }
}

struct FactoriesTab: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        List {
            ForEach(sortedFactories, id: \.self) { factory in
                Section(header: Text(factory.name)) {
                    StatRow(title: "Owned", value: "\(factory.count)")
                    StatRow(title: "Next cost", value: gameState.formatNumber(factory.cost))
                }
            }
        }
        .listStyle(GroupedListStyle())
        
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
}

struct AchievementsTab: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        List {
            ForEach(gameState.model.achievements.sorted(by: { $0.order < $1.order })) { achievement in
                Achievement(achievement: achievement)
            }
        }
        .listStyle(GroupedListStyle())
    }
}

struct Achievement: View {
    let achievement: AchievementModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(achievement.title)
                    .font(.headline)
                Text(achievement.overview)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
            }
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(.bold)
        }
    }
}
