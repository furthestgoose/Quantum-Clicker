import SwiftUI
import SwiftData

struct SplashScreenView: View {
    @ObservedObject var gameState: GameState
    @Binding var showSplash: Bool
    let earnedAmountBits: Double
    let earnedAmountQubits: Double
    let timeAway: TimeInterval
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                VStack(spacing: 20) {
                    Text("Welcome Back!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    Text("You were away for \(formattedTimeAway)")
                        .font(.title3)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Text("and earned:")
                        .font(.title3)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    HStack {
                        resourceDisplay(amount: earnedAmountBits, label: "Bits", icon: "square")
                            .padding()
                        
                        if gameState.model.quantumUnlocked {
                            resourceDisplay(amount: earnedAmountQubits, label: "Qubits", icon: "atom")
                        }
                    }
                    Text("Computers are \(gameState.model.offlineEfficiency == 0.75 ? "25%" : "50%") slower offline \n time away is capped at 8 hours")
                        .font(.subheadline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .opacity(0.9)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 16)
                
                Spacer()
                
                Button(action: {
                    showSplash = false
                }) {
                    Text("Continue")
                        .font(.title2)
                        .padding()
                        .frame(width: geometry.size.width * 0.8)
                        .background(gameState.model.quantumUnlocked ? Color.purple : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(colorScheme == .dark ? Color.black : Color.white)
        }
        .edgesIgnoringSafeArea(.all)
    }

    private func resourceDisplay(amount: Double, label: String, icon: String) -> some View {
        VStack(alignment: .center, spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .frame(width: 40, height: 40)
                .background(Color.gray.opacity(0.2))
                .clipShape(Circle())
            
            Text(gameState.formatNumber(amount))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }
    }
    
    private var formattedTimeAway: String {
        let days = Int(timeAway) / 86400
        let hours = (Int(timeAway) % 86400) / 3600
        let minutes = (Int(timeAway) % 3600) / 60
        let seconds = Int(timeAway) % 60
        var components: [String] = []

        if days > 0 { components.append("\(days)d") }
        if hours > 0 { components.append("\(hours)h") }
        if minutes > 0 { components.append("\(minutes)m") }
        if seconds > 0 { components.append("\(seconds)s") }

        return components.joined(separator: " ")
    }
}
