import Foundation
import SwiftData
import BackgroundTasks

@Model
class GameStateModel: Identifiable{
    let id: UUID
    var lastUpdateTime: Date = Date()
    var quantumUnlocked: Bool
    var personalComputerUnlocked: Bool
    var ramUpgradeBought: Bool
    var cpuUpgradeBought: Bool
    var coolingUpgradeBought: Bool
    var storageUpgradeBought: Bool
    var workstationCPUUpgradeBought: Bool
    var workstationRAMUpgradeBought: Bool
    var workstationGPUUpgradeBought: Bool
    var workstationNetworkUpgradeBought: Bool
    var personalComputerDescription: String = "A basic home computer for simple data processing \nGenerates 0.1 bits per second"
    var workstationDescription: String = "A more powerful computer designed for professional work \nGenerates 0.5 bits per second"
    var prestigePoints: Int = 0
    var totalBitsEarned: Double = 0
    var totalQubitsEarned: Double = 0
    var prestigeMultiplier: Double = 1.0
    var offlineEfficiency: Double?
    var availablePrestigePoints: Int {
            // Example calculation: 1 prestige point per 1e12 (1 trillion) bits earned
            return Int(totalBitsEarned / 1e12)
        }
    
    @Relationship(deleteRule: .cascade) var resources: [ResourceModel]
    @Relationship(deleteRule: .cascade) var upgrades: [UpgradeModel]
    @Relationship(deleteRule: .cascade) var factories: [FactoryModel]
    @Relationship(deleteRule: .cascade) var prestigeUpgrades: [PrestigeUpgradeModel]
    var factoryEfficiencyMultiplier: Double = 1.0
    
