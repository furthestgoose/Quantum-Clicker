import Foundation
import SwiftData
import BackgroundTasks



@Model
class GameStateModel: Identifiable{
    let id: UUID
    var lastUpdateTime: Date = Date()
    var quantumUnlocked: Bool
    var personalComputerUnlocked: Bool
    var prestigePoints: Int = 0
    var totalBitsEarned: Double = 0
    var totalQubitsEarned: Double = 0
    var prestigeMultiplier: Double = 1.0
    var offlineEfficiency: Double?
    var timesPrestiged: Int = 0
    var extendedOffline: Bool = false
    var quickReset: Bool = false
    var availablePrestigePoints: Int {
        return Int(totalQubitsEarned / (quickReset ? 1e6 : 1e12))
    }
    @Relationship(deleteRule: .cascade) var achievements: [AchievementModel]
    @Relationship(deleteRule: .cascade) var resources: [ResourceModel]
    @Relationship(deleteRule: .cascade) var upgrades: [UpgradeModel]
    @Relationship(deleteRule: .cascade) var factories: [FactoryModel]
    @Relationship(deleteRule: .cascade) var prestigeUpgrades: [PrestigeUpgradeModel]
    var factoryEfficiencyMultiplier: Double = 1.0
    
    init(id: UUID = UUID(), quantumUnlocked: Bool = false, personalComputerUnlocked: Bool = false,timesPrestiged: Int = 0) {
        self.id = id
        self.quantumUnlocked = quantumUnlocked
        self.personalComputerUnlocked = personalComputerUnlocked
        self.resources = []
        self.upgrades = []
        self.factories = []
        self.prestigeUpgrades = []
        self.achievements = []
        self.timesPrestiged = timesPrestiged
    }
}

// MARK: - GameState Class

class GameState: ObservableObject {
    @Published var model: GameStateModel
    private var modelContext: ModelContext
    
    init(model: GameStateModel, modelContext: ModelContext) {
        self.model = model
        self.modelContext = modelContext
                
                // Check if we need to reset after a prestige event
                if model.prestigePoints > 0 && !model.upgrades.isEmpty {
                    resetAfterPrestige()
                } else {
                    initializeIfNeeded()
                }
                
                scheduleAppRefresh()
    }
    
    func resetAfterPrestige() {
            model.upgrades.removeAll()
            model.factories.removeAll()
            initializeUpgrades()
            initializeFactories()
            checkAchievements()
            // Make sure to save this state
            saveGameState()
        }
        
        private func initializeIfNeeded() {
            if model.resources.isEmpty {
                initializeResources()
            }
            if model.upgrades.isEmpty {
                initializeUpgrades()
            }
            if model.factories.isEmpty {
                initializeFactories()
            }
            if model.prestigeUpgrades.isEmpty {
                initializePrestigeUpgrades()
            }
            if model.achievements.isEmpty{
                initializeAchievements()
            }
        }
    
    func saveGameState() {
            do {
                try modelContext.save()
            } catch {
                print("Error saving game state: \(error.localizedDescription)")
            }
        }
    
    private func initializeResources() {
        model.resources = [
            ResourceModel(name: "Bits", amount: 0, perClick: 0.1, perSecond: 0),
            ResourceModel(name: "Qubits", amount: 0, perClick: 0, perSecond: 0)
        ]
    }
    
    func initializeAchievements() {
        model.achievements = [
                        AchievementModel(id: "Myfirstbit", title: "My First Bit", description: "Earn 1 bit", isUnlocked: false, order: 0),
                        AchievementModel(id: "Automation", title: "My System", description: "Own 1 Computer", isUnlocked: false, order: 1),
                        AchievementModel(id: "Doublebit", title: "Double Digits", description: "Earn 10 bits", isUnlocked: false, order: 2),
                        AchievementModel(id: "Automation2", title: "Advanced Scraping", description: "Own 10 Computers", isUnlocked: false, order: 3),
                        AchievementModel(id: "Triplebit", title: "Triple Digits", description: "Earn 100 bits", isUnlocked: false, order: 4),
                        AchievementModel(id: "Quadbit", title: "Quadruple Digits", description: "Earn 1000 bits", isUnlocked: false, order: 5),
                        AchievementModel(id: "Automation3", title: "Mass Scraping", description: "Own 50 Computers", isUnlocked: false, order: 6),
                        AchievementModel(id: "10kb", title: "10,000 bits", description: "Earn 10000 bits", isUnlocked: false, order: 7),
                        AchievementModel(id: "factoryTycoon", title: "Computer Tycoon", description: "Own 100 Computers", isUnlocked: false, order: 8),
                        AchievementModel(id: "datac", title: "Data Conglomerate", description: "Earn 100000 bits", isUnlocked: false, order: 9),
                        AchievementModel(id: "bitMillionaire", title: "Bit Millionaire", description: "Earn 1,000,000 bits", isUnlocked: false, order: 10),
                        AchievementModel(id: "bitMultiMillionaire", title: "Bit Multi Millionaire", description: "Earn 2,000,000 bits", isUnlocked: false, order: 11),
                        AchievementModel(id: "bit500m", title: "Data King", description: "Earn 500,000,000 bits", isUnlocked: false, order: 12),
                        AchievementModel(id: "bit1b", title: "Bit Billionaire", description: "Earn 1,000,000,000 bits", isUnlocked: false, order: 13),
                        AchievementModel(id: "bit1t", title: "Bit Trillionaire", description: "Earn 1,00,000,000,000 bits", isUnlocked: false, order: 14),
                        AchievementModel(id: "quantumLeap", title: "Quantum Leap", description: "Unlock quantum computing", isUnlocked: false, order: 15),
                        AchievementModel(id: "Quantum Era", title: "Welcome to the quantum era", description: "earn 1 qubit", isUnlocked: false, order: 16),
                        AchievementModel(id: "Quantum 10qb", title: "Quantum Explorer", description: "earn 10 qubits", isUnlocked: false, order: 17),
                        AchievementModel(id: "Quantum 100qb", title: "Quantum Adventurer", description: "earn 100 qubits", isUnlocked: false, order: 18),
                        AchievementModel(id: "Quantum 1000qb", title: "Quantum Conquerer", description: "earn 1,000 qubits", isUnlocked: false, order: 19),
                        AchievementModel(id: "Quantum 10kqb", title: "Quantum Scientist", description: "earn 10,000 qubits", isUnlocked: false, order: 20),
                        AchievementModel(id: "Quantum 100kqb", title: "Quantum Executive", description: "earn 100,000 qubits", isUnlocked: false, order: 21),
                        AchievementModel(id: "Quantum 1mqb", title: "Quantum Company", description: "earn 1,000,000 qubits", isUnlocked: false, order: 22),
                        AchievementModel(id: "Quantum 10mqb", title: "Quantum Mega Company", description: "earn 10,000,000 qubits", isUnlocked: false, order: 23),
                        AchievementModel(id: "Quantum 100mqb", title: "Quantum Monopoly", description: "earn 100,000,000 qubits", isUnlocked: false, order: 24),
                        AchievementModel(id: "Quantum 1bqb", title: "Quantum Clicker", description: "earn 1,000,000,000 qubits", isUnlocked: false, order: 25),
                        AchievementModel(id: "Quantum 1tqb", title: "Quantum Trillionaire", description: "earn 1,000,000,000,000 qubits", isUnlocked: false, order: 25),
                        AchievementModel(id: "prestigeMaster", title: "Prestige Master", description: "Prestige 5 times", isUnlocked: false, order: 26),
                    ]
    }
    
