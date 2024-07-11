import SwiftUI
import SwiftData

struct SplashScreenView: View {
    @ObservedObject var gameState: GameState
    @Binding var showSplash: Bool
    let earnedAmountBits: Double
    let earnedAmountQubits: Double
    let timeAway: TimeInterval

    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 20) {
                Text("Welcome Back!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("You were away for \(formattedTimeAway)")
                    .font(.title3)
                    .foregroundColor(.white)
                Text("and earned:")
                    .font(.title3)
                    .foregroundColor(.white)
                HStack{
                    resourceDisplay(amount: earnedAmountBits, label: "Bits", icon: "square")
                    
                        .padding()
                    
                    if gameState.model.quantumUnlocked {
                        resourceDisplay(amount: earnedAmountQubits, label: "Qubits", icon: "atom")
                    }
                }
                Text("Computers are \(gameState.model.offlineEfficiency == 0.75 ? "25%" : "50%") slower offline \n time away is capped at 8 hours")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .opacity(0.9)
            }
            .padding()
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
            .padding(.horizontal, 16)
            
            Spacer()
            
            Button(action: {
                showSplash = false
            }) {
                Text("Continue")
                    .font(.title2)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(gameState.model.quantumUnlocked ? .purple : .blue)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .frame(width: 10000)
        .padding()
        .background(gameState.model.quantumUnlocked ? Color.purple : Color.blue)
        .edgesIgnoringSafeArea(.all)
    }

    private func resourceDisplay(amount: Double, label: String, icon: String) -> some View {
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
        }
    }
    
    private var formattedTimeAway: String {
            let days = Int(timeAway) / 86400
            let hours = (Int(timeAway) % 86400) / 3600
            let minutes = (Int(timeAway) % 3600) / 60
            let seconds = Int(timeAway) % 60
            var components: [String] = []

            if days > 0 {
                components.append("\(days)d")
            }
            if hours > 0 {
                components.append("\(hours)h")
            }
            if minutes > 0 {
                components.append("\(minutes)m")
            }
            if seconds > 0 {
                components.append("\(seconds)s")
            }

            return components.joined(separator: " ")
        }
}

