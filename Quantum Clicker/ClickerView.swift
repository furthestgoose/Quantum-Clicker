//
//  ClickerView.swift
//  Quantum Clicker
//
//  Created by Adam Byford on 24/06/2024.
//

import SwiftUI

struct ClickerView: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TopBar(resource: gameState.resources[0])
                
                TappableArea(perClick: gameState.resources[0].perClick) {
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
    let resource: Resource
    
    var body: some View {
        VStack {
            Image(systemName: "desktopcomputer")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .foregroundColor(.white)
                .overlay(
                    VStack {
                        Text("\(Int(resource.amount)) \(Int(resource.amount) == 1 ? "bit" : "bits")")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("\(String(format: "%.2f", resource.perSecond))/s")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                        .padding(.bottom, 30)
                )
        }
        .padding(.top, 30)
        .frame(height: 250)
        .frame(maxWidth: .infinity)
        .background(Color.blue.opacity(0.5))
        .clipShape(RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 20))
        .padding(.bottom, 10)
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
                    Text("Click here to earn \(Int(perClick)) \(Int(perClick) == 1 ? "bit" : "bits")")
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