    private func initializeUpgrades() {
            model.upgrades = [
                UpgradeModel(icon: "creditcard", name: "Premium Licence", cost: 20, costResourceType: "Bits", description: "You buy the Premium Software Licence \nIncrease bits per click by \(formatNumber(0.1 * model.prestigeMultiplier))", upgradeType: .resourcePerClick("Bits", 0.1)),
                
                UpgradeModel(icon: "cursorarrow.click", name: "Double Clicks", cost: 100, costResourceType: "Bits", description: "Double the number of bits per click", upgradeType: .other("Double Clicks")),
                
                UpgradeModel(icon: "cursorarrow.click.badge.clock", name: "Autoclicker", cost: 500, costResourceType: "Bits", description: "Automatically generate \(formatNumber(0.1 * model.prestigeMultiplier)) bits per second", upgradeType: .resourcePerSecond("Bits", 0.1)),
                
                UpgradeModel(icon: "cursorarrow.click.2", name: "Triple Clicks", cost: 2000, costResourceType: "Bits", description: "Triple the number of bits per click", upgradeType: .other("Triple Clicks")),
                UpgradeModel(icon: "dot.circle.and.cursorarrow", name: "Precision Clicking", cost: 10000, costResourceType: "Bits", description: "Increase bits per click by \(formatNumber(0.2 * model.prestigeMultiplier)) through improved accuracy" , upgradeType: .resourcePerClick("Bits", 0.2)),
                UpgradeModel(icon: "cursorarrow.motionlines", name: "Quantum Clicker", cost: 1000000, costResourceType: "Bits", description: "Each click has a small chance to produce a qubit", upgradeType: .resourcePerClick("Qubits", 0.1)),
                UpgradeModel(icon: "apple.terminal", name: "Automated Clicking Software", cost: 5000000, costResourceType: "Bits", description: "Increase the autoclicker speed to \(formatNumber(0.2 * model.prestigeMultiplier)) bits per second",upgradeType: .resourcePerSecond("Bits", 0.2)),
                UpgradeModel(icon: "network", name: "Network Clicks", cost: 20000000, costResourceType: "Bits", description: "Each click generates bits for every connected device, increasing bits per click by \(formatNumber(0.5 * model.prestigeMultiplier))", upgradeType: .resourcePerClick("Bits", 0.5)),
                UpgradeModel(icon: "memorychip", name: "RAM Upgrade", cost: 1000, costResourceType: "Bits", description: "Faster RAM is installed \nPersonal Computers are 1.5x faster", upgradeType: .factoryEfficiency("Personal Computer", 1.5)),
                UpgradeModel(icon: "cpu", name: "CPU Upgrade", cost: 5000, costResourceType: "Bits", description: "The CPU is upgraded \nPersonal Computers are 2x faster", upgradeType: .factoryEfficiency("Personal Computer", 2.0)),
                UpgradeModel(icon: "fan", name: "Cooling System Upgrade", cost: 20000, costResourceType: "Bits", description: "The Cooling System is upgraded \nPersonal Computers are 1.25x faster", upgradeType: .factoryEfficiency("Personal Computer", 1.25)),
                UpgradeModel(icon: "externaldrive", name: "Storage Upgrade", cost: 100000, costResourceType: "Bits", description: "The Storage is upgraded \nPersonal Computers are 1.5x faster", upgradeType: .factoryEfficiency("Personal Computer", 1.5)),
                UpgradeModel(icon: "clock.arrow.circlepath", name: "Processor Overclock", cost: 10000, costResourceType: "Bits", description: "Enhanced CPU performance \nWorkstations are 1.5x faster", upgradeType: .factoryEfficiency("Workstation", 1.5)),
                UpgradeModel(icon: "memorychip", name: "RAM Expansion", cost: 50000, costResourceType: "Bits", description: "Increased memory capacity \nWorkstations are 2x faster", upgradeType: .factoryEfficiency("Workstation", 2)),
                UpgradeModel(icon: "gamecontroller", name: "Graphics Accelerator", cost: 200000, costResourceType: "Bits", description: "Advanced GPU for improved processing \nWorkstations are 1.25x faster", upgradeType: .factoryEfficiency("Workstation", 1.25)),
                UpgradeModel(icon: "network", name: "High-Speed Network Interface", cost: 1000000, costResourceType: "Bits", description: "Improved data transfer capabilities \nWorkstations are 1.5x faster", upgradeType: .factoryEfficiency("Workstation", 1.5)),
                UpgradeModel(icon: "network", name: "Improved Bandwidth", cost: 500, costResourceType: "Bits", description: "Boost the bandwidth to handle more data \nMini Servers are 2x faster", upgradeType: .factoryEfficiency("Mini Server", 2)),
                UpgradeModel(icon: "bolt", name: "Energy Efficiency", cost: 750, costResourceType: "Bits", description: "Make the current amount of energy used go further \nMini Servers are 50% faster", upgradeType: .factoryEfficiency("Mini Server", 1.5)),
                UpgradeModel(icon: "fan", name: "Advanced Cooling System", cost: 2000, costResourceType: "Bits", description: "Install a superior cooling system to enhance performance. \nMini Servers are 75% faster", upgradeType: .factoryEfficiency("Mini Server", 1.75)),
                UpgradeModel(icon: "externaldrive.badge.checkmark", name: "Data Compression", cost: 2000, costResourceType: "Bits", description: "Implement advanced data compression algorithms. \nMini Servers are 50% faster", upgradeType: .factoryEfficiency("Mini Server", 1.5)),
                UpgradeModel(icon: "lock.shield", name: "Security Enhancements", cost: 2000, costResourceType: "Bits", description: "Enhance the server's security to minimize downtime, ensuring a stable bit generation rate. \nMini Servers are 3x faster", upgradeType: .factoryEfficiency("Mini Server", 3)),
                UpgradeModel(icon: "cpu", name: "High Performance CPUs", cost: 10000, costResourceType: "Bits", description: "Install top-of-the-line processors \nServer Racks are 2x faster", upgradeType: .factoryEfficiency("Server Rack", 2)),
                UpgradeModel(icon: "externaldrive.badge.plus", name: "Solid-State Drives", cost: 15000, costResourceType: "Bits", description: "Switch to SSDs for faster data access \nServer Racks are 50% faster", upgradeType: .factoryEfficiency("Server Rack", 1.5)),
                UpgradeModel(icon: "sdcard", name: "Enhanced Network Interface Cards", cost: 20000, costResourceType: "Bits", description: "Install advanced NICs to optimize data transfer \nServer Racks are 75% faster", upgradeType: .factoryEfficiency("Server Rack", 1.75)),
                UpgradeModel(icon: "bolt.batteryblock", name: "Power Distribution Unit Upgrade", cost: 25000, costResourceType: "Bits", description: "Enhance the power distribution system \nServer Racks are 2x faster", upgradeType: .factoryEfficiency("Server Rack", 2)),
                UpgradeModel(icon: "platter.2.filled.iphone", name: "Redundant Array of Independent Disks", cost: 30_000, costResourceType: "Bits", description: "Set up RAID for better performance and reliability \nServer Racks are 3x faster", upgradeType: .factoryEfficiency("Server Rack", 3)),
                UpgradeModel(icon: "hammer", name: "High-Performance Servers", cost: 100_000, costResourceType: "Bits", description: "Enhance the farm with top-tier servers \nServer Farms are 2x faster", upgradeType: .factoryEfficiency("Server Farm", 2)),
                UpgradeModel(icon: "map", name: "Data Center Optimization", cost: 150_000, costResourceType: "Bits", description: "Optimize data center operations for better efficiency \nServer Farms are 50% faster", upgradeType: .factoryEfficiency("Server Farm", 1.5)),
                UpgradeModel(icon: "bolt.ring.closed", name: "Enhanced Power Supply", cost: 200_000, costResourceType: "Bits", description: "Ensure uninterrupted performance with an advanced power supply \nServer Farms are 75% faster", upgradeType: .factoryEfficiency("Server Farm", 1.75)),
                UpgradeModel(icon: "hand.point.up.braille.fill", name: "AI-Driven Maintenance", cost: 250_000, costResourceType: "Bits", description: "Use AI to anticipate and resolve issues proactively \nServer Farms are 2x faster", upgradeType: .factoryEfficiency("Server Farm", 2)),
                UpgradeModel(icon: "shippingbox.fill", name: "Scalable Storage Solutions", cost: 300_000, costResourceType: "Bits", description: "Adopt scalable storage technologies for improved data handling \nServer Farms are 3x faster", upgradeType: .factoryEfficiency("Server Farm", 3)),
                UpgradeModel(icon: "square.and.line.vertical.and.square", name: "Parallel Processing Units", cost: 1_000_000, costResourceType: "Bits", description: "Integrate advanced parallel processing units \nMainframes are 2x faster", upgradeType: .factoryEfficiency("Mainframe", 2)),
                UpgradeModel(icon: "square.grid.3x1.below.line.grid.1x2", name: "Enhanced Memory Architecture", cost: 1_500_000, costResourceType: "Bits", description: "Revamp the memory architecture to boost data handling efficiency \nMainframes are 50% faster", upgradeType: .factoryEfficiency("Mainframe", 1.5)),
                UpgradeModel(icon: "air.conditioner.vertical", name: "Advanced Cooling Solutions", cost: 2_000_000, costResourceType: "Bits", description: "Install an advanced cooling system to maintain optimal performance \nMainframes are 75% faster", upgradeType: .factoryEfficiency("Mainframe", 1.75)),
                UpgradeModel(icon: "bus", name: "High-Speed Data Bus", cost: 2_500_000, costResourceType: "Bits", description: "Upgrade the data bus for rapid internal communication \nMainframes are 2x faster", upgradeType: .factoryEfficiency("Mainframe", 2)),
                UpgradeModel(icon: "brain.filled.head.profile", name: "Artificial Intelligence Integration", cost: 3_000_000, costResourceType: "Bits", description: "Incorporate AI to optimize data processing \nMainframes are 3x faster", upgradeType: .factoryEfficiency("Mainframe", 3)),
                // Vector Processor Upgrades
                UpgradeModel(icon: "cpu", name: "Enhanced Vector Units", cost: 50000000, costResourceType: "Bits", description: "Upgrade vector processing units \nVector Processors are 1.5x faster", upgradeType: .factoryEfficiency("Vector Processor", 1.5)),
                UpgradeModel(icon: "memorychip", name: "High-Bandwidth Memory", cost: 100000000, costResourceType: "Bits", description: "Implement HBM for faster data access \nVector Processors are 1.75x faster", upgradeType: .factoryEfficiency("Vector Processor", 1.75)),
                UpgradeModel(icon: "rectangle.3.group", name: "Multi-Core Architecture", cost: 200000000, costResourceType: "Bits", description: "Implement multi-core design \nVector Processors are 2x faster", upgradeType: .factoryEfficiency("Vector Processor", 2.0)),
                UpgradeModel(icon: "waveform.path.ecg", name: "Advanced Pipeline Optimization", cost: 400000000, costResourceType: "Bits", description: "Optimize instruction pipeline \nVector Processors are 2.25x faster", upgradeType: .factoryEfficiency("Vector Processor", 2.25)),
                UpgradeModel(icon: "bolt.horizontal", name: "Quantum-Inspired Algorithms", cost: 800000000, costResourceType: "Bits", description: "Implement quantum-inspired classical algorithms \nVector Processors are 3x faster", upgradeType: .factoryEfficiency("Vector Processor", 3.0)),

                // Parallel Processing Array Upgrades
                UpgradeModel(icon: "network", name: "Enhanced Interconnect", cost: 500000000, costResourceType: "Bits", description: "Upgrade inter-processor communication \nParallel Processing Arrays are 1.5x faster", upgradeType: .factoryEfficiency("Parallel Processing Array", 1.5)),
                UpgradeModel(icon: "rectangle.split.3x3", name: "Scalable Architecture", cost: 1000000000, costResourceType: "Bits", description: "Implement a more scalable design \nParallel Processing Arrays are 1.75x faster", upgradeType: .factoryEfficiency("Parallel Processing Array", 1.75)),
                UpgradeModel(icon: "cpu", name: "Heterogeneous Computing", cost: 2000000000, costResourceType: "Bits", description: "Integrate CPUs and GPUs \nParallel Processing Arrays are 2x faster", upgradeType: .factoryEfficiency("Parallel Processing Array", 2.0)),
                UpgradeModel(icon: "chart.bar", name: "Load Balancing Algorithms", cost: 4000000000, costResourceType: "Bits", description: "Implement advanced load balancing \nParallel Processing Arrays are 2.25x faster", upgradeType: .factoryEfficiency("Parallel Processing Array", 2.25)),
                UpgradeModel(icon: "rays", name: "Optical Interconnects", cost: 8000000000, costResourceType: "Bits", description: "Use light for inter-processor communication \nParallel Processing Arrays are 3x faster", upgradeType: .factoryEfficiency("Parallel Processing Array", 3.0)),

                // Neural Network Computer Upgrades
                UpgradeModel(icon: "brain", name: "Advanced Neural Architecture", cost: 5000000000, costResourceType: "Bits", description: "Implement state-of-the-art neural network designs \nNeural Network Computers are 1.5x faster", upgradeType: .factoryEfficiency("Neural Network Computer", 1.5)),
                UpgradeModel(icon: "waveform.path", name: "Spiking Neural Networks", cost: 10000000000, costResourceType: "Bits", description: "Integrate spiking neural network models \nNeural Network Computers are 1.75x faster", upgradeType: .factoryEfficiency("Neural Network Computer", 1.75)),
                UpgradeModel(icon: "cpu", name: "Neuromorphic Hardware", cost: 20000000000, costResourceType: "Bits", description: "Use brain-inspired computing hardware \nNeural Network Computers are 2x faster", upgradeType: .factoryEfficiency("Neural Network Computer", 2.0)),
                UpgradeModel(icon: "chart.xyaxis.line", name: "Adaptive Learning Algorithms", cost: 40000000000, costResourceType: "Bits", description: "Implement advanced adaptive learning techniques \nNeural Network Computers are 2.25x faster", upgradeType: .factoryEfficiency("Neural Network Computer", 2.25)),
                UpgradeModel(icon: "ladybug", name: "Quantum-Enhanced Machine Learning", cost: 80000000000, costResourceType: "Bits", description: "Integrate quantum algorithms for machine learning \nNeural Network Computers are 3x faster", upgradeType: .factoryEfficiency("Neural Network Computer", 3.0)),

                // Supercomputer Upgrades
                UpgradeModel(icon: "cpu", name: "Exascale Computing", cost: 50000000000, costResourceType: "Bits", description: "Achieve exascale performance \nSupercomputers are 1.5x faster", upgradeType: .factoryEfficiency("Supercomputer", 1.5)),
                UpgradeModel(icon: "thermometer.sun", name: "Advanced Cooling Systems", cost: 100000000000, costResourceType: "Bits", description: "Implement cutting-edge cooling technology \nSupercomputers are 1.75x faster", upgradeType: .factoryEfficiency("Supercomputer", 1.75)),
                UpgradeModel(icon: "rectangle.connected.to.line.below", name: "3D Chip Stacking", cost: 200000000000, costResourceType: "Bits", description: "Use 3D chip stacking for higher density \nSupercomputers are 2x faster", upgradeType: .factoryEfficiency("Supercomputer", 2.0)),
                UpgradeModel(icon: "network", name: "Photonic Computing", cost: 400000000000, costResourceType: "Bits", description: "Integrate photonic components for faster data transfer \nSupercomputers are 2.25x faster", upgradeType: .factoryEfficiency("Supercomputer", 2.25)),
                UpgradeModel(icon: "atom", name: "Quantum-Classical Hybrid", cost: 800000000000, costResourceType: "Bits", description: "Integrate quantum processors with classical supercomputers \nSupercomputers are 3x faster", upgradeType: .factoryEfficiency("Supercomputer", 3.0)),

                // Basic Quantum Computer Upgrades
                UpgradeModel(icon: "atom", name: "Improved Qubit Coherence", cost: 100, costResourceType: "Qubits", description: "Extend qubit coherence time \nBasic Quantum Computers are 1.5x faster", upgradeType: .factoryEfficiency("Basic Quantum Computer", 1.5)),
                UpgradeModel(icon: "waveform", name: "Enhanced Quantum Gates", cost: 200, costResourceType: "Qubits", description: "Implement more precise quantum gates \nBasic Quantum Computers are 1.75x faster", upgradeType: .factoryEfficiency("Basic Quantum Computer", 1.75)),
                UpgradeModel(icon: "chart.bar", name: "Quantum Error Correction", cost: 400, costResourceType: "Qubits", description: "Implement basic quantum error correction \nBasic Quantum Computers are 2x faster", upgradeType: .factoryEfficiency("Basic Quantum Computer", 2.0)),
                UpgradeModel(icon: "function", name: "Quantum Algorithm Optimization", cost: 800, costResourceType: "Qubits", description: "Optimize quantum algorithms for better performance \nBasic Quantum Computers are 2.25x faster", upgradeType: .factoryEfficiency("Basic Quantum Computer", 2.25)),
                UpgradeModel(icon: "cpu", name: "Scalable Qubit Architecture", cost: 1600, costResourceType: "Qubits", description: "Implement a more scalable qubit design \nBasic Quantum Computers are 3x faster", upgradeType: .factoryEfficiency("Basic Quantum Computer", 3.0)),
                // Advanced Quantum Workstation Upgrades
                UpgradeModel(icon: "atom.3", name: "Multi-Qubit Entanglement", cost: 5000, costResourceType: "Qubits", description: "Achieve stable multi-qubit entanglement \nAdvanced Quantum Workstations are 1.5x faster", upgradeType: .factoryEfficiency("Advanced Quantum Workstation", 1.5)),
                UpgradeModel(icon: "waveform.path.ecg", name: "Quantum Gate Fidelity Boost", cost: 10000, costResourceType: "Qubits", description: "Dramatically increase quantum gate fidelity \nAdvanced Quantum Workstations are 1.75x faster", upgradeType: .factoryEfficiency("Basic Quantum Workstation", 1.75)),
                UpgradeModel(icon: "shield.lefthalf.filled", name: "Advanced Error Correction", cost: 20000, costResourceType: "Qubits", description: "Implement sophisticated quantum error correction \nAdvanced Quantum Workstations are 2x faster", upgradeType: .factoryEfficiency("Advanced Quantum Workstation", 2.0)),
                UpgradeModel(icon: "cpu.fill", name: "Quantum-Classical Hybrid Algorithms", cost: 40000, costResourceType: "Qubits", description: "Develop efficient quantum-classical hybrid algorithms \nAdvanced Quantum Workstations are 2.25x faster", upgradeType: .factoryEfficiency("Advanced Quantum Workstation", 2.25)),
                UpgradeModel(icon: "network", name: "Quantum Network Integration", cost: 80000, costResourceType: "Qubits", description: "Integrate quantum workstations into a quantum network \nAdvanced Quantum Workstations are 3x faster", upgradeType: .factoryEfficiency("Advanced Quantum Workstation", 3.0)),
                

                // Quantum Annealer Upgrades
                UpgradeModel(icon: "thermometer.snowflake", name: "Enhanced Cooling System", cost: 10000, costResourceType: "Qubits", description: "Implement advanced cooling for better stability \nQuantum Annealers are 1.5x faster", upgradeType: .factoryEfficiency("Quantum Annealer", 1.5)),
                UpgradeModel(icon: "chart.xyaxis.line", name: "Improved Annealing Schedule", cost: 20000, costResourceType: "Qubits", description: "Optimize the annealing process \nQuantum Annealers are 1.75x faster", upgradeType: .factoryEfficiency("Quantum Annealer", 1.75)),
                UpgradeModel(icon: "square.grid.3x3.fill", name: "Increased Qubit Connectivity", cost: 40000, costResourceType: "Qubits", description: "Enhance qubit interconnections \nQuantum Annealers are 2x faster", upgradeType: .factoryEfficiency("Quantum Annealer", 2.0)),
                UpgradeModel(icon: "waveform.path.ecg", name: "Quantum Fluctuation Enhancement", cost: 80000, costResourceType: "Qubits", description: "Harness quantum fluctuations for better solutions \nQuantum Annealers are 2.25x faster", upgradeType: .factoryEfficiency("Quantum Annealer", 2.25)),
                UpgradeModel(icon: "cpu", name: "Hybrid Quantum-Classical Algorithms", cost: 160000, costResourceType: "Qubits", description: "Implement hybrid algorithms for complex problems \nQuantum Annealers are 3x faster", upgradeType: .factoryEfficiency("Quantum Annealer", 3.0)),

                // Trapped Ion Quantum Computer Upgrades
                UpgradeModel(icon: "bolt", name: "Enhanced Ion Traps", cost: 100000, costResourceType: "Qubits", description: "Improve ion trapping mechanisms \nTrapped Ion Quantum Computers are 1.5x faster", upgradeType: .factoryEfficiency("Trapped Ion Quantum Computer", 1.5)),
                UpgradeModel(icon: "laser.burst", name: "Precision Laser Control", cost: 200000, costResourceType: "Qubits", description: "Implement high-precision lasers for better qubit control \nTrapped Ion Quantum Computers are 1.75x faster", upgradeType: .factoryEfficiency("Trapped Ion Quantum Computer", 1.75)),
                UpgradeModel(icon: "shield", name: "Improved Decoherence Protection", cost: 400000, costResourceType: "Qubits", description: "Enhance protection against decoherence \nTrapped Ion Quantum Computers are 2x faster", upgradeType: .factoryEfficiency("Trapped Ion Quantum Computer", 2.0)),
                UpgradeModel(icon: "arrow.triangle.2.circlepath", name: "Multi-Species Ion Systems", cost: 800000, costResourceType: "Qubits", description: "Use multiple ion species for enhanced functionality \nTrapped Ion Quantum Computers are 2.25x faster", upgradeType: .factoryEfficiency("Trapped Ion Quantum Computer", 2.25)),
                UpgradeModel(icon: "network", name: "Modular Ion Trap Architecture", cost: 1600000, costResourceType: "Qubits", description: "Implement a scalable, modular ion trap design \nTrapped Ion Quantum Computers are 3x faster", upgradeType: .factoryEfficiency("Trapped Ion Quantum Computer", 3.0)),
                
                // Superconducting Quantum Processor Upgrades
                UpgradeModel(icon: "bolt.shield", name: "Enhanced Flux Control", cost: 1000000, costResourceType: "Qubits", description: "Improve magnetic flux control \nSuperconducting Quantum Processors are 1.5x faster", upgradeType: .factoryEfficiency("Superconducting Quantum Processor", 1.5)),
                UpgradeModel(icon: "antenna.radiowaves.left.and.right", name: "Microwave Pulse Optimization", cost: 2000000, costResourceType: "Qubits", description: "Enhance qubit control with precise microwave pulses \nSuperconducting Quantum Processors are 1.75x faster", upgradeType: .factoryEfficiency("Superconducting Quantum Processor", 1.75)),
                UpgradeModel(icon: "clock.arrow.2.circlepath", name: "Coherence Time Extension", cost: 4000000, costResourceType: "Qubits", description: "Extend qubit coherence time \nSuperconducting Quantum Processors are 2x faster", upgradeType: .factoryEfficiency("Superconducting Quantum Processor", 2.0)),
                UpgradeModel(icon: "chart.xyaxis.line", name: "Multi-Level Qubit States", cost: 8000000, costResourceType: "Qubits", description: "Utilize higher energy levels for enhanced processing \nSuperconducting Quantum Processors are 2.25x faster", upgradeType: .factoryEfficiency("Superconducting Quantum Processor", 2.25)),
                UpgradeModel(icon: "rectangle.3.group", name: "3D Circuit Architecture", cost: 16000000, costResourceType: "Qubits", description: "Implement 3D superconducting circuits for improved scalability \nSuperconducting Quantum Processors are 3x faster", upgradeType: .factoryEfficiency("Superconducting Quantum Processor", 3.0)),

                // Topological Quantum System Upgrades
                UpgradeModel(icon: "figure.walk.circle", name: "Enhanced Braiding Operations", cost: 10000000, costResourceType: "Qubits", description: "Improve anyonic braiding techniques \nTopological Quantum Systems are 1.5x faster", upgradeType: .factoryEfficiency("Topological Quantum System", 1.5)),
                UpgradeModel(icon: "shield.lefthalf.filled", name: "Topological Error Suppression", cost: 20000000, costResourceType: "Qubits", description: "Enhance inherent error protection \nTopological Quantum Systems are 1.75x faster", upgradeType: .factoryEfficiency("Topological Quantum System", 1.75)),
                UpgradeModel(icon: "mosaic", name: "Exotic Anyonic States", cost: 40000000, costResourceType: "Qubits", description: "Utilize more complex anyonic states \nTopological Quantum Systems are 2x faster", upgradeType: .factoryEfficiency("Topological Quantum System", 2.0)),
                UpgradeModel(icon: "square.3.layers.3d.down.right", name: "Multi-Layer Topological Circuits", cost: 80000000, costResourceType: "Qubits", description: "Implement multi-layered topological quantum circuits \nTopological Quantum Systems are 2.25x faster", upgradeType: .factoryEfficiency("Topological Quantum System", 2.25)),
                UpgradeModel(icon: "lock.rotation", name: "Topological Phase Transitions", cost: 160000000, costResourceType: "Qubits", description: "Harness topological phase transitions for computation \nTopological Quantum Systems are 3x faster", upgradeType: .factoryEfficiency("Topological Quantum System", 3.0)),

                // Quantum Error Correction Engine Upgrades
                UpgradeModel(icon: "checkmark.shield", name: "Surface Code Optimization", cost: 100000000, costResourceType: "Qubits", description: "Enhance surface code error correction \nQuantum Error Correction Engines are 1.5x faster", upgradeType: .factoryEfficiency("Quantum Error Correction Engine", 1.5)),
                UpgradeModel(icon: "arrow.triangle.2.circlepath", name: "Real-Time Error Tracking", cost: 200000000, costResourceType: "Qubits", description: "Implement continuous error monitoring \nQuantum Error Correction Engines are 1.75x faster", upgradeType: .factoryEfficiency("Quantum Error Correction Engine", 1.75)),
                UpgradeModel(icon: "rectangle.and.hand.point.up.left", name: "Adaptive Error Correction", cost: 400000000, costResourceType: "Qubits", description: "Develop dynamic error correction strategies \nQuantum Error Correction Engines are 2x faster", upgradeType: .factoryEfficiency("Quantum Error Correction Engine", 2.0)),
                UpgradeModel(icon: "square.stack.3d.up", name: "Multi-Level Error Encoding", cost: 800000000, costResourceType: "Qubits", description: "Utilize hierarchical error correction codes \nQuantum Error Correction Engines are 2.25x faster", upgradeType: .factoryEfficiency("Quantum Error Correction Engine", 2.25)),
                UpgradeModel(icon: "cpu", name: "Hardware-Efficient Error Correction", cost: 1600000000, costResourceType: "Qubits", description: "Implement error correction at the hardware level \nQuantum Error Correction Engines are 3x faster", upgradeType: .factoryEfficiency("Quantum Error Correction Engine", 3.0)),
                // Quantum Network Node Upgrades
                UpgradeModel(icon: "network", name: "Quantum Repeater Enhancement", cost: 1000000000, costResourceType: "Qubits", description: "Improve quantum state transmission over long distances \nQuantum Network Nodes are 1.5x faster", upgradeType: .factoryEfficiency("Quantum Network Node", 1.5)),
                UpgradeModel(icon: "lock.icloud", name: "Quantum Cryptography Protocols", cost: 2000000000, costResourceType: "Qubits", description: "Implement advanced quantum key distribution \nQuantum Network Nodes are 1.75x faster", upgradeType: .factoryEfficiency("Quantum Network Node", 1.75)),
                UpgradeModel(icon: "arrow.triangle.branch", name: "Multi-Node Entanglement", cost: 4000000000, costResourceType: "Qubits", description: "Enable simultaneous entanglement across multiple nodes \nQuantum Network Nodes are 2x faster", upgradeType: .factoryEfficiency("Quantum Network Node", 2.0)),
                UpgradeModel(icon: "rectangle.connected.to.line.below", name: "Quantum-Classical Interface", cost: 8000000000, costResourceType: "Qubits", description: "Optimize quantum-classical data conversion \nQuantum Network Nodes are 2.25x faster", upgradeType: .factoryEfficiency("Quantum Network Node", 2.25)),
                UpgradeModel(icon: "globe.americas", name: "Global Quantum Network", cost: 16000000000, costResourceType: "Qubits", description: "Expand node connectivity to a global scale \nQuantum Network Nodes are 3x faster", upgradeType: .factoryEfficiency("Quantum Network Node", 3.0)),

                // Quantum Simulator Array Upgrades
                UpgradeModel(icon: "square.grid.3x3", name: "Expanded Qubit Array", cost: 10000000000, costResourceType: "Qubits", description: "Increase the number of simulated qubits \nQuantum Simulator Arrays are 1.5x faster", upgradeType: .factoryEfficiency("Quantum Simulator Array", 1.5)),
                UpgradeModel(icon: "circle.hexagongrid", name: "Advanced Lattice Configurations", cost: 20000000000, costResourceType: "Qubits", description: "Implement complex qubit lattice structures \nQuantum Simulator Arrays are 1.75x faster", upgradeType: .factoryEfficiency("Quantum Simulator Array", 1.75)),
                UpgradeModel(icon: "waveform.path", name: "Quantum Dynamics Accelerator", cost: 40000000000, costResourceType: "Qubits", description: "Enhance simulation of quantum system dynamics \nQuantum Simulator Arrays are 2x faster", upgradeType: .factoryEfficiency("Quantum Simulator Array", 2.0)),
                UpgradeModel(icon: "cpu.fill", name: "Tensor Network Coprocessor", cost: 80000000000, costResourceType: "Qubits", description: "Add specialized hardware for tensor network calculations \nQuantum Simulator Arrays are 2.25x faster", upgradeType: .factoryEfficiency("Quantum Simulator Array", 2.25)),
                UpgradeModel(icon: "cube.transparent", name: "Holographic Quantum Simulation", cost: 160000000000, costResourceType: "Qubits", description: "Implement cutting-edge holographic quantum simulation techniques \nQuantum Simulator Arrays are 3x faster", upgradeType: .factoryEfficiency("Quantum Simulator Array", 3.0)),

                // Universal Fault-Tolerant Quantum Computer Upgrades
                UpgradeModel(icon: "shield.checkerboard", name: "Advanced Error Correction", cost: 100000000000, costResourceType: "Qubits", description: "Implement state-of-the-art quantum error correction codes \nUniversal Fault-Tolerant Quantum Computers are 1.5x faster", upgradeType: .factoryEfficiency("Universal Fault-Tolerant Quantum Computer", 1.5)),
                UpgradeModel(icon: "circle.grid.cross", name: "Topological Qubit Enhancement", cost: 200000000000, costResourceType: "Qubits", description: "Utilize topological qubits for improved stability \nUniversal Fault-Tolerant Quantum Computers are 1.75x faster", upgradeType: .factoryEfficiency("Universal Fault-Tolerant Quantum Computer", 1.75)),
                UpgradeModel(icon: "rotate.3d", name: "Multi-Dimensional Quantum Gates", cost: 400000000000, costResourceType: "Qubits", description: "Implement advanced multi-qubit gate operations \nUniversal Fault-Tolerant Quantum Computers are 2x faster", upgradeType: .factoryEfficiency("Universal Fault-Tolerant Quantum Computer", 2.0)),
                UpgradeModel(icon: "square.stack.3d.forward.dottedline", name: "Quantum Circuit Optimization", cost: 800000000000, costResourceType: "Qubits", description: "Enhance quantum circuit compilation and optimization \nUniversal Fault-Tolerant Quantum Computers are 2.25x faster", upgradeType: .factoryEfficiency("Universal Fault-Tolerant Quantum Computer", 2.25)),
                UpgradeModel(icon: "infinity", name: "Unlimited Coherence Time", cost: 1600000000000, costResourceType: "Qubits", description: "Achieve theoretically unlimited qubit coherence time \nUniversal Fault-Tolerant Quantum Computers are 3x faster", upgradeType: .factoryEfficiency("Universal Fault-Tolerant Quantum Computer", 3.0)),

                // Quantum Multiverse Engine Upgrades
                UpgradeModel(icon: "sparkles", name: "Multiverse Tap", cost: 1000000000000, costResourceType: "Qubits", description: "Establish initial connection to quantum multiverse \nQuantum Multiverse Engines are 1.5x faster", upgradeType: .factoryEfficiency("Quantum Multiverse Engine", 1.5)),
                UpgradeModel(icon: "arrow.left.and.right.righttriangle.left.righttriangle.right", name: "Inter-Universe Coherence", cost: 2000000000000, costResourceType: "Qubits", description: "Synchronize quantum states across multiple universes \nQuantum Multiverse Engines are 1.75x faster", upgradeType: .factoryEfficiency("Quantum Multiverse Engine", 1.75)),
                UpgradeModel(icon: "seal", name: "Multiverse Seal Capacitor", cost: 4000000000000, costResourceType: "Qubits", description: "Store and utilize energy from multiple universes \nQuantum Multiverse Engines are 2x faster", upgradeType: .factoryEfficiency("Quantum Multiverse Engine", 2.0)),
                UpgradeModel(icon: "tornado", name: "Quantum Tornado Harmonizer", cost: 8000000000000, costResourceType: "Qubits", description: "Harness chaotic multiverse energies for computation \nQuantum Multiverse Engines are 2.25x faster", upgradeType: .factoryEfficiency("Quantum Multiverse Engine", 2.25)),
                UpgradeModel(icon: "hurricane", name: "Multiverse Hurricane Unleashed", cost: 16000000000000, costResourceType: "Qubits", description: "Fully unlock the computational potential of the quantum multiverse \nQuantum Multiverse Engines are 3x faster", upgradeType: .factoryEfficiency("Quantum Multiverse Engine", 3.0)),

                // Distributed Quantum Cloud Upgrades
                UpgradeModel(icon: "cloud", name: "Quantum Cloud Expansion", cost: 10000000000000, costResourceType: "Qubits", description: "Increase the number of interconnected quantum nodes \nDistributed Quantum Clouds are 1.5x faster", upgradeType: .factoryEfficiency("Distributed Quantum Cloud", 1.5)),
                UpgradeModel(icon: "antenna.radiowaves.left.and.right", name: "Quantum Teleportation Network", cost: 20000000000000, costResourceType: "Qubits", description: "Implement global quantum state teleportation \nDistributed Quantum Clouds are 1.75x faster", upgradeType: .factoryEfficiency("Distributed Quantum Cloud", 1.75)),
                UpgradeModel(icon: "rectangle.connected.to.line.below", name: "Advanced Hybrid Quantum-Classical Algorithms", cost: 40000000000000, costResourceType: "Qubits", description: "Optimize workload distribution between quantum and classical systems \nDistributed Quantum Clouds are 2x faster", upgradeType: .factoryEfficiency("Distributed Quantum Cloud", 2.0)),
                UpgradeModel(icon: "chart.xyaxis.line", name: "Dynamic Resource Allocation", cost: 80000000000000, costResourceType: "Qubits", description: "Implement AI-driven quantum resource management \nDistributed Quantum Clouds are 2.25x faster", upgradeType: .factoryEfficiency("Distributed Quantum Cloud", 2.25)),
                UpgradeModel(icon: "network", name: "Quantum Internet Protocol", cost: 160000000000000, costResourceType: "Qubits", description: "Establish a standardized quantum internet protocol \nDistributed Quantum Clouds are 3x faster", upgradeType: .factoryEfficiency("Distributed Quantum Cloud", 3.0)),

                // Quantum AI Nexus Upgrades
                UpgradeModel(icon: "brain", name: "Quantum Neural Networks", cost: 100000000000000, costResourceType: "Qubits", description: "Implement quantum-enhanced neural network architectures \nQuantum AI Nexuses are 1.5x faster", upgradeType: .factoryEfficiency("Quantum AI Nexus", 1.5)),
                UpgradeModel(icon: "cube.transparent", name: "Quantum Tensor Processing", cost: 200000000000000, costResourceType: "Qubits", description: "Enhance AI operations with quantum tensor networks \nQuantum AI Nexuses are 1.75x faster", upgradeType: .factoryEfficiency("Quantum AI Nexus", 1.75)),
                UpgradeModel(icon: "arrow.triangle.2.circlepath", name: "Quantum Reinforcement Learning", cost: 400000000000000, costResourceType: "Qubits", description: "Develop quantum-enhanced reinforcement learning algorithms \nQuantum AI Nexuses are 2x faster", upgradeType: .factoryEfficiency("Quantum AI Nexus", 2.0)),
                UpgradeModel(icon: "network", name: "Quantum Semantic Networks", cost: 800000000000000, costResourceType: "Qubits", description: "Implement quantum-based natural language processing \nQuantum AI Nexuses are 2.25x faster", upgradeType: .factoryEfficiency("Quantum AI Nexus", 2.25)),
                UpgradeModel(icon: "cpu", name: "Quantum Cognitive Architecture", cost: 1600000000000000, costResourceType: "Qubits", description: "Develop a quantum-based artificial general intelligence framework \nQuantum AI Nexuses are 3x faster", upgradeType: .factoryEfficiency("Quantum AI Nexus", 3.0)),

                // Quantum-Classical Hybrid Megastructure Upgrades
                UpgradeModel(icon: "building.2", name: "Expanded Hybrid Processing Units", cost: 1000000000000000, costResourceType: "Qubits", description: "Increase the number of integrated quantum-classical processors \nQuantum-Classical Hybrid Megastructures are 1.5x faster", upgradeType: .factoryEfficiency("Quantum-Classical Hybrid Megastructure", 1.5)),
                UpgradeModel(icon: "bolt.horizontal.circle", name: "Quantum-Classical Interface Optimization", cost: 2000000000000000, costResourceType: "Qubits", description: "Enhance data transfer between quantum and classical systems \nQuantum-Classical Hybrid Megastructures are 1.75x faster", upgradeType: .factoryEfficiency("Quantum-Classical Hybrid Megastructure", 1.75)),
                UpgradeModel(icon: "rectangle.3.group", name: "Modular Quantum Expansion", cost: 4000000000000000, costResourceType: "Qubits", description: "Implement plug-and-play quantum module integration \nQuantum-Classical Hybrid Megastructures are 2x faster", upgradeType: .factoryEfficiency("Quantum-Classical Hybrid Megastructure", 2.0)),
                UpgradeModel(icon: "cpu", name: "Neuromorphic Quantum Processors", cost: 8000000000000000, costResourceType: "Qubits", description: "Integrate brain-inspired architectures with quantum systems \nQuantum-Classical Hybrid Megastructures are 2.25x faster", upgradeType: .factoryEfficiency("Quantum-Classical Hybrid Megastructure", 2.25)),
                UpgradeModel(icon: "square.stack.3d.up.fill", name: "Exascale Quantum-Classical Integration", cost: 16000000000000000, costResourceType: "Qubits", description: "Achieve seamless exascale computing with quantum acceleration \nQuantum-Classical Hybrid Megastructures are 3x faster", upgradeType: .factoryEfficiency("Quantum-Classical Hybrid Megastructure", 3.0)),
                // Quantum Dimension Gateway Upgrades
                UpgradeModel(icon: "circle.hexagongrid.fill", name: "Dimensional Resonance Tuning", cost: 10000000000000000, costResourceType: "Qubits", description: "Fine-tune gateway resonance with quantum dimensions \nQuantum Dimension Gateways are 1.5x faster", upgradeType: .factoryEfficiency("Quantum Dimension Gateway", 1.5)),
                UpgradeModel(icon: "bubbles.and.sparkles.fill", name: "Multiversal Qubit Entanglement", cost: 20000000000000000, costResourceType: "Qubits", description: "Establish qubit correlations across dimensional boundaries \nQuantum Dimension Gateways are 1.75x faster", upgradeType: .factoryEfficiency("Quantum Dimension Gateway", 1.75)),
                UpgradeModel(icon: "rotate.3d", name: "Hyperdimensional Quantum Circuits", cost: 40000000000000000, costResourceType: "Qubits", description: "Implement quantum circuits that operate beyond 3D space \nQuantum Dimension Gateways are 2x faster", upgradeType: .factoryEfficiency("Quantum Dimension Gateway", 2.0)),
                UpgradeModel(icon: "square.stack.3d.forward.dottedline.fill", name: "Quantum Dimension Stabilizers", cost: 80000000000000000, costResourceType: "Qubits", description: "Enhance stability of interdimensional quantum connections \nQuantum Dimension Gateways are 2.25x faster", upgradeType: .factoryEfficiency("Quantum Dimension Gateway", 2.25)),
                UpgradeModel(icon: "peacesign", name: "Dimension Harmony Resonator", cost: 160000000000000000, costResourceType: "Qubits", description: "Achieve perfect harmony between all accessible quantum dimensions \nQuantum Dimension Gateways are 3x faster", upgradeType: .factoryEfficiency("Quantum Dimension Gateway", 3.0)),

                // Cosmic Quantum Computer Upgrades
                UpgradeModel(icon: "star.fill", name: "Stellar Qubit Array", cost: 100000000000000000, costResourceType: "Qubits", description: "Harness stellar phenomena for qubit manipulation \nCosmic Quantum Computers are 1.5x faster", upgradeType: .factoryEfficiency("Cosmic Quantum Computer", 1.5)),
                UpgradeModel(icon: "atom", name: "Galactic Entanglement Network", cost: 200000000000000000, costResourceType: "Qubits", description: "Establish quantum entanglement on a galactic scale \nCosmic Quantum Computers are 1.75x faster", upgradeType: .factoryEfficiency("Cosmic Quantum Computer", 1.75)),
                UpgradeModel(icon: "bolt.horizontal.circle.fill", name: "Supernova Quantum Accelerator", cost: 400000000000000000, costResourceType: "Qubits", description: "Utilize energy from supernovas to power quantum operations \nCosmic Quantum Computers are 2x faster", upgradeType: .factoryEfficiency("Cosmic Quantum Computer", 2.0)),
                UpgradeModel(icon: "hurricane", name: "Black Hole Information Processor", cost: 800000000000000000, costResourceType: "Qubits", description: "Leverage black hole physics for advanced quantum computations \nCosmic Quantum Computers are 2.25x faster", upgradeType: .factoryEfficiency("Cosmic Quantum Computer", 2.25)),
                UpgradeModel(icon: "sparkles", name: "Universal Quantum Fabric Manipulator", cost: 1600000000000000000, costResourceType: "Qubits", description: "Manipulate the quantum fabric of the universe for ultimate computational power \nCosmic Quantum Computers are 3x faster", upgradeType: .factoryEfficiency("Cosmic Quantum Computer", 3.0)),

                // Planck-Scale Quantum Processor Upgrades
                UpgradeModel(icon: "atom", name: "Planck Length Qubit Miniaturization", cost: 1000000000000000000, costResourceType: "Qubits", description: "Shrink qubits to the smallest possible scale \nPlanck-Scale Quantum Processors are 1.5x faster", upgradeType: .factoryEfficiency("Planck-Scale Quantum Processor", 1.5)),
                UpgradeModel(icon: "waveform.path.ecg.rectangle", name: "Quantum Foam Stabilizer", cost: 2000000000000000000, costResourceType: "Qubits", description: "Harness and stabilize quantum foam for computation \nPlanck-Scale Quantum Processors are 1.75x faster", upgradeType: .factoryEfficiency("Planck-Scale Quantum Processor", 1.75)),
                UpgradeModel(icon: "arrow.3.trianglepath", name: "Quantum Gravity Integrator", cost: 4000000000000000000, costResourceType: "Qubits", description: "Incorporate quantum gravity effects into computations \nPlanck-Scale Quantum Processors are 2x faster", upgradeType: .factoryEfficiency("Planck-Scale Quantum Processor", 2.0)),
                UpgradeModel(icon: "bubbles.and.sparkles.fill", name: "Spacetime Curvature Processor", cost: 8000000000000000000, costResourceType: "Qubits", description: "Utilize spacetime curvature for enhanced quantum operations \nPlanck-Scale Quantum Processors are 2.25x faster", upgradeType: .factoryEfficiency("Planck-Scale Quantum Processor", 2.25)),
                UpgradeModel(icon: "infinity", name: "Unified Field Theory Computer", cost: 16000000000000000000, costResourceType: "Qubits", description: "Achieve computational supremacy through unified field theory \nPlanck-Scale Quantum Processors are 3x faster", upgradeType: .factoryEfficiency("Planck-Scale Quantum Processor", 3.0)),
                
                // New non-factory upgrades
                        UpgradeModel(icon: "bolt.horizontal.fill", name: "Quantum Boost", cost: 1000000, costResourceType: "Bits", description: "Increases bits per click by \(formatNumber(0.5 * model.prestigeMultiplier))", upgradeType: .resourcePerClick("Bits", 0.5)),
                        
                        UpgradeModel(icon: "arrow.3.trianglepath", name: "Quantum Entanglement", cost: 10000000, costResourceType: "Bits", description: "Increases bits per second by \(formatNumber(0.3 * model.prestigeMultiplier))", upgradeType: .resourcePerSecond("Bits", 0.3)),
                        
                        UpgradeModel(icon: "wand.and.stars", name: "Quantum Spell", cost: 100000000, costResourceType: "Bits", description: "Increases qubits per click by \(formatNumber(0.2 * model.prestigeMultiplier))", upgradeType: .resourcePerClick("Qubits", 0.2)),
                        
                        UpgradeModel(icon: "person.3.fill", name: "Quantum Workforce", cost: 1000000000, costResourceType: "Bits", description: "Increases qubits per second by \(formatNumber(0.1 * model.prestigeMultiplier))", upgradeType: .resourcePerSecond("Qubits", 0.1)),
                        
                        UpgradeModel(icon: "arrow.triangle.2.circlepath", name: "Bit Recycler", cost: 10000000000, costResourceType: "Bits", description: "Increases bits per click and per second by \(formatNumber(0.4 * model.prestigeMultiplier))", upgradeType: .other("Bit Recycler")),
                        
                        UpgradeModel(icon: "shield.lefthalf.filled", name: "Quantum Firewall", cost: 50000000000, costResourceType: "Bits", description: "Increases qubits per click and per second by \(formatNumber(0.3 * model.prestigeMultiplier))", upgradeType: .other("Quantum Firewall")),
                        
                        UpgradeModel(icon: "sparkles", name: "Quantum Inspiration", cost: 100000000000, costResourceType: "Bits", description: "Increases bits and qubits per click by \(formatNumber(0.6 * model.prestigeMultiplier))", upgradeType: .other("Quantum Inspiration")),
                        
                        UpgradeModel(icon: "cube.transparent", name: "Hypercube Compression", cost: 500000000000, costResourceType: "Bits", description: "Increases bits and qubits per second by \(formatNumber(0.5 * model.prestigeMultiplier))", upgradeType: .other("Hypercube Compression")),
                        
                        UpgradeModel(icon: "antenna.radiowaves.left.and.right", name: "Quantum Internet", cost: 1000000000000, costResourceType: "Bits", description: "Increases all resource generation by \(formatNumber(0.7 * model.prestigeMultiplier)) per click and per second", upgradeType: .other("Quantum Internet")),

                        // Qubit-based upgrades
                        UpgradeModel(icon: "atom", name: "Qubit Amplifier", cost: 1000, costResourceType: "Qubits", description: "Increases bits per click by \(formatNumber(1.0 * model.prestigeMultiplier))", upgradeType: .resourcePerClick("Bits", 1.0)),
                        
                        UpgradeModel(icon: "waveform", name: "Quantum Wave Generator", cost: 5000, costResourceType: "Qubits", description: "Increases bits per second by \(formatNumber(0.8 * model.prestigeMultiplier))", upgradeType: .resourcePerSecond("Bits", 0.8)),
                        
                        UpgradeModel(icon: "circle.grid.cross", name: "Qubit Matrix", cost: 10000, costResourceType: "Qubits", description: "Increases qubits per click by \(formatNumber(0.5 * model.prestigeMultiplier))", upgradeType: .resourcePerClick("Qubits", 0.5)),
                        
                        UpgradeModel(icon: "square.3.stack.3d", name: "Quantum Stack", cost: 50000, costResourceType: "Qubits", description: "Increases qubits per second by \(formatNumber(0.4 * model.prestigeMultiplier))", upgradeType: .resourcePerSecond("Qubits", 0.4)),
                        
                        UpgradeModel(icon: "function", name: "Quantum Algorithm", cost: 100000, costResourceType: "Qubits", description: "Increases all resource generation by \(formatNumber(0.9 * model.prestigeMultiplier)) per click and per second", upgradeType: .other("Quantum Algorithm")),

                UpgradeModel(icon: "testtube.2", name: "Quantum Research Lab", cost: 10000000000, costResourceType: "Bits", description: "Unlocks the Quantum Era", upgradeType: .unlockResource("Qubits"))
            ]
        }
    
