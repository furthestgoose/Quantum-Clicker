import Foundation
import SwiftData

@Model
class GameStateModel: Identifiable{
    let id: UUID
    var quantumUnlocked: Bool
    var personalComputerUnlocked: Bool
    var ramUpgradeBought: Bool
    var cpuUpgradeBought: Bool
    var coolingUpgradeBought: Bool
    var storageUpgradeBought: Bool
    
    @Relationship(deleteRule: .cascade) var resources: [ResourceModel]
    @Relationship(deleteRule: .cascade) var upgrades: [UpgradeModel]
    @Relationship(deleteRule: .cascade) var factories: [FactoryModel]
    
    init(id: UUID = UUID(), quantumUnlocked: Bool = false, personalComputerUnlocked: Bool = false,
         ramUpgradeBought: Bool = false, cpuUpgradeBought: Bool = false, coolingUpgradeBought: Bool = false,
         storageUpgradeBought: Bool = false) {
        self.id = id
        self.quantumUnlocked = quantumUnlocked
        self.personalComputerUnlocked = personalComputerUnlocked
        self.ramUpgradeBought = ramUpgradeBought
        self.cpuUpgradeBought = cpuUpgradeBought
        self.coolingUpgradeBought = coolingUpgradeBought
        self.storageUpgradeBought = storageUpgradeBought
        self.resources = []
        self.upgrades = []
        self.factories = []
    }
    
    func debugPrint() {
            print("Resources:")
            for resource in resources {
                print("- \(resource.name), amount: \(resource.amount), perClick: \(resource.perClick), perSecond: \(resource.perSecond)")
            }

            print("\nUpgrades:")
            for upgrade in upgrades {
                print("- \(upgrade.name), cost: \(upgrade.cost), description: \(upgrade.OverView)")
            }

            print("\nFactories:")
            for factory in factories {
                print("- \(factory.name), cost: \(factory.cost), count: \(factory.count), description: \(factory.OverView)")
            }
        }
}

// MARK: - GameState Class

class GameState: ObservableObject {
    @Published var model: GameStateModel
    
    init(model: GameStateModel) {
        self.model = model
        if model.resources.isEmpty {
            initializeResources()
        }
        if model.upgrades.isEmpty {
            initializeUpgrades()
        }
        if model.factories.isEmpty {
            initializeFactories()
        }
        
        
    }
    
    private func initializeResources() {
        model.resources = [
            ResourceModel(name: "Bits", amount: 0, perClick: 0.1, perSecond: 0),
            ResourceModel(name: "Qubits", amount: 0, perClick: 0, perSecond: 0)
        ]
    }
    
    private func initializeUpgrades() {
        model.upgrades = [
            UpgradeModel(icon: "creditcard", name: "Premium Licence", cost: 0.9, description: "You buy the Premium Software Licence \nIncrease bits per click by 0.1"),
            UpgradeModel(icon: "cursorarrow.click", name: "Double Clicks", cost: 49.9, description: "Double the number of bits per click"),
            UpgradeModel(icon: "cursorarrow.click.badge.clock", name: "Autoclicker", cost: 199.9, description: "Automatically generate 0.1 bits per second"),
            UpgradeModel(icon: "cursorarrow.click.2", name: "Triple Clicks", cost: 499.9, description: "Triple the number of bits per click"),
            UpgradeModel(icon: "dot.circle.and.cursorarrow", name: "Precision Clicking", cost: 1999.9, description: "Increase bits per click by 0.2 through improved accuracy"),
            UpgradeModel(icon: "cursorarrow.motionlines", name: "Quantum Clicker", cost: 4999.9, description: "Each click has a small chance to produce a qubit"),
            UpgradeModel(icon: "apple.terminal", name: "Automated Clicking Software", cost: 9999.9, description: "Increase the autoclicker speed to 0.2 bits per second"),
            UpgradeModel(icon: "network", name: "Network Clicks", cost: 49999.9, description: "Each click generates bits for every connected device, increasing bits per click by 0.5"),
            UpgradeModel(icon: "memorychip", name: "Ram Upgrade", cost: 9.9, description: "Faster RAM is installed \nPersonal Computers are 2x faster"),
            UpgradeModel(icon: "cpu", name: "CPU Upgrade", cost: 49.9, description: "The CPU is upgraded \nPersonal Computers are 2.5x faster"),
            UpgradeModel(icon: "fan", name: "Cooling System Upgrade", cost: 149.9, description: "The Cooling System is upgraded \nPersonal Computers are 1.5x faster"),
            UpgradeModel(icon: "externaldrive", name: "Storage Upgrade", cost: 999.9, description: "The Storage is upgraded \nPersonal Computers are 1.8x faster")
        ]
        
    }
    
    private func initializeFactories() {
        model.factories = [
            FactoryModel(icon: "pc", name: "Personal Computer", cost: 15, count: 0, description: "A basic home computer for simple data processing \nGenerates 0.1 bits per second"),
            FactoryModel(icon: "desktopcomputer", name: "Workstation", cost: 50, count: 0, description: "A more powerful computer designed for professional work \nGenerates 0.5 bits per second"),
            FactoryModel(icon: "wifi.router", name: "Mini Server", cost: 200, count: 0, description: "A small server suitable for a home or small office \nGenerates 2 bits per second"),
            FactoryModel(icon: "server.rack", name: "Server Rack", cost: 1000, count: 0, description: "A small cluster of servers for increased computing power. \nGenerates 10 bits per second")
        ]
    }
    
    var personalComputerCount: Int {
        model.factories.first { $0.name == "Personal Computer" }?.count ?? 0
    }
    
