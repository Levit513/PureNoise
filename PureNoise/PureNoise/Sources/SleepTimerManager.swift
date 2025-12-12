import Foundation
import Combine

@MainActor
final class SleepTimerManager: ObservableObject {
    static let shared = SleepTimerManager()

    @Published private(set) var isActive: Bool = false
    @Published private(set) var endDate: Date?
    @Published private(set) var remainingSeconds: Int = 0

    private var tick: AnyCancellable?

    private init() {}

    func start(minutes: Int) {
        start(seconds: minutes * 60)
    }

    func start(seconds: Int) {
        guard seconds > 0 else { return }
        endDate = Date().addingTimeInterval(TimeInterval(seconds))
        isActive = true
        updateRemaining()

        tick?.cancel()
        tick = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateRemaining()
            }
    }

    func cancel() {
        tick?.cancel()
        tick = nil
        isActive = false
        endDate = nil
        remainingSeconds = 0
    }

    private func updateRemaining() {
        guard let endDate else {
            cancel()
            return
        }
        let remaining = Int(endDate.timeIntervalSinceNow.rounded(.down))
        remainingSeconds = max(0, remaining)

        // Fade out in the last 10 seconds
        if remainingSeconds == 10 {
            AudioManager.shared.fadeOutAndStop(duration: 10)
        }

        if remainingSeconds <= 0 {
            cancel()
        }
    }
}
