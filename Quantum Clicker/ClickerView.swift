//
//  ClickerView.swift
//  Quantum Clicker
//
//  Created by Adam Byford on 24/06/2024.
//

import SwiftUI
import SwiftData

struct ClickerView: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let bitsResource = gameState.model.resources.first(where: { $0.name == "Bits" }) {
                    let qubitsResource = gameState.model.resources.first(where: { $0.name == "Qubits" })
                    TopBar(gameState: gameState, resource: bitsResource, qubitsResource: qubitsResource)
                }
                
                TappableArea(perClick: gameState.model.resources.first(where: { $0.name == "Bits" })?.perClick ?? 0.1) {
                    gameState.click()
                }
            }
            .edgesIgnoringSafeArea(.top)
            .navigationTitle("Quantum Clicker")
            .navigationBarHidden(true)
        }
    }
}

struct TopBar: View {
    @ObservedObject var gameState: GameState
    let resource: ResourceModel
    let qubitsResource: ResourceModel?
    
    var body: some View {
        VStack(spacing: 0) {
            // Spacer to account for dynamic island
            Spacer()
                .frame(height: 60)
            
            Text ("Era: \(gameState.model.quantumUnlocked ? "Quantum" : "Classical")")
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .bold))
                .padding(.top, 10)
            
            HStack(spacing: 20) {
                resourceDisplay(amount: resource.amount, perSecond: resource.perSecond, label: "Bits", icon: "square")
                if gameState.model.quantumUnlocked, let qubits = qubitsResource {
                    Divider().background(Color.white.opacity(0.3))
                    resourceDisplay(amount: qubits.amount, perSecond: qubits.perSecond, label: "Qubits", icon: "atom")
                }
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 20)
        }
        .frame(height: 220) // Increased height to accommodate for dynamic island
        .frame(width: 1000)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    gameState.model.quantumUnlocked ? Color.purple : Color.blue,
                    gameState.model.quantumUnlocked ? Color.purple.opacity(0.7) : Color.blue.opacity(0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 16)
        .padding(.top, 0) // Removed top padding as we're using Spacer
        .padding(.bottom, 10)
    }
    
    private func resourceDisplay(amount: Double, perSecond: Double, label: String, icon: String) -> some View {
        VStack(alignment: .center, spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
            
            Text(gameState.formatNumber(amount))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            Text("\(gameState.formatNumber(perSecond))/s")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }
}

struct RoundedCornersShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct TappableArea: View {
    let perClick: Double
    let action: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                    .opacity(0.5)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    
                
                VStack {
                    Image(systemName: "hand.tap.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.black)
                    Text("Click here to earn \(String(format: "%.2f", perClick)) \(perClick == 1 ? "bit" : "bits")")
                        .foregroundColor(.black)
                        .font(.headline)
                }
                
            }
            .onTapGesture {
                action()
            }
        }
    }
}
