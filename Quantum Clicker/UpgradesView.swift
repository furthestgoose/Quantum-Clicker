//
//  UpgradesView.swift
//  Quantum Clicker
//
//  Created by Adam Byford on 24/06/2024.
//

import SwiftUI

struct UpgradesView: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        NavigationView {
            List {
                ForEach(gameState.upgrades.filter { $0.name != "Auto-Clicker Efficiency Improvements" && $0.name != "Auto-Clicker Output Improvements"} , id: \.id) { upgrade in
                    UpgradeRow(upgrade: upgrade,
                               canBuy: gameState.resources[0].amount >= upgrade.cost) {
                        if let index = gameState.upgrades.firstIndex(where: { $0.id == upgrade.id }) {
                            gameState.buyUpgrade(index)
                        }
                    }
                }
                
                // Display the "Auto-Clicker Interval" upgrade if AutoClickerUnlocked is true
                if gameState.AutoClickerUnlocked {
                    if let autoClickerUpgrade = gameState.upgrades.first(where: { $0.name == "Auto-Clicker Efficiency Improvements" }) {
                        UpgradeRow(upgrade: autoClickerUpgrade,
                                   canBuy: gameState.resources[0].amount >= autoClickerUpgrade.cost) {
                            if let index = gameState.upgrades.firstIndex(where: { $0.id == autoClickerUpgrade.id }) {
                                gameState.buyUpgrade(index)
                            }
                        }
                    }
                }
                
                // Display the "Auto-Clicker Output Improvements" upgrade if AutoClicker count is 50 or more
                if gameState.autoClickerCount >= 50 {
                    if let autoClickerUpgrade = gameState.upgrades.first(where: { $0.name == "Auto-Clicker Output Improvements" }) {
                        UpgradeRow(upgrade: autoClickerUpgrade,
                                   canBuy: gameState.resources[0].amount >= autoClickerUpgrade.cost) {
                            if let index = gameState.upgrades.firstIndex(where: { $0.id == autoClickerUpgrade.id }) {
                                gameState.buyUpgrade(index)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Upgrades")
        }
    }
}

struct UpgradeRow: View {
    let upgrade: Upgrade
    let canBuy: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(upgrade.name).font(.headline)
                Text(upgrade.description).font(.subheadline)
            }
            Spacer()
            VStack{
                Button("Buy", action: action)
                    .disabled(!canBuy)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(canBuy ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(5)
                
                Text("\(Int(upgrade.cost)) bits")
                    .font(.caption)
                    .foregroundColor(canBuy ? .blue : .gray)
            }
        }
    }
}