    private func initializeFactories() {
            model.factories = [
                FactoryModel(icon: "pc", name: "Personal Computer", cost: 15, costResourceType: "Bits", count: 0, OverView: "A basic home computer for simple data processing \nGenerates \(formatNumber(0.1 * model.prestigeMultiplier)) bits per second", baseOutput: 0.1),
                FactoryModel(icon: "desktopcomputer", name: "Workstation", cost: 200, costResourceType: "Bits", count: 0, OverView: "A more powerful computer designed for professional work \nGenerates \(formatNumber(0.5 * model.prestigeMultiplier)) bits per second", baseOutput: 0.5),
                FactoryModel(icon: "wifi.router", name: "Mini Server", cost: 2000, costResourceType: "Bits", count: 0, OverView: "A small server suitable for a home or small office \nGenerates \(formatNumber(2 * model.prestigeMultiplier)) bits per second", baseOutput: 2),
                FactoryModel(icon: "server.rack", name: "Server Rack", cost: 20000, costResourceType: "Bits", count: 0, OverView: "A small cluster of servers for increased computing power. \nGenerates \(formatNumber(10 * model.prestigeMultiplier)) bits per second", baseOutput: 10),
                FactoryModel(icon: "cloud", name: "Server Farm", cost: 200000, costResourceType: "Bits", count: 0, OverView: "A collection of server racks working in unison for increased processing power \nGenerates \(formatNumber(50 * model.prestigeMultiplier)) bits per second", baseOutput: 50),
                FactoryModel(icon: "cpu", name: "Mainframe", cost: 2000000, costResourceType: "Bits", count: 0, OverView: "A large, powerful computer system capable of handling multiple complex tasks simultaneously \nGenerates \(formatNumber(250 * model.prestigeMultiplier)) bits per second", baseOutput: 250),
                FactoryModel(icon: "memorychip", name: "Vector Processor", cost: 20000000, costResourceType: "Bits", count: 0, OverView: "Specialized high-performance computer optimized for scientific and graphical calculations \nGenerates \(formatNumber(1000 * model.prestigeMultiplier)) bits per second", baseOutput: 1000),
                FactoryModel(icon: "waveform.path.ecg", name: "Parallel Processing Array", cost: 200000000, costResourceType: "Bits", count: 0, OverView: "A system of interconnected processors working on shared tasks \nGenerates \(formatNumber(5000 * model.prestigeMultiplier)) bits per second", baseOutput: 5000),
                FactoryModel(icon: "brain", name: "Neural Network Computer", cost: 2000000000, costResourceType: "Bits", count: 0, OverView: "Advanced system mimicking brain structure for complex pattern recognition \nGenerates \(formatNumber(25000 * model.prestigeMultiplier)) bits per second", baseOutput: 25000),
                FactoryModel(icon: "bolt.fill", name: "Supercomputer", cost: 20000000000, costResourceType: "Bits", count: 0, OverView: "Cutting-edge high-performance computing system for the most demanding computational tasks \nGenerates \(formatNumber(100000 * model.prestigeMultiplier)) bits per second", baseOutput: 100000),
                // MARK: - Quantum Factories
                FactoryModel(icon: "laptopcomputer", name: "Basic Quantum Computer", cost: 10, costResourceType: "Qubits", count: 0, OverView: "An entry-level quantum computing system capable of executing fundamental quantum algorithms.\nGenerates \(formatNumber(0.1 * model.prestigeMultiplier)) Qubit per second.", baseOutput: 0.1),

                FactoryModel(icon: "desktopcomputer", name: "Advanced Quantum Workstation", cost: 50, costResourceType: "Qubits", count: 0, OverView: "A more powerful quantum system for complex calculations.\nGenerates \(formatNumber(0.3 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 0.3),

                FactoryModel(icon: "externaldrive.connected.to.line.below", name: "Quantum Annealer", cost: 250, costResourceType: "Qubits", count: 0, OverView: "Specialized quantum device for solving optimization problems. \nGenerates \(formatNumber(0.8 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 0.8),

                FactoryModel(icon: "atom", name: "Trapped Ion Quantum Computer", cost: 1000, costResourceType: "Qubits", count: 0, OverView: "Uses charged atoms to store quantum information. \nGenerates \(formatNumber(2 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 2),

                FactoryModel(icon: "bolt.circle", name: "Superconducting Quantum Processor", cost: 5000, costResourceType: "Qubits", count: 0, OverView: "Utilizes superconducting circuits for quantum operations. \nGenerates \(formatNumber(6 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 6),

                FactoryModel(icon: "map", name: "Topological Quantum System", cost: 25000, costResourceType: "Qubits", count: 0, OverView: "Employs exotic quantum states for more stable computation. \nGenerates \(formatNumber(20 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 20),

                FactoryModel(icon: "externaldrive.badge.exclamationmark", name: "Quantum Error Correction Engine", cost: 100000, costResourceType: "Qubits", count: 0, OverView: "Advanced system that actively corrects quantum errors. \nGenerates \(formatNumber(50 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 50),

                FactoryModel(icon: "point.3.connected.trianglepath.dotted", name: "Quantum Network Node", cost: 500000, costResourceType: "Qubits", count: 0, OverView: "Key component in a quantum internet infrastructure. \nGenerates \(formatNumber(200 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 200),

                FactoryModel(icon: "server.rack", name: "Quantum Simulator Array", cost: 2500000, costResourceType: "Qubits", count: 0, OverView: "Large-scale system for simulating complex quantum systems. \nGenerates \(formatNumber(1000 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 1000),

                FactoryModel(icon: "globe", name: "Universal Fault-Tolerant Quantum Computer", cost: 10000000, costResourceType: "Qubits", count: 0, OverView: "The holy grail of quantum computing, capable of any quantum algorithm. \nGenerates \(formatNumber(5000 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 5000),

                FactoryModel(icon: "engine.combustion", name: "Quantum Multiverse Engine", cost: 50000000, costResourceType: "Qubits", count: 0, OverView: "Theoretical system harnessing quantum multiverse for unprecedented power. \nGenerates \(formatNumber(25000 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 25000),

                FactoryModel(icon: "cloud.circle", name: "Distributed Quantum Cloud", cost: 250000000, costResourceType: "Qubits", count: 0, OverView: "A global network of quantum computers working in unison. \nGenerates \(formatNumber(100000 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 100000),

                FactoryModel(icon: "externaldrive.badge.icloud", name: "Quantum AI Nexus", cost: 1000000000, costResourceType: "Qubits", count: 0, OverView: "Merges quantum computing with advanced AI for unprecedented problem-solving. \nGenerates \(formatNumber(500000 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 500000),

                FactoryModel(icon: "window.ceiling.closed", name: "Quantum-Classical Hybrid Megastructure", cost: 5000000000, costResourceType: "Qubits", count: 0, OverView: "Massive facility integrating quantum and classical computing at scale. \nGenerates \(formatNumber(2500000 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 2500000),

                FactoryModel(icon: "door.left.hand.open", name: "Quantum Dimension Gateway", cost: 25000000000, costResourceType: "Qubits", count: 0, OverView: "Theoretical system tapping into quantum dimensions for computation. \nGenerates \(formatNumber(10000000 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 10000000),

                FactoryModel(icon: "moon.stars", name: "Cosmic Quantum Computer", cost: 100000000000, costResourceType: "Qubits", count: 0, OverView: "Harnesses cosmic phenomena for quantum operations on an astronomical scale. \nGenerates \(formatNumber(50000000 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 50000000),

                FactoryModel(icon: "cpu", name: "Planck-Scale Quantum Processor", cost: 500000000000, costResourceType: "Qubits", count: 0, OverView: "Operates at the smallest possible scale, pushing the boundaries of physics. \nGenerates \(formatNumber(250000000 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 250000000),
                

                
            ]
        }
    
    private func initializePrestigeUpgrades() {
        model.prestigeUpgrades = [
            PrestigeUpgradeModel(icon: "sparkles", name: "Quick Start", description: "Start with 100 bits after prestige", cost: 1),
            PrestigeUpgradeModel(icon: "clock.arrow.circlepath", name: "Time Warp", description: "Gain 100 hours worth of bits production", cost: 2),
            PrestigeUpgradeModel(icon: "multiply.circle.fill", name: "Multiplier Boost", description: "Increase your prestige multiplier by 10%", cost: 5),
            PrestigeUpgradeModel(icon: "sparkles", name: "Starting Boost", description: "Start with 1000 bits after prestige", cost: 3),
            PrestigeUpgradeModel(icon: "bolt.fill", name: "Click Power", description: "Double your bits per click", cost: 4),
            PrestigeUpgradeModel(icon: "cpu", name: "Computer Efficiency", description: "All Computers produce 25% more bits", cost: 7),
            PrestigeUpgradeModel(icon: "hourglass", name: "Offline Progress", description: "Increase offline production efficiency to 75%", cost: 8),
            PrestigeUpgradeModel(icon: "dollarsign.circle", name: "Cost Reduction", description: "Reduce all Computer costs by 10%", cost: 10),
            PrestigeUpgradeModel(icon: "memorychip", name: "Quantum Memory", description: "Start with 10 Qubits after prestige", cost: 15),
            
            PrestigeUpgradeModel(icon: "sparkles.2", name: "Mega Start", description: "Start with 10,000 bits after prestige", cost: 20),
            PrestigeUpgradeModel(icon: "clock.arrow.2.circlepath", name: "Time Leap", description: "Gain 500 hours worth of bits production", cost: 25),
            PrestigeUpgradeModel(icon: "multiply.square.fill", name: "Super Multiplier", description: "Increase your prestige multiplier by 25%", cost: 30),
            PrestigeUpgradeModel(icon: "bolt.circle.fill", name: "Click Frenzy", description: "Triple your bits per click", cost: 35),
            PrestigeUpgradeModel(icon: "cpu.fill", name: "Overclocked Computers", description: "All Computers produce 50% more bits", cost: 40),
            PrestigeUpgradeModel(icon: "moon.zzz.fill", name: "Extended Offline", description: "Offline production cap raised to 10 hours", cost: 45),
            PrestigeUpgradeModel(icon: "arrow.clockwise", name: "Quick Reset", description: "Reduce the time needed to perform a prestige by 50%", cost: 50),
            PrestigeUpgradeModel(icon: "dollarsign.circle.fill", name: "Bargain Hunter", description: "Reduce all Computer costs by 20%", cost: 55),
            PrestigeUpgradeModel(icon: "memorychip.fill", name: "Quantum Surge", description: "Start with 50 Qubits after prestige", cost: 60)
        ]
    }
    
    func factoryCount(name: String) -> Int{
        return model.factories.first { $0.name == name }?.count ?? 0
    }
    
    func canBuyPrestigeUpgrade(_ upgrade: PrestigeUpgradeModel) -> Bool {
            return model.prestigePoints >= upgrade.cost && !upgrade.bought
        }

        func buyPrestigeUpgrade(_ upgrade: PrestigeUpgradeModel) {
            if canBuyPrestigeUpgrade(upgrade) {
                model.prestigePoints -= upgrade.cost
                upgrade.bought = true
                applyPrestigeUpgradeEffect(upgrade)
                objectWillChange.send()
            }
        }
    
    func checkAchievements() {
            for achievement in model.achievements {
                switch achievement.id {
                case "bitMillionaire":
                    if model.totalBitsEarned >= 1_000_000 {
                        achievement.isUnlocked = true
                    }
                case "quantumLeap":
                    if model.quantumUnlocked {
                        achievement.isUnlocked = true
                    }
                case "factoryTycoon":
                    if model.factories.reduce(0, { $0 + $1.count }) >= 100 {
                        achievement.isUnlocked = true
                    }
                case "prestigeMaster":
                    if model.timesPrestiged >= 5 {
                        achievement.isUnlocked = true
                    }
                case "myfirstbit":
                    if model.totalBitsEarned >= 1{
                        achievement.isUnlocked = true
                    }
                case "Doublebit":
                    if model.totalBitsEarned >= 10{
                        achievement.isUnlocked = true
                    }
                case "Triplebit":
                    if model.totalBitsEarned >= 100{
                        achievement.isUnlocked = true
                    }
                case "Quadbit":
                    if model.totalBitsEarned >= 1000{
                        achievement.isUnlocked = true
                    }
                case "10kb":
                    if model.totalBitsEarned >= 10_000{
                        achievement.isUnlocked = true
                    }
                case "datac":
                    if model.totalBitsEarned >= 100_000{
                        achievement.isUnlocked = true
                    }
                case "Quantum Era":
                    if model.totalQubitsEarned >= 1{
                        achievement.isUnlocked = true
                    }
                case "Automation":
                    if model.factories.reduce(0, { $0 + $1.count }) >= 1 {
                        achievement.isUnlocked = true
                    }
                case "Automation2":
                    if model.factories.reduce(0, { $0 + $1.count }) >= 10 {
                        achievement.isUnlocked = true
                    }
                case "Automation3":
                    if model.factories.reduce(0, { $0 + $1.count }) >= 50 {
                        achievement.isUnlocked = true
                    }
                case "bitMultiMillionaire":
                    if model.totalBitsEarned >= 2_000_000{
                        achievement.isUnlocked = true
                    }
                case "bit500m":
                    if model.totalBitsEarned >= 500_000_000{
                        achievement.isUnlocked = true
                    }
                case "bit1b":
                    if model.totalBitsEarned >= 1_000_000_000{
                        achievement.isUnlocked = true
                    }
                case "bit1t":
                    if model.totalBitsEarned >= 1_000_000_000_000{
                        achievement.isUnlocked = true
                    }
                case "Quantum 10qb":
                    if model.totalQubitsEarned >= 10{
                        achievement.isUnlocked = true
                    }
                case "Quantum 100qb":
                    if model.totalQubitsEarned >= 100{
                        achievement.isUnlocked = true
                    }
                case "Quantum 1000qb":
                    if model.totalQubitsEarned >= 1000{
                        achievement.isUnlocked = true
                    }
                case "Quantum 10kqb":
                    if model.totalQubitsEarned >= 10_000{
                        achievement.isUnlocked = true
                    }
                case "Quantum 100kqb":
                    if model.totalQubitsEarned >= 100_000{
                        achievement.isUnlocked = true
                    }
                case "Quantum 1mqb":
                    if model.totalQubitsEarned >= 1_000_000{
                        achievement.isUnlocked = true
                    }
                case "Quantum 10mqb":
                    if model.totalQubitsEarned >= 10_000_000{
                        achievement.isUnlocked = true
                    }
                case "Quantum 100mqb":
                    if model.totalQubitsEarned >= 100_000_000{
                        achievement.isUnlocked = true
                    }
                case "Quantum 1bqb":
                    if model.totalQubitsEarned >= 1_000_000_000{
                        achievement.isUnlocked = true
                    }
                case "Quantum 1tqb":
                    if model.totalQubitsEarned >= 1_000_000_000_000{
                        achievement.isUnlocked = true
                    }


                default:
                    break
                }
            }
            saveGameState()
        }

    private func applyPrestigeUpgradeEffect(_ upgrade: PrestigeUpgradeModel) {
            switch upgrade.name {
            case "Quick Start":
                if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                    model.resources[bitsIndex].amount += 100
                }
            case "Time Warp":
                if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                    let production = model.resources[bitsIndex].perSecond
                    model.resources[bitsIndex].amount += production * 3600 * 100 // 100 hours worth
                }
            case "Multiplier Boost":
                model.prestigeMultiplier *= 1.1
            case "Starting Boost":
                if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                    model.resources[bitsIndex].amount += 1000
                }
            case "Click Power":
                if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                    model.resources[bitsIndex].perClick *= 2
                }
            case "Computer Efficiency":
                model.factoryEfficiencyMultiplier *= 1.25
                recalculateAllFactoryOutputs()
            case "Offline Progress":
                // This will be used in the calculateOfflineProgress function
                model.offlineEfficiency = 0.75
            case "Cost Reduction":
                for i in 0..<model.factories.count {
                    model.factories[i].cost *= 0.9
                }
            case "Quantum Memory":
                if let QubitsIndex = model.resources.firstIndex(where: { $0.name == "Qubits" }) {
                    model.resources[QubitsIndex].amount += 10
                }
            case "Mega Start":
                if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                    model.resources[bitsIndex].amount += 100
                }
            case "Time Leap":
                if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                    let production = model.resources[bitsIndex].perSecond
                    model.resources[bitsIndex].amount += production * 3600 * 500
                }
            case "Super Multiplier":
                model.prestigeMultiplier *= 1.25
            case "Click Frenzy":
                if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                    model.resources[bitsIndex].perClick *= 3
                }
            case "Overclocked Computers":
                model.factoryEfficiencyMultiplier *= 1.5
                recalculateAllFactoryOutputs()
            case "Bargain Hunter":
                for i in 0..<model.factories.count {
                    model.factories[i].cost *= 0.8
                }
            case "Quantum Surge":
                if let QubitsIndex = model.resources.firstIndex(where: { $0.name == "Qubits" }) {
                    model.resources[QubitsIndex].amount += 50
                }
            case "Quick Reset":
                model.quickReset = true
            case "Extended Offline":
                model.extendedOffline = true
                
                
                
            default:
                break
            }
        }
    
    private func updateFactoryOutput(factoryIndex: Int) {
        let factory = model.factories[factoryIndex]
        let baseOutput = factory.baseOutput
        let updatedOutput = baseOutput * factory.efficiency
        
        if let resourceIndex = model.resources.firstIndex(where: { $0.name == factory.costResourceType }) {
            model.resources[resourceIndex].perSecond += (updatedOutput * Double(factory.count)) - factory.baseOutput
        }
        factory.baseOutput = updatedOutput
        factory.OverView = "Generates \(formatNumber(updatedOutput)) \(factory.costResourceType) per second"
        saveGameState()
    }

    func performPrestige() {
            let newPrestigePoints = model.availablePrestigePoints
        
            model.timesPrestiged += 1
    
            model.prestigePoints += newPrestigePoints
            model.prestigeMultiplier +=  Double(newPrestigePoints) * 0.1
            
            // Reset resources
            for i in 0..<model.resources.count {
                model.resources[i].amount = 0
                model.resources[i].perClick = model.resources[i].name == "Bits" ? 0.1 * model.prestigeMultiplier : 0
                model.resources[i].perSecond = 0
            }
            
            // Reset factories
            for i in 0..<model.factories.count {
                model.factories[i].count = 0
                model.factories[i].cost = model.factories[i].initialCost
            }
        
            
            model.personalComputerUnlocked = false
            model.quantumUnlocked = false
        
            model.factoryEfficiencyMultiplier = 1.0
        
            // Reapply effects of bought prestige upgrades
            for upgrade in model.prestigeUpgrades where upgrade.bought {
                applyPrestigeUpgradeEffect(upgrade)
            }
        
            model.totalBitsEarned = 0
            model.totalQubitsEarned = 0
            saveGameState()
        
            resetAfterPrestige()
            
            objectWillChange.send()
        }
    
    func canAffordAnyItem() -> Bool {
            for upgrade in model.upgrades {
                let canBuyUpgradeWithBits = model.resources.first(where: { $0.name == "Bits" })?.amount ?? 0 >= upgrade.cost
                let canBuyUpgradeWithQubits = model.resources.first(where: { $0.name == "Qubits" })?.amount ?? 0 >= upgrade.cost
                if canBuyUpgradeWithBits {
                    return true
                }else if canBuyUpgradeWithQubits{
                    return true
                }
            }

            for factory in model.factories {
                let factoryCost = factory.cost
                let canBuyFactory = model.resources.first(where: { $0.name == factory.costResourceType })?.amount ?? 0 >= factoryCost
                if canBuyFactory {
                    return true
                }
            }

            return false
        }
    
    private func recalculateAllFactoryOutputs() {
            // Reset all resource production rates
            for i in 0..<model.resources.count {
                model.resources[i].perSecond = 0
            }

            // Recalculate production for all factories
            for factory in model.factories {
                for _ in 0..<factory.count {
                    applyFactoryEffect(factory)
                }
                updateFactoryDescription(factory)
            }
        }
    
    private func updateFactoryDescription(_ factory: FactoryModel) {
            let baseOutput = factory.baseOutput
            let upgradedOutput = baseOutput * model.factoryEfficiencyMultiplier * model.prestigeMultiplier
            factory.OverView = "Generates \(formatNumber(upgradedOutput)) \(factory.name == "Basic Quantum Computer" ? "qubits" : "bits") per second"
        }
    
    func calculateOfflineProgress() {
            if let terminationTime = UserDefaults.standard.object(forKey: "terminationTime") as? Date {
                let now = Date()
                let timeDifference = now.timeIntervalSince(terminationTime)
                let secondsElapsed = Int(timeDifference)
                
                // Cap offline progress to a maximum of 8 hours
                let cappedSeconds = min(secondsElapsed, (model.extendedOffline ? 10 : 8) * 60 * 60)
                
                for i in 0..<model.resources.count {
                    let generatedAmount = model.resources[i].perSecond * Double(cappedSeconds)
                    // Apply the offline efficiency rate for offline production
                    model.resources[i].amount += generatedAmount * (model.offlineEfficiency ?? 0.5)
                }
                
                model.lastUpdateTime = now
            }
        }
        
        func scheduleAppRefresh() {
            let request = BGAppRefreshTaskRequest(identifier: "com.name.adambyford.Quantum-Clicker.refresh")
            request.earliestBeginDate = Date(timeIntervalSinceNow: 0.01 * 60)
            
            do {
                try BGTaskScheduler.shared.submit(request)
            } catch {
                print("Could not schedule app refresh: \(error)")
            }
        }
    
    
    func click() {
            if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                let clickAmount = model.resources[bitsIndex].perClick
                model.resources[bitsIndex].amount += clickAmount
                model.totalBitsEarned += clickAmount
            }
            if model.quantumUnlocked, let qubitsIndex = model.resources.firstIndex(where: { $0.name == "Qubits" }) {
                let clickAmount = model.resources[qubitsIndex].perClick
                model.resources[qubitsIndex].amount += clickAmount
                model.totalQubitsEarned += clickAmount
            }
            objectWillChange.send()
        }
    
    func formatNumber(_ number: Double) -> String {
        let absNumber = abs(number)
        let sign = number.sign == .minus ? "-" : ""
        
        let suffixes = ["", "K", "M", "B", "T", "Qu", "Qi", "S", "O", "N", "D"]
        var suffixIndex = 0
        var scaledNumber = absNumber

        while scaledNumber >= 1000 && suffixIndex < suffixes.count - 1 {
            scaledNumber /= 1000
            suffixIndex += 1
        }

        if scaledNumber.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%@%.0f%@", sign, scaledNumber, suffixes[suffixIndex])
        } else {
            let decimalPlaces = scaledNumber < 10 ? 2 : 1
            return String(format: "%@%.\(decimalPlaces)f%@", sign, scaledNumber, suffixes[suffixIndex])
        }
    }
    
    func buyUpgrade(_ upgradeIndex: Int) {
        guard upgradeIndex < model.upgrades.count else { return }
        let upgrade = model.upgrades[upgradeIndex]
        if let bitsIndex = model.resources.firstIndex(where: { $0.name == upgrade.costResourceType }),
           model.resources[bitsIndex].amount >= upgrade.cost {
            model.resources[bitsIndex].amount -= upgrade.cost
            model.upgrades.remove(at: upgradeIndex)
            applyUpgradeEffect(upgrade)
        }
        saveGameState()
    }
    
    func applyUpgradeEffect(_ upgrade: UpgradeModel) {
        switch upgrade.upgradeType {
        case .factoryEfficiency(let factoryName, let multiplier):
            applyFactoryEfficiencyUpgrade(factoryName: factoryName, multiplier: multiplier)
        case .resourcePerClick(let resourceName, let amount):
            applyResourcePerClickUpgrade(resourceName: resourceName, amount: amount)
        case .resourcePerSecond(let resourceName, let amount):
            applyResourcePerSecondUpgrade(resourceName: resourceName, amount: amount)
        case .unlockResource(let resourceName):
            unlockResource(resourceName: resourceName)
        case .other(let description):
            applyOtherUpgrade(description: description)
        }
    }
    
    private func applyFactoryEfficiencyUpgrade(factoryName: String, multiplier: Double) {
        if let factoryIndex = model.factories.firstIndex(where: { $0.name == factoryName }) {
            let currentEfficiency = model.factories[factoryIndex].efficiency
            model.factories[factoryIndex].efficiency = currentEfficiency * multiplier
            updateFactoryOutput(factoryIndex: factoryIndex)
            model.factories[factoryIndex].efficiency = currentEfficiency
        }
    }

    private func applyResourcePerClickUpgrade(resourceName: String, amount: Double) {
        if let resourceIndex = model.resources.firstIndex(where: { $0.name == resourceName }) {
            model.resources[resourceIndex].perClick += amount * model.prestigeMultiplier
        }
    }

    private func applyResourcePerSecondUpgrade(resourceName: String, amount: Double) {
        if let resourceIndex = model.resources.firstIndex(where: { $0.name == resourceName }) {
            model.resources[resourceIndex].perSecond += amount * model.prestigeMultiplier
        }
    }
    
    
    private func unlockResource(resourceName: String) {
        switch resourceName {
        case "Qubits":
            model.quantumUnlocked = true
            if let QubitsIndex = model.resources.firstIndex(where: { $0.name == "Qubits" }) {
                model.resources[QubitsIndex].perClick = 0.1
            }
        // Add other resources as needed
        default:
            break
        }
    }
    
    private func applyOtherUpgrade(description: String) {
        // Handle other types of upgrades that don't fit into the above categories
        switch description {
        case "Double Clicks":
            if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                model.resources[bitsIndex].perClick *= 2
            }
        case "Triple Clicks":
            if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                model.resources[bitsIndex].perClick *= 3
            }
        case "Bit Recycler":
            if let resourceIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                model.resources[resourceIndex].perClick += 0.4 * model.prestigeMultiplier
                model.resources[resourceIndex].perSecond += 0.4 * model.prestigeMultiplier
            }
        case "Quantum Firewall":
            if let resourceIndex = model.resources.firstIndex(where: { $0.name == "Qubits" }) {
                model.resources[resourceIndex].perClick += 0.3 * model.prestigeMultiplier
                model.resources[resourceIndex].perSecond += 0.3 * model.prestigeMultiplier
            }
        case "Quantum Inspiration":
            if let resourceIndex = model.resources.firstIndex(where: { $0.name == "Qubits" }) {
                model.resources[resourceIndex].perClick += 0.6 * model.prestigeMultiplier
                model.resources[resourceIndex].perSecond += 0.6 * model.prestigeMultiplier
            }
        case "Hypercube Compression":
            if let qubitIndex = model.resources.firstIndex(where: { $0.name == "Qubits" }) {
                model.resources[qubitIndex].perClick += 0.5 * model.prestigeMultiplier
                model.resources[qubitIndex].perSecond += 0.5 * model.prestigeMultiplier
            }
            if let bitIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                model.resources[bitIndex].perClick += 0.5 * model.prestigeMultiplier
                model.resources[bitIndex].perSecond += 0.5 * model.prestigeMultiplier
            }
        case "Quantum Internet":
            if let qubitIndex = model.resources.firstIndex(where: { $0.name == "Qubits" }) {
                model.resources[qubitIndex].perClick += 0.7 * model.prestigeMultiplier
                model.resources[qubitIndex].perSecond += 0.7 * model.prestigeMultiplier
            }
            if let bitIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                model.resources[bitIndex].perClick += 0.7 * model.prestigeMultiplier
                model.resources[bitIndex].perSecond += 0.7 * model.prestigeMultiplier
            }
        case "Quantum Algorithm":
            if let qubitIndex = model.resources.firstIndex(where: { $0.name == "Qubits" }) {
                model.resources[qubitIndex].perClick += 0.9 * model.prestigeMultiplier
                model.resources[qubitIndex].perSecond += 0.9 * model.prestigeMultiplier
            }
            if let bitIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                model.resources[bitIndex].perClick += 0.9 * model.prestigeMultiplier
                model.resources[bitIndex].perSecond += 0.9 * model.prestigeMultiplier
            }
            
            
            
            
            
            
        default:
            break
        }
    }
    
    func buyFactory(_ factoryIndex: Int, quantity: Int = 1) {
        guard factoryIndex < model.factories.count else { return }
        let factory = model.factories[factoryIndex]
        let totalCost = factory.cost * (1 - pow(1.2, Double(quantity))) / (1 - 1.2)
        
        if let resourceIndex = model.resources.firstIndex(where: { $0.name == factory.costResourceType }),
           model.resources[resourceIndex].amount >= totalCost {
            model.resources[resourceIndex].amount -= totalCost
            for _ in 0..<quantity {
                applyFactoryEffect(factory)
                factory.count += 1
                factory.cost *= 1.2
            }
            model.factories[factoryIndex] = factory
        }
    }
    
    private func applyFactoryEffect(_ factory: FactoryModel) {
        guard let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }),
              let qubitsIndex = model.resources.firstIndex(where: { $0.name == "Qubits" }) else {
            return
        }

