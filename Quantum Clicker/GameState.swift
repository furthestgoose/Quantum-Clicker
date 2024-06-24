import Foundation

class GameState: ObservableObject {
    @Published var resources: [Resource]
    @Published var upgrades: [Upgrade]
    @Published var factories: [Factory]
    @Published var quantumUnlocked = false
    @Published var PersonalComputerUnlocked = false
    @Published var ramUpgradeBought = false
    @Published var cpuUpgradeBought = false
    @Published var coolingUpgradeBought = false
    @Published var storageUpgradeBought = false
    
    init() {
        resources = [
            Resource(name: "Bits", amount: 0, perClick: 0.1, perSecond: 0),
            Resource(name: "Qubits", amount: 0, perClick: 0, perSecond: 0)
        ]
        
        upgrades = [
            // MARK: clicker upgrades
            Upgrade(icon: "creditcard", name: "Premium Licence", cost: 0.9, effect: { state in
                state.resources[0].perClick += 0.1
                        }, description: "You buy the Premium Software Licence \nIncrease bits per click by 0.1"),
            Upgrade(icon: "cursorarrow.click", name: "Double Clicks", cost: 49.9, effect: { state in
                            state.resources[0].perClick *= 2
                        }, description: "Double the number of bits per click"),
            Upgrade(icon: "cursorarrow.click.badge.clock", name: "Autoclicker", cost: 199.9, effect: { state in
                            state.resources[0].perSecond += 0.1
                        }, description: "Automatically generate 0.1 bits per second"),
            Upgrade(icon: "cursorarrow.click.2", name: "Triple Clicks", cost: 499.9, effect: { state in
                            state.resources[0].perClick *= 3
                        }, description: "Triple the number of bits per click"),
            Upgrade(icon: "dot.circle.and.cursorarrow", name: "Precision Clicking", cost: 1999.9, effect: { state in
                            state.resources[0].perClick += 0.2
                        }, description: "Increase bits per click by 0.2 through improved accuracy"),
            Upgrade(icon: "cursorarrow.motionlines", name: "Quantum Clicker", cost: 4999.9, effect: { state in
                            state.resources[1].perClick += 1
                        }, description: "Each click has a small chance to produce a qubit"),
            Upgrade(icon: "apple.terminal", name: "Automated Clicking Software", cost: 9999.9, effect: { state in
                            state.resources[0].perSecond += 0.2
                        }, description: "Increase the autoclicker speed to 0.2 bits per second"),
            Upgrade(icon: "network", name: "Network Clicks", cost: 49999.9, effect: { state in
                            state.resources[0].perClick += 0.5
                        }, description: "Each click generates bits for every connected device, increasing bits per click by 0.5"),
            //MARK: personal computer upgrades
            Upgrade(icon: "memorychip",name: "Ram Upgrade", cost: 9.9, effect: { state in
                state.ramUpgradeBought = true
                state.updatePersonalComputerOutput(multiplier: 2.0)
            }, description: "Faster RAM is installed \nPersonal Computers are 2x faster"),
            Upgrade(icon: "cpu", name: "CPU Upgrade", cost: 49.9, effect: { state in
                state.cpuUpgradeBought = true
                state.updatePersonalComputerOutput(multiplier: 5)
            }, description: "The CPU is upgraded \nPersonal Computers are 2.5x faster"),
            Upgrade(icon: "cpu", name: "Cooling System Upgrade", cost: 149.9, effect: { state in
                state.coolingUpgradeBought = true
                state.updatePersonalComputerOutput(multiplier: 7.5)
            }, description: "The Cooling System is upgraded \nPersonal Computers are 1.5x faster"),
            Upgrade(icon: "cpu", name: "Storage Upgrade", cost: 999.9, effect: { state in
                state.storageUpgradeBought = true
                state.updatePersonalComputerOutput(multiplier: 13.5)
            }, description: "The Cooling System is upgraded \nPersonal Computers are 1.8x faster")
        ]
        
        factories = [
            Factory(icon: "pc",name: "Personal Computer", cost: 15, effect: { state in
                if state.ramUpgradeBought && state.cpuUpgradeBought && state.coolingUpgradeBought && state.storageUpgradeBought{
                    state.resources[0].perSecond += 1.35
                }else if state.ramUpgradeBought && state.cpuUpgradeBought && state.coolingUpgradeBought{
                    state.resources[0].perSecond += 0.75
                }else if state.ramUpgradeBought && state.cpuUpgradeBought{
                    state.resources[0].perSecond += 0.5
                }else if state.ramUpgradeBought{
                    state.resources[0].perSecond += 0.2
                }else{
                    state.resources[0].perSecond += 0.1
                }
                
                state.PersonalComputerUnlocked = true
            }, description: "A basic home computer for simple data processing \nGenerates 0.1 bits per second"),
            Factory(icon: "desktopcomputer",name: "Workstation", cost: 50, effect: { state in
                state.resources[0].perSecond += 0.5
            }, description: "A more powerful computer designed for professional work \nGenerates 0.5 bits per second"),
            Factory(icon: "wifi.router",name: "Mini Server", cost: 200, effect: { state in
                state.resources[0].perSecond += 2
            }, description: "A small server suitable for a home or small office \nGenerates 2 bits per second"),
            Factory(icon: "server.rack",name: "Server Rack", cost: 1000, effect: { state in
                state.resources[0].perSecond += 10
            }, description: "A small cluster of servers for increased computing power. \nGenerates 10 bits per second"),
        ]
    }
    
    var PersonalComputerCount: Int {
        factories.first { $0.name == "Personal Computer" }?.count ?? 0
    }
    
    func updatePersonalComputerOutput(multiplier: Double) {
        
            if let index = factories.firstIndex(where: { $0.name == "Personal Computer" }) {
                let baseOutput = 0.1
                let outputPerUnit = baseOutput * multiplier
                let totalOutput = outputPerUnit * Double(factories[index].count)
                
                // Update the total output for Personal Computers
                resources[0].perSecond = resources[0].perSecond
                    - (baseOutput * Double(factories[index].count)) // Remove old output
                    + totalOutput // Add new output
                
                // Update the description
                factories[index].description = "Generate \(outputPerUnit) bits per second"
            }
        }
    
    func click() {
        resources[0].amount += resources[0].perClick
        if quantumUnlocked {
            resources[1].amount += resources[1].perClick
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
        guard upgradeIndex < upgrades.count else { return }
        let upgrade = upgrades[upgradeIndex]
        if resources[0].amount >= upgrade.cost {
            resources[0].amount -= upgrade.cost
            upgrade.effect(self)
            upgrades.remove(at: upgradeIndex)
        }
    }
    
    func buyFactory(_ factoryIndex: Int, quantity: Int = 1) {
        guard factoryIndex < factories.count else { return }
        var factory = factories[factoryIndex]
        let totalCost = factory.cost * (1 - pow(1.5, Double(quantity))) / (1 - 1.5)
        if resources[0].amount >= totalCost {
            resources[0].amount -= totalCost
            for _ in 0..<quantity {
                factory.effect(self)
                factory.count += 1
                factory.cost *= 1.2
            }
            factories[factoryIndex] = factory
        }
    }
    
    func update() {
        for i in 0..<resources.count {
            resources[i].amount += resources[i].perSecond / 10
        }
    }
}
