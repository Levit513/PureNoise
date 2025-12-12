import AVFoundation
import Foundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    private var player: AVAudioPlayer?
    @Published var isPlaying = false
    @Published var currentSound = ""

    private init() {}

    func playSound(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "m4a") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1 // Loop forever
            player?.prepareToPlay()
            player?.play()
            isPlaying = true
            currentSound = name
        } catch {
            print("Error playing sound: \(error)")
        }
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func stop() {
        player?.stop()
        isPlaying = false
        currentSound = ""
    }
}
