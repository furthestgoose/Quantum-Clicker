import SwiftUI
import SwiftData
import BackgroundTasks

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var gameStateModels: [GameStateModel]
    @State private var gameState: GameState?
    @State private var showSplash: Bool = false
    @State private var earnedAmountBits: Double = 0.0
    @State private var earnedAmountQubits: Double = 0.0
    @State private var timeAway: TimeInterval = 0.0
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            if showSplash, let gameState = gameState{
                    SplashScreenView(gameState: gameState, showSplash: $showSplash, earnedAmountBits: earnedAmountBits, earnedAmountQubits: earnedAmountQubits, timeAway: timeAway)
                
            } else if let gameState = gameState {
                TabView {
                    ClickerView(gameState: gameState)
                        .tabItem {
                            Label("Clicker", systemImage: "hand.tap.fill")
                        }
                    
                    StoreView(gameState: gameState)
                                            .tabItem {
                                                if gameState.canAffordAnyItem() {
                                                    Label("Store", systemImage: "exclamationmark.circle")
                                                        
                                                } else {
                                                    Label("Store", systemImage: "storefront.fill")
                                                }
                                            }
                    
                    StatsView(gameState: gameState)
                        .tabItem {
                            Label("Stats", systemImage: "chart.bar.fill")
                        }
                }
                .accentColor(gameState.model.quantumUnlocked ? .purple : .blue)
                .onReceive(timer) { _ in
                    gameState.update()
                    try? modelContext.save()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    calculateOfflineProgress()
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if gameState == nil {
                let gameStateModel: GameStateModel
                if let existingModel = gameStateModels.first {
                    gameStateModel = existingModel
                } else {
                    gameStateModel = GameStateModel()
                    modelContext.insert(gameStateModel)
                }
                gameState = GameState(model: gameStateModel)
                
                // Calculate offline progress on app launch
                calculateOfflineProgress()
            }
            BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.name.adambyford.Quantum-Clicker.refresh", using: nil) { task in
                self.handleAppRefresh(task: task as! BGAppRefreshTask)
            }
        }
    }

    func calculateOfflineProgress() {
            if let terminationTime = UserDefaults.standard.object(forKey: "terminationTime") as? Date {
                let now = Date()
                let timeDifference = now.timeIntervalSince(terminationTime)
                let secondsElapsed = Int(timeDifference)
                
                // Cap offline progress to a maximum of 8 hours
                let cappedSeconds = min(secondsElapsed, 8 * 60 * 60)
                
                var bitsEarnings: Double = 0.0
                var qubitsEarnings: Double = 0.0
                
                for resource in gameState!.model.resources {
                    let generatedAmount = resource.perSecond * Double(cappedSeconds)
                    // Apply a 50% efficiency rate for offline production
                    let adjustedAmount = generatedAmount * 0.5
                    resource.amount += adjustedAmount
                    
                    if resource.name == "Bits" {
                        bitsEarnings += adjustedAmount
                    } else if resource.name == "Qubits" {
                        qubitsEarnings += adjustedAmount
                    }
                }
                
                gameState!.model.lastUpdateTime = now
                earnedAmountBits = bitsEarnings
                earnedAmountQubits = qubitsEarnings
                timeAway = Double(cappedSeconds)
                showSplash = bitsEarnings > 0 || qubitsEarnings > 0
            }
        }

    func handleAppRefresh(task: BGAppRefreshTask) {
        // Schedule a new refresh task
        gameState?.scheduleAppRefresh()
        
        // Create a task to update the game state
        let updateTask = Task {
            gameState?.calculateOfflineProgress()
            try? modelContext.save()
        }
        
        // Inform the system when the update is complete
        task.expirationHandler = {
            updateTask.cancel()
        }
    }
}


