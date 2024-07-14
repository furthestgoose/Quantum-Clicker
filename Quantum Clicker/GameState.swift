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
    var availablePrestigePoints: Int {
            // Example calculation: 1 prestige point per 1e12 (1 trillion) Qubits earned
            return Int(totalQubitsEarned / 1e12)
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
            ResourceModel(name: "Bits", amount: 100000, perClick: 0.1, perSecond: 0),
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
                        AchievementModel(id: "quantumLeap", title: "Quantum Leap", description: "Unlock quantum computing", isUnlocked: false, order: 11),
                        AchievementModel(id: "Quantum Era", title: "Welcome to the quantum era", description: "earn 1 qubit", isUnlocked: false, order: 12),
                        AchievementModel(id: "prestigeMaster", title: "Prestige Master", description: "Prestige 5 times", isUnlocked: false, order: 13),
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
                FactoryModel(icon: "laptopcomputer", name: "Basic Quantum Computer", cost: 100, costResourceType: "Qubits", count: 0, OverView: "An entry-level quantum computing system capable of executing fundamental quantum algorithms.\nGenerates \(formatNumber(0.1 * model.prestigeMultiplier)) Qubit per second.", baseOutput: 0.1),
                FactoryModel(icon: "externaldrive.connected.to.line.below", name: "Quantum Annealer", cost: 1000, costResourceType: "Qubits", count: 0, OverView: "Specialized quantum device for solving optimization problems. \nGenerates \(formatNumber(0.5 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 0.5),
                FactoryModel(icon: "atom", name: "Trapped Ion Quantum Computer", cost: 10000, costResourceType: "Qubits", count: 0, OverView: "Uses charged atoms to store quantum information. \nGenerates \(formatNumber(2 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 2),
                FactoryModel(icon: "bolt.circle", name: "Superconducting Quantum Processor", cost: 100_000, costResourceType: "Qubits", count: 0, OverView: "Utilizes superconducting circuits for quantum operations. \nGenerates \(formatNumber(10 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 10),
                FactoryModel(icon: "map", name: "Topological Quantum System", cost: 1_000_000, costResourceType: "Qubits", count: 0, OverView: "Employs exotic quantum states for more stable computation. \nGenerates \(formatNumber(50 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 50),
                FactoryModel(icon: "externaldrive.badge.exclamationmark", name: "Quantum Error Correction Engine", cost: 10_000_000, costResourceType: "Qubits", count: 0, OverView: "Advanced system that actively corrects quantum errors. \nGenerates \(formatNumber(250 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 250),
                FactoryModel(icon: "point.3.connected.trianglepath.dotted", name: "Quantum Network Node", cost: 100_000_000, costResourceType: "Qubits", count: 0, OverView: "Key component in a quantum internet infrastructure. \nGenerates \(formatNumber(1000 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 1000),
                FactoryModel(icon: "server.rack", name: "Quantum Simulator Array", cost: 1_000_000_000, costResourceType: "Qubits", count: 0, OverView: "Large-scale system for simulating complex quantum systems. \nGenerates \(formatNumber(5000 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 5000),
                FactoryModel(icon: "globe", name: "Universal Fault-Tolerant Quantum Computer", cost: 10_000_000_000, costResourceType: "Qubits", count: 0, OverView: "The holy grail of quantum computing, capable of any quantum algorithm. \nGenerates \(formatNumber(25000 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 25000),
                FactoryModel(icon: "engine.combustion", name: "Quantum Multiverse Engine", cost: 100_000_000_000, costResourceType: "Qubits", count: 0, OverView: "Theoretical system harnessing quantum multiverse for unprecedented power. \nGenerates \(formatNumber(100000 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 100000),
                FactoryModel(icon: "cloud.circle", name: "Distributed Quantum Cloud", cost: 1_000_000_000_000, costResourceType: "Qubits", count: 0, OverView: "A global network of quantum computers working in unison. \nGenerates \(formatNumber(500000 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 500000),
                FactoryModel(icon: "externaldrive.badge.icloud", name: "Quantum AI Nexus", cost: 10_000_000_000_000, costResourceType: "Qubits", count: 0, OverView: "Merges quantum computing with advanced AI for unprecedented problem-solving. \nGenerates \(formatNumber(2500000 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 2500000),
                FactoryModel(icon: "window.ceiling.closed", name: "Quantum-Classical Hybrid Megastructure", cost: 100_000_000_000_000, costResourceType: "Qubits", count: 0, OverView: "Massive facility integrating quantum and classical computing at scale. \nGenerates \(formatNumber(10000000 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 10000000),
                FactoryModel(icon: "door.left.hand.open", name: "Quantum Dimension Gateway", cost: 1_000_000_000_000_000, costResourceType: "Qubits", count: 0, OverView: "Theoretical system tapping into quantum dimensions for computation. \nGenerates \(formatNumber(50000000 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 50000000),
                FactoryModel(icon: "moon.stars", name: "Cosmic Quantum Computer", cost: 10_000_000_000_000_000, costResourceType: "Qubits", count: 0, OverView: "Harnesses cosmic phenomena for quantum operations on an astronomical scale. \nGenerates \(formatNumber(250000000 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 250000000),
                FactoryModel(icon: "cpu", name: "Planck-Scale Quantum Processor", cost: 100_000_000_000_000_000, costResourceType: "Qubits", count: 0, OverView: "Harnesses cosmic phenomena for quantum operations on an astronomical scale. \nGenerates \(formatNumber(1000000000 * model.prestigeMultiplier)) Qubits per second.", baseOutput: 1000000000),
                

                
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
                model.prestigeMultiplier *= 1.1 // Increase by 10%
            case "Starting Boost":
                if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                    model.resources[bitsIndex].amount += 1000
                }
            case "Click Power":
                if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                    model.resources[bitsIndex].perClick *= 2
                }
            case "Factory Efficiency":
                model.factoryEfficiencyMultiplier *= 1.25
                recalculateAllFactoryOutputs()
            case "Offline Progress":
                // This will be used in the calculateOfflineProgress function
                model.offlineEfficiency = 0.75
            case "Cost Reduction":
                for i in 0..<model.factories.count {
                    model.factories[i].cost *= 0.9
                }
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
                let cappedSeconds = min(secondsElapsed, 8 * 60 * 60)
                
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
        let sign = number < 0 ? "-" : ""
        
        switch absNumber {
        case 0..<1000:
            if number.truncatingRemainder(dividingBy: 1) == 0 {
                return String(format: "%@%.0f",sign, absNumber)
            }else{
                return String(format: "%@%.2f", sign, absNumber)
            }
        case 1000..<1_000_000:
            if number.truncatingRemainder(dividingBy: 1) == 0 {
                return String(format: "%@%.0fK",sign, absNumber / 1000)
            }else{
                return String(format: "%@%.1fK", sign, absNumber / 1000)
            }
        case 1_000_000..<1_000_000_000:
            if number.truncatingRemainder(dividingBy: 1) == 0 {
                return String(format: "%@%.0fM",sign, absNumber / 1_000_000)
            }else{
                return String(format: "%@%.1fM", sign, absNumber / 1_000_000)
            }
        case 1_000_000_000..<1_000_000_000_000:
            if number.truncatingRemainder(dividingBy: 1) == 0 {
                return String(format: "%@%.0fB",sign, absNumber / 1_000_000_000)
            }else{
                return String(format: "%@%.1fB", sign, absNumber / 1_000_000_000)
            }
        case 1_000_000_000_000..<1_000_000_000_000_000:
            if number.truncatingRemainder(dividingBy: 1) == 0{
                return String(format: "%@%.0fQu",sign, absNumber / 1_000_000_000_000_000)
            }else{
                return String(format: "%@%.1fQu",sign, absNumber / 1_000_000_000_000_000)
            }
        case 1_000_000_000_000_000..<1_000_000_000_000_000_000:
            if number.truncatingRemainder(dividingBy: 1) == 0{
                return String(format: "%@%.0fQi",sign, absNumber / 1_000_000_000_000_000_000)
            }else{
                return String(format: "%@%.1fQi",sign, absNumber / 1_000_000_000_000_000_000)
            }
        case 1_000_000_000_000_000_000..<1_000_000_000_000_000_000_000:
            if number.truncatingRemainder(dividingBy: 1) == 0{
                return String(format: "%@%.0fS",sign, absNumber / 1_000_000_000_000_000_000_000)
            }else{
                return String(format: "%@%.1fS",sign, absNumber / 1_000_000_000_000_000_000_000)
            }
        default:
            if number.truncatingRemainder(dividingBy: 1) == 0 {
                return String(format: "%@%.0fT",sign, absNumber / 1_000_000_000_000)
            }else{
                return String(format: "%@%.1fT", sign, absNumber / 1_000_000_000_000)
            }
        }
    }
    
    func buyUpgrade(_ upgradeIndex: Int) {
        guard upgradeIndex < model.upgrades.count else { return }
        let upgrade = model.upgrades[upgradeIndex]
        if let bitsIndex = model.resources.firstIndex(where: { $0.name == upgrade.costResourceType }),
           model.resources[bitsIndex].amount >= upgrade.cost {
            model.resources[bitsIndex].amount -= upgrade.cost
            applyUpgradeEffect(upgrade)
            model.upgrades.remove(at: upgradeIndex)
        }
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
        // Add other specific upgrades as needed
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
