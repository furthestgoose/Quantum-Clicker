//
//  FactoriesView.swift
//  Quantum Clicker
//
//  Created by Adam Byford on 24/06/2024.
//

import SwiftUI

struct FactoriesView: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        NavigationView {
            List {
                ForEach(gameState.factories.indices, id: \.self) { index in
                    FactoryRow(gameState: gameState, factory: gameState.factories[index], index: index)
                }
            }
            .navigationTitle("Factories")
        }
    }
}

struct FactoryRow: View {
    @ObservedObject var gameState: GameState
    let factory: Factory
    let index: Int
    @State private var quantity = 1
    
    var canBuy: Bool {
        let totalCost = factory.cost * (1 - pow(1.5, Double(quantity))) / (1 - 1.5)
        return gameState.resources[0].amount >= totalCost
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(factory.name).font(.headline)
            Text(factory.description).font(.subheadline)
            Text("Owned: \(factory.count)").font(.caption)
            
            HStack {
                Stepper("Quantity: \(quantity)", value: $quantity, in: 1...100)
                    .frame(width: 200)
            }
            
            Button("Buy") {
                gameState.buyFactory(index, quantity: quantity)
            }
            .disabled(!canBuy)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(canBuy ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(5)
            
            let totalCost = factory.cost * (1 - pow(1.5, Double(quantity))) / (1 - 1.5)
            Text("\(Int(totalCost)) bits")
                .font(.caption)
                .foregroundColor(canBuy ? .blue : .gray)
        }
    }
}
