//
//  GameState.swift
//  Quantum Clicker
//
//  Created by Adam Byford on 24/06/2024.
//

import Foundation

class GameState: ObservableObject {
    @Published var resources: [Resource]
    @Published var upgrades: [Upgrade]
    @Published var factories: [Factory]
    @Published var quantumUnlocked = false
    @Published var AutoClickerUnlocked = false
    
    init() {
        resources = [
            Resource(name: "Bits", amount: 0, perClick: 1, perSecond: 0),
            Resource(name: "Qubits", amount: 0, perClick: 0, perSecond: 0)
        ]
        
        upgrades = [
            Upgrade(name: "Faster Fingers", cost: 10, effect: { state in
                state.resources[0].perClick += 1
            }, description: "Increase bits per click"),
            Upgrade(name: "Quantum Research", cost: 1000, effect: { state in
                state.quantumUnlocked = true
                state.resources[1].perClick = 0.001
            }, description: "Unlock Quantum Computing"),
            Upgrade(name: "Auto-Clicker Efficiency Improvements", cost: 1, effect: { state in
                    if let autoClickerFactory = state.factories.first(where: { $0.name == "Auto-Clicker" }) {
                        let additionalPerSecond = 0.1 * Double(autoClickerFactory.count)
                        state.resources[0].perSecond += additionalPerSecond
                    }
                }, description: "Auto-Clickers take 0.9 secs to produce 1 bit"),
            Upgrade(name: "Auto-Clicker Output Improvements", cost: 1, effect: { state in
                    if let autoClickerFactory = state.factories.first(where: { $0.name == "Auto-Clicker" }) {
                        let additionalPerSecond = 0.5 * Double(autoClickerFactory.count)
                        state.resources[0].perSecond += additionalPerSecond
                    }
                }, description: "Auto-Clickers produce 0.5 more bits per second")
            
        ]
        
        factories = [
            Factory(name: "Auto-Clicker", cost: 50, effect: { state in
                state.resources[0].perSecond += 1
                state.AutoClickerUnlocked = true
            }, description: "Generate 1 bit per second")
        ]
    }
    
    var autoClickerCount: Int {
            factories.first { $0.name == "Auto-Clicker" }?.count ?? 0
        }
    
    func click() {
        resources[0].amount += resources[0].perClick
        if quantumUnlocked {
            resources[1].amount += resources[1].perClick
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
                    factory.cost *= 1.5
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
