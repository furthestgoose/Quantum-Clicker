import SwiftUI
import SwiftData

struct StatsView: View {
    @ObservedObject var gameState: GameState
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme
    
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
                        Text("Computers").tag(1)
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
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(colorScheme == .dark ? Color.black : Color.white)
                .ignoresSafeArea(edges: .top)
            }
            .navigationBarHidden(true)
        }
    }
}

struct ResourcesTab: View {
    @ObservedObject var gameState: GameState
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(gameState.model.resources) { resource in
                    ResourceSection(resource: resource, gameState: gameState)
                }
                PrestigeSection(gameState: gameState)
            }
            .padding()
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
    }
}

struct ResourceSection: View {
    let resource: ResourceModel
    @ObservedObject var gameState: GameState
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(resource.name)
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            StatRow(title: "Total", value: gameState.formatNumber(resource.amount))
            StatRow(title: "Per click", value: gameState.formatNumber(resource.perClick))
            StatRow(title: "Per second", value: gameState.formatNumber(resource.perSecond))
            
            if resource.name == "Bits" {
                StatRow(title: "Total earned", value: gameState.formatNumber(gameState.model.totalBitsEarned))
            } else if resource.name == "Qubits" {
                StatRow(title: "Total earned", value: gameState.formatNumber(gameState.model.totalQubitsEarned))
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct PrestigeSection: View {
    @ObservedObject var gameState: GameState
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Prestige")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            StatRow(title: "Prestige Points", value: String(gameState.model.prestigePoints))
            StatRow(title: "Prestige Multiplier", value: String(format: "%.2f%%", gameState.model.prestigeMultiplier))
            StatRow(title: "Times Prestiged", value: String(gameState.model.timesPrestiged))
        }
        .padding()
        .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct FactoriesTab: View {
    @ObservedObject var gameState: GameState
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(sortedFactories, id: \.self) { factory in
                    FactorySection(factory: factory, gameState: gameState)
                }
            }
            .padding()
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
    }
    
    var sortedFactories: [FactoryModel] {
        let classicalFactories = gameState.model.factories.filter { !$0.name.contains("Quantum") }
        let sortedClassical = classicalFactories.sorted(by: { $0.initialCost < $1.initialCost })
        
        if gameState.model.quantumUnlocked {
            let quantumFactories = gameState.model.factories.filter { $0.name.contains("Quantum") }
            return sortedClassical + quantumFactories
        } else {
            return sortedClassical
        }
    }
}

struct FactorySection: View {
    let factory: FactoryModel
    @ObservedObject var gameState: GameState
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(factory.name)
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            StatRow(title: "Owned", value: "\(factory.count)")
            StatRow(title: "Next cost", value: gameState.formatNumber(factory.cost))
        }
        .padding()
        .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct AchievementsTab: View {
    @ObservedObject var gameState: GameState
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(gameState.model.achievements.sorted(by: { $0.order < $1.order })) { achievement in
                    Achievement(achievement: achievement)
                }
            }
            .padding()
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
    }
}

struct Achievement: View {
    let achievement: AchievementModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
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
        .padding()
        .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct StatRow: View {
    let title: String
    let value: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            Spacer()
            Text(value)
                .fontWeight(.bold)
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }
    }
}
