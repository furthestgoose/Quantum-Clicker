import SwiftUI
import SwiftData

struct ClickerView: View {
    @ObservedObject var gameState: GameState
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                VStack(spacing: 0) {
                    if let bitsResource = gameState.model.resources.first(where: { $0.name == "Bits" }) {
                        let qubitsResource = gameState.model.resources.first(where: { $0.name == "Qubits" })
                        TopBar(gameState: gameState, resource: bitsResource, qubitsResource: qubitsResource, screenSize: geometry.size)
                    }
                    
                    TappableArea(gameState: gameState, screenSize: geometry.size) {
                        gameState.click()
                    }
                }
                .edgesIgnoringSafeArea(.top)
                .navigationTitle("Quantum Clicker")
                .navigationBarHidden(true)
            }
        }
    }
}

struct TopBar: View {
    @ObservedObject var gameState: GameState
    let resource: ResourceModel
    let qubitsResource: ResourceModel?
    let screenSize: CGSize
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: UIApplication.shared.windows.first?.safeAreaInsets.top ?? 20)
            
            Text("Era: \(gameState.model.quantumUnlocked ? "Quantum" : "Classical")")
                .foregroundColor(.white)
                .font(.system(size: fontSize(for: screenSize, baseFontSize: 20, maxSize: 24), weight: .bold))
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
        .frame(width: screenSize.width, height: screenSize.height * 0.25)
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
        .shadow(color: Color.primary.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }
    
    private func resourceDisplay(amount: Double, perSecond: Double, label: String, icon: String) -> some View {
        VStack(alignment: .center, spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: fontSize(for: screenSize, baseFontSize: 24, maxSize: 28)))
                .foregroundColor(.white)
                .frame(width: iconSize(for: screenSize), height: iconSize(for: screenSize))
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
            
            Text(gameState.formatNumber(amount))
                .font(.system(size: fontSize(for: screenSize, baseFontSize: 20, maxSize: 24), weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text(label)
                .font(.system(size: fontSize(for: screenSize, baseFontSize: 14, maxSize: 16), weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            Text("\(gameState.formatNumber(perSecond))/s")
                .font(.system(size: fontSize(for: screenSize, baseFontSize: 12, maxSize: 14), weight: .regular))
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }
}

struct TappableArea: View {
    @ObservedObject var gameState: GameState
    let screenSize: CGSize
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Info panel
            VStack(spacing: 10) {
                Text("Click to earn:")
                    .font(.system(size: fontSize(for: screenSize, baseFontSize: 18, maxSize: 20), weight: .bold))
                HStack(spacing: 20) {
                    resourceInfo(
                        icon: "square",
                        value: gameState.model.resources.first(where: { $0.name == "Bits" })?.perClick ?? 0,
                        label: "Bits"
                    )
                    if gameState.model.quantumUnlocked {
                        resourceInfo(
                            icon: "atom",
                            value: gameState.model.resources.first(where: { $0.name == "Qubits" })?.perClick ?? 0,
                            label: "Qubits"
                        )
                    }
                }
            }
            .padding()
            .background(Color.primary.opacity(0.05))
            .cornerRadius(15)
            .shadow(radius: 5)
            
            Spacer()
            
            // Clickable area
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: gameState.model.quantumUnlocked ?
                                [ .white, .purple] :
                                [.white, .blue]),
                            center: .center,
                            startRadius: 5,
                            endRadius: clickableAreaSize(for: screenSize) / 2
                        )
                    )
                    .frame(width: clickableAreaSize(for: screenSize), height: clickableAreaSize(for: screenSize))
                    .shadow(color: gameState.model.quantumUnlocked ? .purple.opacity(0.3) : .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                
                VStack {
                    Image(systemName: "hand.tap.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: clickableAreaSize(for: screenSize) * 0.4, height: clickableAreaSize(for: screenSize) * 0.4)
                    
                    Text("Tap Here!")
                        .font(.system(size: fontSize(for: screenSize, baseFontSize: 20, maxSize: 24), weight: .bold))
                }
                .foregroundColor(colorScheme == .dark ? .black : .white)
            }
            .onTapGesture {
                action()
            }
            
            Spacer()
            
            Text("Tap the circle to generate resources!")
                .font(.system(size: fontSize(for: screenSize, baseFontSize: 16, maxSize: 18)))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .frame(width: screenSize.width, height: screenSize.height * 0.75)
        .background(Color.primary.opacity(0.05))
    }
    
    private func resourceInfo(icon: String, value: Double, label: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(gameState.model.quantumUnlocked ? .purple : .blue)
                .font(.system(size: fontSize(for: screenSize, baseFontSize: 18, maxSize: 20)))
            VStack(alignment: .leading) {
                Text(gameState.formatNumber(value))
                    .font(.system(size: fontSize(for: screenSize, baseFontSize: 16, maxSize: 18), weight: .bold))
                Text(label)
                    .font(.system(size: fontSize(for: screenSize, baseFontSize: 14, maxSize: 16)))
                    .foregroundColor(.secondary)
            }
        }
    }
}

// Helper functions for scaling
func fontSize(for size: CGSize, baseFontSize: CGFloat, maxSize: CGFloat) -> CGFloat {
    let scaleFactor = min(size.width, size.height) / 390 // Base on iPhone 12 Pro
    return min(max(baseFontSize * scaleFactor, baseFontSize), maxSize)
}

func iconSize(for size: CGSize) -> CGFloat {
    let baseSize: CGFloat = 40
    let scaleFactor = min(size.width, size.height) / 390
    return min(max(baseSize * scaleFactor, baseSize), 50)
}

func clickableAreaSize(for size: CGSize) -> CGFloat {
    let baseSize: CGFloat = 200
    let scaleFactor = min(size.width, size.height) / 390
    let maxSize: CGFloat = 300
    return min(max(baseSize * scaleFactor, baseSize), maxSize)
}
