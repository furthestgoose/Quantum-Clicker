import SwiftUI
import SwiftData
import BackgroundTasks

@main
struct Quantum_ClickerApp: App {
    init() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.name.adambyford.Quantum-Clicker.refresh", using: nil) { task in
            // This is just to register the background task. The actual handling is in ContentView.
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: .main) { _ in
                    UserDefaults.standard.set(Date(), forKey: "terminationTime")
                }
    }
    
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [GameStateModel.self, UpgradeModel.self])
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background {
                UserDefaults.standard.set(Date(), forKey: "terminationTime")
            }
        }
    }
}
