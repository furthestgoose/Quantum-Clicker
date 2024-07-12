import SwiftUI

struct PrestigeView: View {
    @ObservedObject var gameState: GameState
    @State private var showingConfirmation = false

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    if let bitsResource = gameState.model.resources.first(where: { $0.name == "Bits" }) {
                        let qubitsResource = gameState.model.resources.first(where: { $0.name == "Qubits" })
                        StoreTopBar(bitsResource: bitsResource, qubitsResource: qubitsResource, gameState: gameState)
                    }

                    ScrollView {
                        VStack(alignment: .center, spacing: 20) {

                            PrestigeInfoCard(title: "Times Prestiged", value: "\(gameState.model.timesPrestiged)")
                            PrestigeInfoCard(title: "Current Prestige Points", value: "\(gameState.model.prestigePoints)")
                            PrestigeInfoCard(title: "Current Multiplier", value: "x\(String(format: "%.2f", gameState.model.prestigeMultiplier))")

                            VStack(alignment: .center, spacing: 10) {
                                Text("Prestiging will reset your progress, but you'll gain:")
                                    .font(.headline)
                                    .foregroundColor(.secondary)

                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    Text("\(gameState.model.availablePrestigePoints) Prestige Points")
                                }

                                HStack {
                                    Image(systemName: "multiply.circle.fill")
                                        .foregroundColor(.green)
                                    Text("x\(String(format: "%.2f", 0 + Double(gameState.model.availablePrestigePoints) * 0.1)) Production Multiplier")
                                }
                            }
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(10)

                            Button(action: {
                                showingConfirmation = true
                            }) {
                                Text("Prestige")
                                    .fontWeight(.bold)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(gameState.model.availablePrestigePoints > 0 ?
                                        (gameState.model.quantumUnlocked ? Color.purple : Color.blue) :
                                        Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .disabled(gameState.model.availablePrestigePoints == 0)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        .padding()
                    }
                }
                .ignoresSafeArea(edges: .top)
            }
            .navigationBarHidden(true)
            .alert("Confirm Prestige", isPresented: $showingConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Confirm", role: .destructive) {
                    gameState.performPrestige()
                }
            } message: {
                Text("Are you sure you want to prestige? This will reset your progress but grant you prestige bonuses.")
            }
        }
    }
}

struct PrestigeInfoCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}
