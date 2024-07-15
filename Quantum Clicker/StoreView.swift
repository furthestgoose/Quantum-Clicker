import SwiftUI

enum StoreTab {
    case factories
    case upgrades
    case prestigeUpgrades
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
                        Text("Prestige").tag(StoreTab.prestigeUpgrades)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

                    switch selectedTab {
                    case .factories:
                        FactoriesList(gameState: gameState)
                    case .upgrades:
                        UpgradesList(gameState: gameState)
                    case .prestigeUpgrades:
                        PrestigeUpgradesList(gameState: gameState)
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
                resourceDisplay(showPerSec: true, amount: bitsResource.amount, perSecond: bitsResource.perSecond, label: "Bits", icon: "square")
                if gameState.model.quantumUnlocked, let qubits = qubitsResource {
                    Divider().background(Color.white.opacity(0.3))
                    resourceDisplay(showPerSec: true,amount: qubits.amount, perSecond: qubits.perSecond, label: "Qubits", icon: "atom")
                }
                Divider().background(Color.white.opacity(0.3))
                resourceDisplay(showPerSec: false,amount: Double(gameState.model.prestigePoints), perSecond: 0, label: "Prestige Points", icon: "star.fill")
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
    
    private func resourceDisplay(showPerSec: Bool, amount: Double, perSecond: Double, label: String, icon: String) -> some View {
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
                    if showPerSec{
                        Text("\(gameState.formatNumber(perSecond))/s")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
    }
}

struct PrestigeUpgradesList: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        List {
            ForEach(gameState.model.prestigeUpgrades.sorted(by: { $1.cost > $0.cost })) { upgrade in
                PrestigeUpgradeRow(gameState: gameState, upgrade: upgrade,
                                   canBuy: gameState.canBuyPrestigeUpgrade(upgrade)) {
                    gameState.buyPrestigeUpgrade(upgrade)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct PrestigeUpgradeRow: View {
    @ObservedObject var gameState: GameState
    let upgrade: PrestigeUpgradeModel
    let canBuy: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: upgrade.icon)
                .font(.title)
            VStack(alignment: .leading) {
                Text(upgrade.name).font(.headline)
                Text(upgrade.overview).font(.subheadline)
            }
            Spacer()
            VStack {
                if upgrade.bought {
                    Text("Purchased")
                        .foregroundColor(.green)
                        .font(.caption)
                } else {
                    Button("Buy", action: action)
                        .buttonStyle(BorderlessButtonStyle())
                        .disabled(!canBuy)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(canBuy ? .gold : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                    
                    Text("\(upgrade.cost) \(upgrade.cost > 1 ? "Prestige Points" : "Prestige Point")")
                        .font(.caption)
                        .foregroundColor(canBuy ? .gold : .gray)
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
                    return gameState.factoryCount(name: "Personal Computer") >= 1
                case "Cooling System Upgrade":
                    return gameState.factoryCount(name: "Personal Computer") >= 10
                case "Storage Upgrade":
                    return gameState.factoryCount(name: "Personal Computer") >= 15
                case "Processor Overclock":
                    return gameState.factoryCount(name: "Workstation") >= 10
                case "RAM Expansion":
                    return gameState.factoryCount(name: "Workstation") >= 25
                case "Graphics Accelerator":
                    return gameState.factoryCount(name: "Workstation") >= 50
                case "High-Speed Network Interface":
                    return gameState.factoryCount(name: "Workstation") >= 100
                case "Improved Bandwidth":
                    return gameState.model.totalBitsEarned >= 25000 && gameState.factoryCount(name: "Mini Server") >= 1
                case "Energy Efficiency":
                    return gameState.factoryCount(name: "Mini Server") >= 5
                case "Advanced Cooling System":
                    return gameState.factoryCount(name: "Mini Server") >= 10 && gameState.model.totalBitsEarned >= 50000
                case "Data Compression":
                    return gameState.factoryCount(name: "Mini Server") >= 15 && gameState.model.totalBitsEarned >= 100_000
                case "Security Enhancements":
                    return gameState.factoryCount(name: "Mini Server") >= 20 && gameState.model.totalBitsEarned >= 150_000
                case "High Performance CPUs":
                    return gameState.model.totalBitsEarned >= 100_000 && gameState.factoryCount(name: "Server Rack") >= 1
                case "Solid-State Drives":
                    return gameState.model.totalBitsEarned >= 150_000 && gameState.factoryCount(name: "Server Rack") >= 10
                case "Enhanced Network Interface Cards":
                    return gameState.model.totalBitsEarned >= 200_000 && gameState.factoryCount(name: "Server Rack") >= 15
                case "Power Distribution Unit Upgrade":
                    return gameState.model.totalBitsEarned >= 250_000 && gameState.factoryCount(name: "Server Rack") >= 20
                case "Redundant Array of Independent Disks":
                    return gameState.model.totalBitsEarned >= 300_000 && gameState.factoryCount(name: "Server Rack") >= 25
                case "High-Performance Servers":
                    return gameState.model.totalBitsEarned >= 1_000_000 && gameState.factoryCount(name: "Server Farm") >= 5
                case "Data Center Optimization":
                    return gameState.model.totalBitsEarned >= 1_500_000 && gameState.factoryCount(name: "Server Farm") >= 10
                case "Enhanced Power Supply":
                    return gameState.model.totalBitsEarned >= 2_000_000 && gameState.factoryCount(name: "Server Farm") >= 15
                case "AI-Driven Maintenance":
                    return gameState.model.totalBitsEarned >= 2_500_000 && gameState.factoryCount(name: "Server Farm") >= 20
                case "Scalable Storage Solutions":
                    return gameState.model.totalBitsEarned >= 3_000_000 && gameState.factoryCount(name: "Server Farm") >= 25
                case "Parallel Processing Units":
                    return gameState.model.totalBitsEarned >= 10_000_000 && gameState.factoryCount(name: "Mainframe") >= 5
                case "Enhanced Memory Architecture":
                    return gameState.model.totalBitsEarned >= 15_000_000 && gameState.factoryCount(name: "Mainframe") >= 10
                case "Advanced Cooling Solutions":
                    return gameState.model.totalBitsEarned >= 20_000_000 && gameState.factoryCount(name: "Mainframe") >= 15
                case "High-Speed Data Bus":
                    return gameState.model.totalBitsEarned >= 25_000_000 && gameState.factoryCount(name: "Mainframe") >= 20
                case "Artificial Intelligence Integration":
                    return gameState.model.totalBitsEarned >= 30_000_000 && gameState.factoryCount(name: "Mainframe") >= 25
                case "Enhanced Vector Units":
                            return gameState.model.totalBitsEarned >= 50_000_000 && gameState.factoryCount(name: "Vector Processor") >= 5
                        case "High-Bandwidth Memory":
                            return gameState.model.totalBitsEarned >= 100_000_000 && gameState.factoryCount(name: "Vector Processor") >= 10
                        case "Multi-Core Architecture":
                            return gameState.model.totalBitsEarned >= 200_000_000 && gameState.factoryCount(name: "Vector Processor") >= 15
                        case "Advanced Pipeline Optimization":
                            return gameState.model.totalBitsEarned >= 400_000_000 && gameState.factoryCount(name: "Vector Processor") >= 20
                        case "Quantum-Inspired Algorithms":
                            return gameState.model.totalBitsEarned >= 800_000_000 && gameState.factoryCount(name: "Vector Processor") >= 25
                        case "Enhanced Interconnect":
                            return gameState.model.totalBitsEarned >= 500_000_000 && gameState.factoryCount(name: "Parallel Processing Array") >= 5
                        case "Scalable Architecture":
                            return gameState.model.totalBitsEarned >= 1_000_000_000 && gameState.factoryCount(name: "Parallel Processing Array") >= 10
                        case "Heterogeneous Computing":
                            return gameState.model.totalBitsEarned >= 2_000_000_000 && gameState.factoryCount(name: "Parallel Processing Array") >= 15
                        case "Load Balancing Algorithms":
                            return gameState.model.totalBitsEarned >= 4_000_000_000 && gameState.factoryCount(name: "Parallel Processing Array") >= 20
                        case "Optical Interconnects":
                            return gameState.model.totalBitsEarned >= 8_000_000_000 && gameState.factoryCount(name: "Parallel Processing Array") >= 25
                        case "Advanced Neural Architecture":
                            return gameState.model.totalBitsEarned >= 5_000_000_000 && gameState.factoryCount(name: "Neural Network Computer") >= 5
                        case "Spiking Neural Networks":
                            return gameState.model.totalBitsEarned >= 10_000_000_000 && gameState.factoryCount(name: "Neural Network Computer") >= 10
                        case "Neuromorphic Hardware":
                            return gameState.model.totalBitsEarned >= 20_000_000_000 && gameState.factoryCount(name: "Neural Network Computer") >= 15
                        case "Adaptive Learning Algorithms":
                            return gameState.model.totalBitsEarned >= 40_000_000_000 && gameState.factoryCount(name: "Neural Network Computer") >= 20
                        case "Quantum-Enhanced Machine Learning":
                            return gameState.model.totalBitsEarned >= 80_000_000_000 && gameState.factoryCount(name: "Neural Network Computer") >= 25
                        case "Exascale Computing":
                            return gameState.model.totalBitsEarned >= 50_000_000_000 && gameState.factoryCount(name: "Supercomputer") >= 5
                        case "Advanced Cooling Systems":
                            return gameState.model.totalBitsEarned >= 100_000_000_000 && gameState.factoryCount(name: "Supercomputer") >= 10
                        case "3D Chip Stacking":
                            return gameState.model.totalBitsEarned >= 200_000_000_000 && gameState.factoryCount(name: "Supercomputer") >= 15
                        case "Photonic Computing":
                            return gameState.model.totalBitsEarned >= 400_000_000_000 && gameState.factoryCount(name: "Supercomputer") >= 20
                        case "Quantum-Classical Hybrid":
                            return gameState.model.totalBitsEarned >= 800_000_000_000 && gameState.factoryCount(name: "Supercomputer") >= 25
                    // Quantum Computer Upgrades
                        case "Improved Qubit Coherence":
                            return gameState.factoryCount(name: "Basic Quantum Computer") >= 1
                        case "Enhanced Quantum Gates":
                            return gameState.factoryCount(name: "Basic Quantum Computer") >= 5
                        case "Quantum Error Correction":
                            return gameState.factoryCount(name: "Basic Quantum Computer") >= 10
                        case "Quantum Algorithm Optimization":
                            return gameState.factoryCount(name: "Basic Quantum Computer") >= 15
                        case "Scalable Qubit Architecture":
                            return gameState.factoryCount(name: "Basic Quantum Computer") >= 20

                        case "Enhanced Cooling System":
                            return gameState.factoryCount(name: "Quantum Annealer") >= 1
                        case "Improved Annealing Schedule":
                            return gameState.factoryCount(name: "Quantum Annealer") >= 5
                        case "Increased Qubit Connectivity":
                            return gameState.factoryCount(name: "Quantum Annealer") >= 10
                        case "Quantum Fluctuation Enhancement":
                            return gameState.factoryCount(name: "Quantum Annealer") >= 15
                        case "Hybrid Quantum-Classical Algorithms":
                            return gameState.factoryCount(name: "Quantum Annealer") >= 20

                        case "Enhanced Ion Traps":
                            return gameState.factoryCount(name: "Trapped Ion Quantum Computer") >= 1
                        case "Precision Laser Control":
                            return gameState.factoryCount(name: "Trapped Ion Quantum Computer") >= 5
                        case "Improved Decoherence Protection":
                            return gameState.factoryCount(name: "Trapped Ion Quantum Computer") >= 10
                        case "Multi-Species Ion Systems":
                            return gameState.factoryCount(name: "Trapped Ion Quantum Computer") >= 15
                        case "Modular Ion Trap Architecture":
                            return gameState.factoryCount(name: "Trapped Ion Quantum Computer") >= 20

                        case "Enhanced Flux Control":
                            return gameState.factoryCount(name: "Superconducting Quantum Processor") >= 1
                        case "Microwave Pulse Optimization":
                            return gameState.factoryCount(name: "Superconducting Quantum Processor") >= 5
                        case "Coherence Time Extension":
                            return gameState.factoryCount(name: "Superconducting Quantum Processor") >= 10
                        case "Multi-Level Qubit States":
                            return gameState.factoryCount(name: "Superconducting Quantum Processor") >= 15
                        case "3D Circuit Architecture":
                            return gameState.factoryCount(name: "Superconducting Quantum Processor") >= 20

                        case "Enhanced Braiding Operations":
                            return gameState.factoryCount(name: "Topological Quantum System") >= 1
                        case "Topological Error Suppression":
                            return gameState.factoryCount(name: "Topological Quantum System") >= 5
                        case "Exotic Anyonic States":
                            return gameState.factoryCount(name: "Topological Quantum System") >= 10
                        case "Multi-Layer Topological Circuits":
                            return gameState.factoryCount(name: "Topological Quantum System") >= 15
                        case "Topological Phase Transitions":
                            return gameState.factoryCount(name: "Topological Quantum System") >= 20

                        case "Surface Code Optimization":
                            return gameState.factoryCount(name: "Quantum Error Correction Engine") >= 1
                        case "Real-Time Error Tracking":
                            return gameState.factoryCount(name: "Quantum Error Correction Engine") >= 5
                        case "Adaptive Error Correction":
                            return gameState.factoryCount(name: "Quantum Error Correction Engine") >= 10
                        case "Multi-Level Error Encoding":
                            return gameState.factoryCount(name: "Quantum Error Correction Engine") >= 15
                        case "Hardware-Efficient Error Correction":
                            return gameState.factoryCount(name: "Quantum Error Correction Engine") >= 20

                        case "Quantum Repeater Enhancement":
                            return gameState.factoryCount(name: "Quantum Network Node") >= 1
                        case "Quantum Cryptography Protocols":
                            return gameState.factoryCount(name: "Quantum Network Node") >= 5
                        case "Multi-Node Entanglement":
                            return gameState.factoryCount(name: "Quantum Network Node") >= 10
                        case "Quantum-Classical Interface":
                            return gameState.factoryCount(name: "Quantum Network Node") >= 15
                        case "Global Quantum Network":
                            return gameState.factoryCount(name: "Quantum Network Node") >= 20

                        case "Expanded Qubit Array":
                            return gameState.factoryCount(name: "Quantum Simulator Array") >= 1
                        case "Advanced Lattice Configurations":
                            return gameState.factoryCount(name: "Quantum Simulator Array") >= 5
                        case "Quantum Dynamics Accelerator":
                            return gameState.factoryCount(name: "Quantum Simulator Array") >= 10
                        case "Tensor Network Coprocessor":
                            return gameState.factoryCount(name: "Quantum Simulator Array") >= 15
                        case "Holographic Quantum Simulation":
                            return gameState.factoryCount(name: "Quantum Simulator Array") >= 20

                        case "Advanced Error Correction":
                            return gameState.factoryCount(name: "Universal Fault-Tolerant Quantum Computer") >= 1
                        case "Topological Qubit Enhancement":
                            return gameState.factoryCount(name: "Universal Fault-Tolerant Quantum Computer") >= 5
                        case "Multi-Dimensional Quantum Gates":
                            return gameState.factoryCount(name: "Universal Fault-Tolerant Quantum Computer") >= 10
                        case "Quantum Circuit Optimization":
                            return gameState.factoryCount(name: "Universal Fault-Tolerant Quantum Computer") >= 15
                        case "Unlimited Coherence Time":
                            return gameState.factoryCount(name: "Universal Fault-Tolerant Quantum Computer") >= 20

                        case "Multiverse Tap":
                            return gameState.factoryCount(name: "Quantum Multiverse Engine") >= 1
                        case "Inter-Universe Coherence":
                            return gameState.factoryCount(name: "Quantum Multiverse Engine") >= 5
                        case "Multiverse Seal Capacitor":
                            return gameState.factoryCount(name: "Quantum Multiverse Engine") >= 10
                        case "Quantum Tornado Harmonizer":
                            return gameState.factoryCount(name: "Quantum Multiverse Engine") >= 15
                        case "Multiverse Hurricane Unleashed":
                            return gameState.factoryCount(name: "Quantum Multiverse Engine") >= 20

                        case "Quantum Cloud Expansion":
                            return gameState.factoryCount(name: "Distributed Quantum Cloud") >= 1
                        case "Quantum Teleportation Network":
                            return gameState.factoryCount(name: "Distributed Quantum Cloud") >= 5
                        case "Advanced Hybrid Quantum-Classical Algorithms":
                            return gameState.factoryCount(name: "Distributed Quantum Cloud") >= 10
                        case "Dynamic Resource Allocation":
                            return gameState.factoryCount(name: "Distributed Quantum Cloud") >= 15
                        case "Quantum Internet Protocol":
                            return gameState.factoryCount(name: "Distributed Quantum Cloud") >= 20

                        case "Quantum Neural Networks":
                            return gameState.factoryCount(name: "Quantum AI Nexus") >= 1
                        case "Quantum Tensor Processing":
                            return gameState.factoryCount(name: "Quantum AI Nexus") >= 5
                        case "Quantum Reinforcement Learning":
                            return gameState.factoryCount(name: "Quantum AI Nexus") >= 10
                        case "Quantum Semantic Networks":
                            return gameState.factoryCount(name: "Quantum AI Nexus") >= 15
                        case "Quantum Cognitive Architecture":
                            return gameState.factoryCount(name: "Quantum AI Nexus") >= 20

                        case "Expanded Hybrid Processing Units":
                            return gameState.factoryCount(name: "Quantum-Classical Hybrid Megastructure") >= 1
                        case "Quantum-Classical Interface Optimization":
                            return gameState.factoryCount(name: "Quantum-Classical Hybrid Megastructure") >= 5
                        case "Modular Quantum Expansion":
                            return gameState.factoryCount(name: "Quantum-Classical Hybrid Megastructure") >= 10
                        case "Neuromorphic Quantum Processors":
                            return gameState.factoryCount(name: "Quantum-Classical Hybrid Megastructure") >= 15
                        case "Exascale Quantum-Classical Integration":
                            return gameState.factoryCount(name: "Quantum-Classical Hybrid Megastructure") >= 20

                        case "Dimensional Resonance Tuning":
                            return gameState.factoryCount(name: "Quantum Dimension Gateway") >= 1
                        case "Multiversal Qubit Entanglement":
                            return gameState.factoryCount(name: "Quantum Dimension Gateway") >= 5
                        case "Hyperdimensional Quantum Circuits":
                            return gameState.factoryCount(name: "Quantum Dimension Gateway") >= 10
                        case "Quantum Dimension Stabilizers":
                            return gameState.factoryCount(name: "Quantum Dimension Gateway") >= 15
                        case "Dimension Harmony Resonator":
                            return gameState.factoryCount(name: "Quantum Dimension Gateway") >= 20

                        case "Stellar Qubit Array":
                            return gameState.factoryCount(name: "Cosmic Quantum Computer") >= 1
                        case "Galactic Entanglement Network":
                            return gameState.factoryCount(name: "Cosmic Quantum Computer") >= 5
                        case "Supernova Quantum Accelerator":
                            return gameState.factoryCount(name: "Cosmic Quantum Computer") >= 10
                        case "Black Hole Information Processor":
                            return gameState.factoryCount(name: "Cosmic Quantum Computer") >= 15
                        case "Universal Quantum Fabric Manipulator":
                            return gameState.factoryCount(name: "Cosmic Quantum Computer") >= 20

                        case "Planck Length Qubit Miniaturization":
                            return gameState.factoryCount(name: "Planck-Scale Quantum Processor") >= 1
                        case "Quantum Foam Stabilizer":
                            return gameState.factoryCount(name: "Planck-Scale Quantum Processor") >= 5
                        case "Quantum Gravity Integrator":
                            return gameState.factoryCount(name: "Planck-Scale Quantum Processor") >= 10
                        case "Spacetime Curvature Processor":
                            return gameState.factoryCount(name: "Planck-Scale Quantum Processor") >= 15
                        case "Unified Field Theory Computer":
                            return gameState.factoryCount(name: "Planck-Scale Quantum Processor") >= 20
                

                case "Quantum Clicker":
                    return gameState.model.quantumUnlocked
                default:
                    return true
                }
            }
        }

    private func canBuy(_ upgrade: UpgradeModel) -> Bool {
        if upgrade.costResourceType == "Qubits" {
            return gameState.model.resources.first(where: { $0.name == "Qubits" })?.amount ?? 0 >= upgrade.cost
        } else {
            return gameState.model.resources.first(where: { $0.name == "Bits" })?.amount ?? 0 >= upgrade.cost
        }
        
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
                Text(upgrade.overview).font(.subheadline)
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
                Text("\(gameState.formatNumber(upgrade.cost)) \(upgrade.costResourceType)")
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
        let classicalFactories = gameState.model.factories.filter { factory in
            !["Basic Quantum Computer", "Quantum Annealer", "Trapped Ion Quantum Computer",
              "Superconducting Quantum Processor", "Topological Quantum System",
              "Quantum Error Correction Engine", "Quantum Network Node", "Quantum Simulator Array",
              "Universal Fault-Tolerant Quantum Computer", "Quantum Multiverse Engine",
              "Distributed Quantum Cloud", "Quantum AI Nexus",
              "Quantum-Classical Hybrid Megastructure", "Quantum Dimension Gateway",
              "Cosmic Quantum Computer", "Planck-Scale Quantum Processor"].contains(factory.name)
        }
        let sortedClassical = classicalFactories.sorted(by: { $0.initialCost < $1.initialCost })
        
        if gameState.model.quantumUnlocked {
            let quantumFactories = gameState.model.factories.filter { factory in
                ["Basic Quantum Computer", "Quantum Annealer", "Trapped Ion Quantum Computer",
                 "Superconducting Quantum Processor", "Topological Quantum System",
                 "Quantum Error Correction Engine", "Quantum Network Node", "Quantum Simulator Array",
                 "Universal Fault-Tolerant Quantum Computer", "Quantum Multiverse Engine",
                 "Distributed Quantum Cloud", "Quantum AI Nexus",
                 "Quantum-Classical Hybrid Megastructure", "Quantum Dimension Gateway",
                 "Cosmic Quantum Computer", "Planck-Scale Quantum Processor"].contains(factory.name)
            }
            let sortedQuantum = quantumFactories.sorted(by: { $0.initialCost < $1.initialCost })
            return sortedClassical + sortedQuantum
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
