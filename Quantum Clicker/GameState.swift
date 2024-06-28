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
    var workstationCPUUpgradeBought: Bool
    var workstationRAMUpgradeBought: Bool
    var workstationGPUUpgradeBought: Bool
    var workstationNetworkUpgradeBought: Bool
    
    @Relationship(deleteRule: .cascade) var resources: [ResourceModel]
    @Relationship(deleteRule: .cascade) var upgrades: [UpgradeModel]
    @Relationship(deleteRule: .cascade) var factories: [FactoryModel]
    
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
            UpgradeModel(icon: "memorychip", name: "RAM Upgrade", cost: 9.9, description: "Faster RAM is installed \nPersonal Computers are 2x faster"),
            UpgradeModel(icon: "cpu", name: "CPU Upgrade", cost: 49.9, description: "The CPU is upgraded \nPersonal Computers are 2.5x faster"),
            UpgradeModel(icon: "fan", name: "Cooling System Upgrade", cost: 149.9, description: "The Cooling System is upgraded \nPersonal Computers are 1.5x faster"),
            UpgradeModel(icon: "externaldrive", name: "Storage Upgrade", cost: 999.9, description: "The Storage is upgraded \nPersonal Computers are 1.8x faster"),
            UpgradeModel(icon: "clock.arrow.circlepath", name: "Processor Overclock", cost: 499.9, description: "Enhanced CPU performance \nWorkstations are 2x faster"),
            UpgradeModel(icon: "memorychip", name: "RAM Expansion", cost: 1999.9, description: "Increased memory capacity \nWorkstations are 2.5x faster"),
            UpgradeModel(icon: "gamecontroller", name: "Graphics Accelerator", cost: 4999.9, description: "Advanced GPU for improved processing \nWorkstations are 1.5x"),
            UpgradeModel(icon: "network", name: "High-Speed Network Interface", cost: 9999.9, description: "Improved data transfer capabilities \nWorkstations are 1.8x faster"),
            UpgradeModel(icon: "testtube.2", name: "Quantum Research Lab", cost: 99999999.9, description: "Unlocks the Quantum Era")
        ]
        
    }
    
    private func initializeFactories() {
        model.factories = [
            FactoryModel(icon: "pc", name: "Personal Computer", cost: 14.9 ,costResourceType: "Bits", count: 0, OverView: "A basic home computer for simple data processing \nGenerates 0.1 bits per second"),
            FactoryModel(icon: "desktopcomputer", name: "Workstation", cost: 49.9, costResourceType: "Bits", count: 0, OverView: "A more powerful computer designed for professional work \nGenerates 0.5 bits per second"),
            FactoryModel(icon: "wifi.router", name: "Mini Server", cost: 199.9, costResourceType: "Bits", count: 0, OverView: "A small server suitable for a home or small office \nGenerates 2 bits per second"),
            FactoryModel(icon: "server.rack", name: "Server Rack", cost: 999.9, costResourceType: "Bits", count: 0, OverView: "A small cluster of servers for increased computing power. \nGenerates 10 bits per second"),
            FactoryModel(icon: "cloud", name: "Server Farm", cost: 4999.9, costResourceType: "Bits", count: 0, OverView: "A collection of server racks working in unison for increased processing power \nGenerates 50 bits per second"),
            FactoryModel(icon: "cpu", name: "Mainframe", cost: 24999.9, costResourceType: "Bits", count: 0, OverView: "A large, powerful computer system capable of handling multiple complex tasks simultaneously \nGenerates 250 bits per second"),
            FactoryModel(icon: "memorychip", name: "Vector Processor", cost: 99999.9, costResourceType: "Bits", count: 0, OverView: "Specialized high-performance computer optimized for scientific and graphical calculations \nGenerates 1000 bits per second"),
            FactoryModel(icon: "waveform.path.ecg", name: "Parallel Processing Array", cost: 499999.9, costResourceType: "Bits", count: 0, OverView: "A system of interconnected processors working on shared tasks \nGenerates 5000 bits per second"),
            FactoryModel(icon: "brain", name: "Neural Network Computer", cost: 1999999.9, costResourceType: "Bits", count: 0, OverView: "Advanced system mimicking brain structure for complex pattern recognition \nGenerates 20000 bits per second"),
            FactoryModel(icon: "bolt.fill", name: "Supercomputer", cost: 9999999.9, costResourceType: "Bits", count: 0, OverView: "Cutting-edge high-performance computing system for the most demanding computational tasks \nGenerates 100000 bits per second"),
            FactoryModel(icon: "Atom", name: "Basic Quantum Computer", cost: 5, costResourceType: "Qubits", count: 0, OverView: "An entry-level quantum computing system capable of executing fundamental quantum algorithms.\nGenerates 1 Qubit per second.")
        ]
    }
    
    var personalComputerCount: Int {
        model.factories.first { $0.name == "Personal Computer" }?.count ?? 0
    }
    
    var workstationCount: Int {
        model.factories.first { $0.name == "Workstation" }?.count ?? 0
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
    
    func updateWorkstation(multiplier: Double){
        if let index = model.factories.firstIndex(where: { $0.name == "Workstation" }) {
            let baseOutput = 0.5
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
        if let bitsIndex = model.resources.firstIndex(where: { $0.name == "Bits" }),
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
                model.resources[bitsIndex].perClick += 0.1
            }
            model.quantumUnlocked = true
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
        case "RAM Upgrade":
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
        case "Processor Overclock":
            model.workstationCPUUpgradeBought = true
            updateWorkstation(multiplier: 2)
        case "RAM Expansion":
            model.workstationRAMUpgradeBought = true
            updateWorkstation(multiplier: 5)
        case "Graphics Accelerator":
            model.workstationGPUUpgradeBought = true
            updateWorkstation(multiplier: 7.5)
        case "High-Speed Network Interface":
            model.workstationNetworkUpgradeBought = true
            updateWorkstation(multiplier: 13.5)
        default:
            break
        }
    }
    
    func buyFactory(_ factoryIndex: Int, quantity: Int = 1) {
        guard factoryIndex < model.factories.count else { return }
        let factory = model.factories[factoryIndex]
        let totalCost = factory.cost * (1 - pow(1.5, Double(quantity))) / (1 - 1.5)
        
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
                let output: Double
                if model.workstationCPUUpgradeBought && model.workstationGPUUpgradeBought && model.workstationRAMUpgradeBought && model.workstationNetworkUpgradeBought {
                    output = 6.75
                } else if model.workstationCPUUpgradeBought && model.workstationRAMUpgradeBought && model.workstationGPUUpgradeBought {
                    output = 3.75
                } else if model.workstationCPUUpgradeBought && model.workstationRAMUpgradeBought {
                    output = 2.5
                } else if model.workstationCPUUpgradeBought {
                    output = 1
                } else {
                    output = 0.5
                }
                model.resources[bitsIndex].perSecond += output
            case "Mini Server":
                model.resources[bitsIndex].perSecond += 2
            case "Server Rack":
                model.resources[bitsIndex].perSecond += 10
            case "Server Farm":
                model.resources[bitsIndex].perSecond += 50
            case "Mainframe":
                model.resources[bitsIndex].perSecond += 250
            case "Vector Processor":
                model.resources[bitsIndex].perSecond += 1000
            case "Parallel Processing Array":
                model.resources[bitsIndex].perSecond += 5000
            case "Neural Network Computer":
                model.resources[bitsIndex].perSecond += 20000
            case "Supercomputer":
                model.resources[bitsIndex].perSecond += 100000
            case "Basic Quantum Computer":
                model.resources[qubitsIndex].perSecond += 1
            default:
                break
            }
        }
    }
    
    func update() {
        for i in 0..<model.resources.count {
            model.resources[i].amount += model.resources[i].perSecond
        }
    }
}