        func updateResource(for resourceIndex: Int, with baseOutput: Double) {
            model.resources[resourceIndex].perSecond += baseOutput * model.prestigeMultiplier * model.factoryEfficiencyMultiplier
            print(baseOutput * model.prestigeMultiplier * model.factoryEfficiencyMultiplier)
        }

        switch factory.name {
        case "Personal Computer":
            updateResource(for: bitsIndex, with: factory.baseOutput)
            model.personalComputerUnlocked = true
        case "Workstation", "Mini Server", "Server Rack", "Server Farm",
             "Mainframe", "Vector Processor", "Parallel Processing Array",
             "Neural Network Computer", "Supercomputer":
            updateResource(for: bitsIndex, with: factory.baseOutput)
        case "Basic Quantum Computer", "Quantum Annealer", "Trapped Ion Quantum Computer",
             "Superconducting Quantum Processor", "Topological Quantum System",
             "Quantum Error Correction Engine", "Quantum Network Node", "Quantum Simulator Array",
             "Universal Fault-Tolerant Quantum Computer", "Quantum Multiverse Engine",
             "Distributed Quantum Cloud", "Quantum AI Nexus", "Quantum-Classical Hybrid Megastructure",
             "Quantum Dimension Gateway", "Cosmic Quantum Computer", "Planck-Scale Quantum Processor":
            updateResource(for: qubitsIndex, with: factory.baseOutput)
        default:
            break
        }
    }

    
    func update() {
            for i in 0..<model.resources.count {
                let previousAmount = model.resources[i].amount
                let newAmount = previousAmount + (model.resources[i].perSecond * model.prestigeMultiplier)
                model.resources[i].amount = newAmount
                
                let earned = newAmount - previousAmount
                
                if model.resources[i].name == "Bits" {
                    model.totalBitsEarned += earned
                } else if model.resources[i].name == "Qubits" {
                    model.totalQubitsEarned += earned
                }
            }
            checkAchievements()
            objectWillChange.send()
        }
}
