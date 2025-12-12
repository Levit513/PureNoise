import SwiftUI

@main
struct PureNoiseApp: App {
    @StateObject private var audio = AudioManager.shared
    @StateObject private var purchases = PurchasesManager.shared
    @StateObject private var sleepTimer = SleepTimerManager.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(audio)
                .environmentObject(purchases)
                .environmentObject(sleepTimer)
                .task {
                    purchases.configureIfPossible()
                    audio.configureAudioSession()
                    audio.configureRemoteCommands()
                }
        }
    }
}
