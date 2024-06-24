//
//  StatsView.swift
//  Quantum Clicker
//
//  Created by Adam Byford on 24/06/2024.
//

import SwiftUI

struct StatsView: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        NavigationView {
            List {
                ForEach(gameState.resources) { resource in
                    Section(header: Text(resource.name)) {
                        Text("Total: \(Int(resource.amount))")
                        Text("Per click: \(String(format: "%.1f", resource.perClick))")
                        Text("Per second: \(String(format: "%.1f", resource.perSecond))")
                    }
                }
            }
            .navigationTitle("Statistics")
        }
    }
}