    func updatePersonalComputerOutput(multiplier: Double) {
        if let index = model.factories.firstIndex(where: { $0.name == "Personal Computer" }) {
            let baseOutput = 0.1
            let outputPerUnit = baseOutput * multiplier
            let totalOutput = outputPerUnit * Double(model.factories[index].count)
            
            if let resourceIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                model.resources[resourceIndex].perSecond = model.resources[resourceIndex].perSecond
                    - (baseOutput * Double(model.factories[index].count))
                    + totalOutput
            }
            
            model.factories[index].OverView = "Generate \(outputPerUnit) bits per second"
        }
    }
    
    func click() {
        if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
            model.resources[bitsIndex].amount += model.resources[bitsIndex].perClick
        }
        if model.quantumUnlocked, let qubitsIndex = model.resources.firstIndex(where: { $0.name == "Qubits" }) {
            model.resources[qubitsIndex].amount += model.resources[qubitsIndex].perClick
        }
    }
    
    func formatNumber(_ number: Double) -> String {
        let absNumber = abs(number)
        let sign = number < 0 ? "-" : ""
        
        switch absNumber {
        case 0..<1000:
            return String(format: "%@%.2f", sign, absNumber)
        case 1000..<1_000_000:
            return String(format: "%@%.2fK", sign, absNumber / 1000)
        case 1_000_000..<1_000_000_000:
            return String(format: "%@%.2fM", sign, absNumber / 1_000_000)
        case 1_000_000_000..<1_000_000_000_000:
            return String(format: "%@%.2fB", sign, absNumber / 1_000_000_000)
        default:
            return String(format: "%@%.2fT", sign, absNumber / 1_000_000_000_000)
        }
    }
    
    func buyUpgrade(_ upgradeIndex: Int) {
        guard upgradeIndex < model.upgrades.count else { return }
        let upgrade = model.upgrades[upgradeIndex]
        if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }),
           model.resources[bitsIndex].amount >= upgrade.cost {
            model.resources[bitsIndex].amount -= upgrade.cost
            applyUpgradeEffect(upgrade)
            model.upgrades.remove(at: upgradeIndex)
        }
    }
    
    private func applyUpgradeEffect(_ upgrade: UpgradeModel) {
        switch upgrade.name {
        case "Premium Licence":
            if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                model.resources[bitsIndex].perClick += 0.1
            }
        case "Double Clicks":
            if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                model.resources[bitsIndex].perClick *= 2
            }
        case "Autoclicker":
            if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                model.resources[bitsIndex].perSecond += 0.1
            }
        case "Triple Clicks":
            if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                model.resources[bitsIndex].perClick *= 3
            }
        case "Precision Clicking":
            if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                model.resources[bitsIndex].perClick += 0.2
            }
        case "Quantum Clicker":
            if let qubitsIndex = model.resources.firstIndex(where: { $0.name == "Qubits" }) {
                model.resources[qubitsIndex].perClick += 1
            }
            model.quantumUnlocked = true
        case "Automated Clicking Software":
            if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                model.resources[bitsIndex].perSecond += 0.2
            }
        case "Network Clicks":
            if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
                model.resources[bitsIndex].perClick += 0.5
            }
        case "Ram Upgrade":
            model.ramUpgradeBought = true
            updatePersonalComputerOutput(multiplier: 2.0)
        case "CPU Upgrade":
            model.cpuUpgradeBought = true
            updatePersonalComputerOutput(multiplier: 5)
        case "Cooling System Upgrade":
            model.coolingUpgradeBought = true
            updatePersonalComputerOutput(multiplier: 7.5)
        case "Storage Upgrade":
            model.storageUpgradeBought = true
            updatePersonalComputerOutput(multiplier: 13.5)
        default:
            break
        }
    }
    
    func buyFactory(_ factoryIndex: Int, quantity: Int = 1) {
        guard factoryIndex < model.factories.count else { return }
        let factory = model.factories[factoryIndex]
        let totalCost = factory.cost * (1 - pow(1.5, Double(quantity))) / (1 - 1.5)
        if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }),
           model.resources[bitsIndex].amount >= totalCost {
            model.resources[bitsIndex].amount -= totalCost
            for _ in 0..<quantity {
                applyFactoryEffect(factory)
                factory.count += 1
                factory.cost *= 1.2
            }
            model.factories[factoryIndex] = factory
        }
    }
    
    private func applyFactoryEffect(_ factory: FactoryModel) {
        if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }) {
            switch factory.name {
            case "Personal Computer":
                let output: Double
                if model.ramUpgradeBought && model.cpuUpgradeBought && model.coolingUpgradeBought && model.storageUpgradeBought {
                    output = 1.35
                } else if model.ramUpgradeBought && model.cpuUpgradeBought && model.coolingUpgradeBought {
                    output = 0.75
                } else if model.ramUpgradeBought && model.cpuUpgradeBought {
                    output = 0.5
                } else if model.ramUpgradeBought {
                    output = 0.2
                } else {
                    output = 0.1
                }
                model.resources[bitsIndex].perSecond += output
                model.personalComputerUnlocked = true
            case "Workstation":
                model.resources[bitsIndex].perSecond += 0.5
            case "Mini Server":
                model.resources[bitsIndex].perSecond += 2
            case "Server Rack":
                model.resources[bitsIndex].perSecond += 10
            default:
                break
            }
        }
    }
    
    func update() {
        for i in 0..<model.resources.count {
            model.resources[i].amount += model.resources[i].perSecond / 10
        }
    }
}