    init(id: UUID = UUID(), quantumUnlocked: Bool = false, personalComputerUnlocked: Bool = false,
         ramUpgradeBought: Bool = false, cpuUpgradeBought: Bool = false, coolingUpgradeBought: Bool = false,
         storageUpgradeBought: Bool = false, workstationCPUUpgradeBought: Bool = false, workstationRAMUpgradeBought: Bool = false,
         workstationGPUUpgradeBought: Bool = false, workstationNetworkUpgradeBought: Bool = false) {
        self.id = id
        self.quantumUnlocked = quantumUnlocked
        self.personalComputerUnlocked = personalComputerUnlocked
        self.ramUpgradeBought = ramUpgradeBought
        self.cpuUpgradeBought = cpuUpgradeBought
        self.coolingUpgradeBought = coolingUpgradeBought
        self.storageUpgradeBought = storageUpgradeBought
        self.workstationCPUUpgradeBought = workstationCPUUpgradeBought
        self.workstationRAMUpgradeBought = workstationRAMUpgradeBought
        self.workstationGPUUpgradeBought = workstationGPUUpgradeBought
        self.workstationNetworkUpgradeBought = workstationNetworkUpgradeBought
        self.resources = []
        self.upgrades = []
        self.factories = []
        self.prestigeUpgrades = []
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
            ResourceModel(name: "Bits", amount: 0, perClick: 0, perSecond: 0.1),
            ResourceModel(name: "Qubits", amount: 0, perClick: 0, perSecond: 0)
        ]
    }
    
    private func initializeUpgrades() {
            model.upgrades = [
                UpgradeModel(icon: "creditcard", name: "Premium Licence", cost: 20, costResourceType: "Bits", description: "You buy the Premium Software Licence \nIncrease bits per click by \(formatNumber(0.1 * model.prestigeMultiplier))"),
                UpgradeModel(icon: "cursorarrow.click", name: "Double Clicks", cost: 100, costResourceType: "Bits", description: "Double the number of bits per click"),
                UpgradeModel(icon: "cursorarrow.click.badge.clock", name: "Autoclicker", cost: 500, costResourceType: "Bits", description: "Automatically generate \(formatNumber(0.1 * model.prestigeMultiplier)) bits per second"),
                UpgradeModel(icon: "cursorarrow.click.2", name: "Triple Clicks", cost: 2000, costResourceType: "Bits", description: "Triple the number of bits per click"),
                UpgradeModel(icon: "dot.circle.and.cursorarrow", name: "Precision Clicking", cost: 10000, costResourceType: "Bits", description: "Increase bits per click by \(formatNumber(0.2 * model.prestigeMultiplier)) through improved accuracy"),
                UpgradeModel(icon: "cursorarrow.motionlines", name: "Quantum Clicker", cost: 1000000, costResourceType: "Bits", description: "Each click has a small chance to produce a qubit"),
                UpgradeModel(icon: "apple.terminal", name: "Automated Clicking Software", cost: 5000000, costResourceType: "Bits", description: "Increase the autoclicker speed to \(formatNumber(0.2 * model.prestigeMultiplier)) bits per second"),
                UpgradeModel(icon: "network", name: "Network Clicks", cost: 20000000, costResourceType: "Bits", description: "Each click generates bits for every connected device, increasing bits per click by \(formatNumber(0.5 * model.prestigeMultiplier))"),
                UpgradeModel(icon: "memorychip", name: "RAM Upgrade", cost: 1000, costResourceType: "Bits", description: "Faster RAM is installed \nPersonal Computers are 1.5x faster"),
                UpgradeModel(icon: "cpu", name: "CPU Upgrade", cost: 5000, costResourceType: "Bits", description: "The CPU is upgraded \nPersonal Computers are 2x faster"),
                UpgradeModel(icon: "fan", name: "Cooling System Upgrade", cost: 20000, costResourceType: "Bits", description: "The Cooling System is upgraded \nPersonal Computers are 1.25x faster"),
                UpgradeModel(icon: "externaldrive", name: "Storage Upgrade", cost: 100000, costResourceType: "Bits", description: "The Storage is upgraded \nPersonal Computers are 1.5x faster"),
                UpgradeModel(icon: "clock.arrow.circlepath", name: "Processor Overclock", cost: 10000, costResourceType: "Bits", description: "Enhanced CPU performance \nWorkstations are 1.5x faster"),
                UpgradeModel(icon: "memorychip", name: "RAM Expansion", cost: 50000, costResourceType: "Bits", description: "Increased memory capacity \nWorkstations are 2x faster"),
                UpgradeModel(icon: "gamecontroller", name: "Graphics Accelerator", cost: 200000, costResourceType: "Bits", description: "Advanced GPU for improved processing \nWorkstations are 1.25x faster"),
                UpgradeModel(icon: "network", name: "High-Speed Network Interface", cost: 1000000, costResourceType: "Bits", description: "Improved data transfer capabilities \nWorkstations are 1.5x faster"),
                UpgradeModel(icon: "testtube.2", name: "Quantum Research Lab", cost: 10000000000, costResourceType: "Bits", description: "Unlocks the Quantum Era")
            ]
        }
    
    private func initializeFactories() {
            model.factories = [
                FactoryModel(icon: "pc", name: "Personal Computer", cost: 15, costResourceType: "Bits", count: 0, OverView: "A basic home computer for simple data processing \nGenerates \(formatNumber(0.1 * model.prestigeMultiplier)) bits per second"),
                FactoryModel(icon: "desktopcomputer", name: "Workstation", cost: 200, costResourceType: "Bits", count: 0, OverView: "A more powerful computer designed for professional work \nGenerates \(formatNumber(0.5 * model.prestigeMultiplier)) bits per second"),
                FactoryModel(icon: "wifi.router", name: "Mini Server", cost: 2000, costResourceType: "Bits", count: 0, OverView: "A small server suitable for a home or small office \nGenerates \(formatNumber(2 * model.prestigeMultiplier)) bits per second"),
                FactoryModel(icon: "server.rack", name: "Server Rack", cost: 20000, costResourceType: "Bits", count: 0, OverView: "A small cluster of servers for increased computing power. \nGenerates \(formatNumber(10 * model.prestigeMultiplier)) bits per second"),
                FactoryModel(icon: "cloud", name: "Server Farm", cost: 200000, costResourceType: "Bits", count: 0, OverView: "A collection of server racks working in unison for increased processing power \nGenerates \(formatNumber(50 * model.prestigeMultiplier)) bits per second"),
                FactoryModel(icon: "cpu", name: "Mainframe", cost: 2000000, costResourceType: "Bits", count: 0, OverView: "A large, powerful computer system capable of handling multiple complex tasks simultaneously \nGenerates \(formatNumber(250 * model.prestigeMultiplier)) bits per second"),
                FactoryModel(icon: "memorychip", name: "Vector Processor", cost: 20000000, costResourceType: "Bits", count: 0, OverView: "Specialized high-performance computer optimized for scientific and graphical calculations \nGenerates \(formatNumber(1000 * model.prestigeMultiplier)) bits per second"),
                FactoryModel(icon: "waveform.path.ecg", name: "Parallel Processing Array", cost: 200000000, costResourceType: "Bits", count: 0, OverView: "A system of interconnected processors working on shared tasks \nGenerates \(formatNumber(5000 * model.prestigeMultiplier)) bits per second"),
                FactoryModel(icon: "brain", name: "Neural Network Computer", cost: 2000000000, costResourceType: "Bits", count: 0, OverView: "Advanced system mimicking brain structure for complex pattern recognition \nGenerates \(formatNumber(25000 * model.prestigeMultiplier)) bits per second"),
                FactoryModel(icon: "bolt.fill", name: "Supercomputer", cost: 20000000000, costResourceType: "Bits", count: 0, OverView: "Cutting-edge high-performance computing system for the most demanding computational tasks \nGenerates \(formatNumber(100000 * model.prestigeMultiplier)) bits per second"),
                FactoryModel(icon: "building", name: "Basic Quantum Computer", cost: 100, costResourceType: "Qubits", count: 0, OverView: "An entry-level quantum computing system capable of executing fundamental quantum algorithms.\nGenerates \(formatNumber(0.1 * model.prestigeMultiplier)) Qubit per second.")
            ]
        }
    
    private func initializePrestigeUpgrades() {
            model.prestigeUpgrades = [
                PrestigeUpgradeModel(icon: "sparkles", name: "Quick Start", description: "Start with 100 bits after prestige", cost: 1),
                PrestigeUpgradeModel(icon: "clock.arrow.circlepath", name: "Time Warp", description: "Gain 100 hours worth of bits production", cost: 2),
                PrestigeUpgradeModel(icon: "multiply.circle.fill", name: "Multiplier Boost", description: "Increase your prestige multiplier by 10%", cost: 5),
                PrestigeUpgradeModel(icon: "sparkles", name: "Starting Boost", description: "Start with 1000 bits after prestige", cost: 3),
                PrestigeUpgradeModel(icon: "bolt.fill", name: "Click Power", description: "Double your bits per click", cost: 4),
                PrestigeUpgradeModel(icon: "cpu", name: "Factory Efficiency", description: "All factories produce 25% more bits", cost: 7),
                PrestigeUpgradeModel(icon: "hourglass", name: "Offline Progress", description: "Increase offline production efficiency to 75%", cost: 8),
                PrestigeUpgradeModel(icon: "dollarsign.circle", name: "Cost Reduction", description: "Reduce all factory costs by 10%", cost: 10),
            ]
        }
    
    var personalComputerCount: Int {
        model.factories.first { $0.name == "Personal Computer" }?.count ?? 0
    }
    
    var workstationCount: Int {
        model.factories.first { $0.name == "Workstation" }?.count ?? 0
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
    
    func updatePersonalComputerOutput(multiplier: Double) {
            if let index = model.factories.firstIndex(where: { $0.name == "Personal Computer" }) {
                let baseOutput = 0.1 * model.prestigeMultiplier
                let outputPerUnit = baseOutput * multiplier
                let totalOutput = outputPerUnit * Double(model.factories[index].count)
                
                if let resourceIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                    model.resources[resourceIndex].perSecond = model.resources[resourceIndex].perSecond
                        - (baseOutput * Double(model.factories[index].count))
                        + totalOutput
                }
                
                let newDescription = "Generate \(outputPerUnit) bits per second"
                model.factories[index].OverView = newDescription
                model.personalComputerDescription = newDescription
            }
        }
    
    func performPrestige() {
            let newPrestigePoints = model.availablePrestigePoints
        
            
    
            model.prestigePoints += newPrestigePoints
            model.prestigeMultiplier +=  Double(newPrestigePoints) * 0.1
            
            // Reset resources
            for i in 0..<model.resources.count {
                model.resources[i].amount = 0
               
                model.resources[i].perSecond = 0
            }
            
            // Reset factories
            for i in 0..<model.factories.count {
                model.factories[i].count = 0
                model.factories[i].cost = model.factories[i].initialCost
            }
        
            
            model.personalComputerUnlocked = false
            model.quantumUnlocked = false
        
            // Reapply effects of bought prestige upgrades
            for upgrade in model.prestigeUpgrades where upgrade.bought {
                applyPrestigeUpgradeEffect(upgrade)
            }
        
            model.totalBitsEarned = 0
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
            let baseOutput = getBaseOutput(for: factory.name)
            let upgradedOutput = baseOutput * model.factoryEfficiencyMultiplier * model.prestigeMultiplier
            factory.OverView = "Generates \(formatNumber(upgradedOutput)) \(factory.name == "Basic Quantum Computer" ? "qubits" : "bits") per second"
        }
    
    private func getBaseOutput(for factoryName: String) -> Double {
            switch factoryName {
            case "Personal Computer":
                return 0.1
            case "Workstation":
                return 0.5
            case "Mini Server":
                return 2
            case "Server Rack":
                return 10
            case "Server Farm":
                return 50
            case "Mainframe":
                return 250
            case "Vector Processor":
                return 1000
            case "Parallel Processing Array":
                return 5000
            case "Neural Network Computer":
                return 25000
            case "Supercomputer":
                return 100000
            default:
                return 0
            }
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
    
    func updateWorkstation(multiplier: Double) {
            if let index = model.factories.firstIndex(where: { $0.name == "Workstation" }) {
                let baseOutput = 0.5 * model.prestigeMultiplier
                let outputPerUnit = baseOutput * multiplier
                let totalOutput = outputPerUnit * Double(model.factories[index].count)
                
                if let resourceIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                    model.resources[resourceIndex].perSecond = model.resources[resourceIndex].perSecond
                        - (baseOutput * Double(model.factories[index].count))
                        + totalOutput
                }
                
                let newDescription = "Generate \(outputPerUnit) bits per second"
                model.factories[index].OverView = newDescription
                model.workstationDescription = newDescription
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
                return String(format: "%@%.1f", sign, absNumber)
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
    
    private func applyUpgradeEffect(_ upgrade: UpgradeModel) {
            switch upgrade.name {
            case "Quantum Research Lab":
                if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Qubits" }) {
                    model.resources[bitsIndex].perClick += 0.01 * model.prestigeMultiplier
                }
                model.quantumUnlocked = true
            case "Premium Licence":
                if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                    model.resources[bitsIndex].perClick += 0.1 * model.prestigeMultiplier
                }
            case "Double Clicks":
                if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                    model.resources[bitsIndex].perClick *= 2
                }
            case "Autoclicker":
                if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                    model.resources[bitsIndex].perSecond += 0.1 * model.prestigeMultiplier
                }
            case "Triple Clicks":
                if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                    model.resources[bitsIndex].perClick *= 3 * model.prestigeMultiplier
                }
            case "Precision Clicking":
                if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                    model.resources[bitsIndex].perClick += 0.1 * model.prestigeMultiplier
                }
            case "Quantum Clicker":
                if let qubitsIndex = model.resources.firstIndex(where: { $0.name == "Qubits" }) {
                    model.resources[qubitsIndex].perClick += 0.01 * model.prestigeMultiplier
                }
            case "Automated Clicking Software":
                if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                    model.resources[bitsIndex].perSecond += 0.1 * model.prestigeMultiplier
                }
            case "Network Clicks":
                if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                    model.resources[bitsIndex].perClick += 0.2 * model.prestigeMultiplier
                }
            case "RAM Upgrade":
                model.ramUpgradeBought = true
                updatePersonalComputerOutput(multiplier: 1.5)
            case "CPU Upgrade":
                model.cpuUpgradeBought = true
                updatePersonalComputerOutput(multiplier: 3)
            case "Cooling System Upgrade":
                model.coolingUpgradeBought = true
                updatePersonalComputerOutput(multiplier: 3.75)
            case "Storage Upgrade":
                model.storageUpgradeBought = true
                updatePersonalComputerOutput(multiplier: 5.625)
            case "Processor Overclock":
                model.workstationCPUUpgradeBought = true
                updateWorkstation(multiplier: 1.5)
            case "RAM Expansion":
                model.workstationRAMUpgradeBought = true
                updateWorkstation(multiplier: 3)
            case "Graphics Accelerator":
                model.workstationGPUUpgradeBought = true
                updateWorkstation(multiplier: 3.75)
            case "High-Speed Network Interface":
                model.workstationNetworkUpgradeBought = true
                updateWorkstation(multiplier: 5.625)
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
            if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }), let qubitsIndex = model.resources.firstIndex(where: { $0.name == "Qubits" }) {
                switch factory.name {
                case "Personal Computer":
                    let output: Double
                    if model.ramUpgradeBought && model.cpuUpgradeBought && model.coolingUpgradeBought && model.storageUpgradeBought {
                        output = 0.5625 * model.prestigeMultiplier * model.factoryEfficiencyMultiplier
                    } else if model.ramUpgradeBought && model.cpuUpgradeBought && model.coolingUpgradeBought {
                        output = 0.375 * model.prestigeMultiplier * model.factoryEfficiencyMultiplier
                    } else if model.ramUpgradeBought && model.cpuUpgradeBought {
                        output = 0.3 * model.prestigeMultiplier * model.factoryEfficiencyMultiplier
                    } else if model.ramUpgradeBought {
                        output = 0.15 * model.prestigeMultiplier * model.factoryEfficiencyMultiplier
                    } else {
                        output = 0.1 * model.prestigeMultiplier * model.factoryEfficiencyMultiplier
                    }
                    model.resources[bitsIndex].perSecond += output
                    model.personalComputerUnlocked = true
                case "Workstation":
                    let output: Double
                    if model.workstationCPUUpgradeBought && model.workstationGPUUpgradeBought && model.workstationRAMUpgradeBought && model.workstationNetworkUpgradeBought {
                        output = 2.8125 * model.prestigeMultiplier * model.factoryEfficiencyMultiplier
                    } else if model.workstationCPUUpgradeBought && model.workstationRAMUpgradeBought && model.workstationGPUUpgradeBought {
                        output = 1.875 * model.prestigeMultiplier * model.factoryEfficiencyMultiplier
                    } else if model.workstationCPUUpgradeBought && model.workstationRAMUpgradeBought {
                        output = 1.5 * model.prestigeMultiplier * model.factoryEfficiencyMultiplier
                    } else if model.workstationCPUUpgradeBought {
                        output = 0.75 * model.prestigeMultiplier * model.factoryEfficiencyMultiplier
                    } else {
                        output = 0.5 * model.prestigeMultiplier * model.factoryEfficiencyMultiplier
                    }
                    model.resources[bitsIndex].perSecond += output
                case "Mini Server":
                    model.resources[bitsIndex].perSecond += 2 * model.prestigeMultiplier * model.factoryEfficiencyMultiplier
                case "Server Rack":
                    model.resources[bitsIndex].perSecond += 10 * model.prestigeMultiplier * model.factoryEfficiencyMultiplier
                case "Server Farm":
                    model.resources[bitsIndex].perSecond += 50 * model.prestigeMultiplier * model.factoryEfficiencyMultiplier
                case "Mainframe":
                    model.resources[bitsIndex].perSecond += 250 * model.prestigeMultiplier * model.factoryEfficiencyMultiplier
                case "Vector Processor":
                    model.resources[bitsIndex].perSecond += 1000 * model.prestigeMultiplier * model.factoryEfficiencyMultiplier
                case "Parallel Processing Array":
                    model.resources[bitsIndex].perSecond += 5000 * model.prestigeMultiplier * model.factoryEfficiencyMultiplier
                case "Neural Network Computer":
                    model.resources[bitsIndex].perSecond += 25000 * model.prestigeMultiplier * model.factoryEfficiencyMultiplier
                case "Supercomputer":
                    model.resources[bitsIndex].perSecond += 100000 * model.prestigeMultiplier * model.factoryEfficiencyMultiplier
                case "Basic Quantum Computer":
                    model.resources[qubitsIndex].perSecond += 0.1 * model.prestigeMultiplier * model.factoryEfficiencyMultiplier
                default:
                    break
                }
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
            objectWillChange.send()
        }
}
