import AVFoundation
import Combine
import MediaPlayer

@MainActor
final class AudioManager: ObservableObject {
    static let shared = AudioManager()

    @Published private(set) var currentSoundID: String?
    @Published private(set) var isPlaying: Bool = false
    @Published var volume: Float = 1.0 {
        didSet { player?.volume = volume }
    }

    private var player: AVAudioPlayer?
    private var fadeCancellable: AnyCancellable?

    private init() {}

    func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            try session.setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }

    func play(sound: Sound) {
        stop(resetNowPlaying: false)

        guard let url = Bundle.main.url(forResource: sound.filename, withExtension: "wav", subdirectory: "Sounds") else {
            print("Missing audio resource: \(sound.filename).wav")
            return
        }

        do {
            let p = try AVAudioPlayer(contentsOf: url)
            p.numberOfLoops = -1
            p.volume = volume
            p.prepareToPlay()
            p.play()
            player = p
            currentSoundID = sound.id
            isPlaying = true
            updateNowPlaying(soundName: sound.name, isPlaying: true)
        } catch {
            print("AVAudioPlayer error: \(error)")
        }
    }

    func toggle(sound: Sound) {
        if currentSoundID == sound.id {
            if isPlaying {
                pause()
            } else {
                resume(soundName: sound.name)
            }
        } else {
            play(sound: sound)
        }
    }

    func pause() {
        player?.pause()
        isPlaying = false
        updateNowPlaying(soundName: nil, isPlaying: false)
    }

    func resume(soundName: String?) {
        player?.play()
        isPlaying = true
        updateNowPlaying(soundName: soundName, isPlaying: true)
    }

    func stop(resetNowPlaying: Bool = true) {
        fadeCancellable?.cancel()
        fadeCancellable = nil
        player?.stop()
        player = nil
        isPlaying = false
        currentSoundID = nil
        if resetNowPlaying {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        }
    }

    func fadeOutAndStop(duration: TimeInterval) {
        fadeCancellable?.cancel()
        guard let p = player else { return }

        let steps = max(1, Int(duration / 0.05))
        let startVolume = p.volume
        var currentStep = 0

        fadeCancellable = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                currentStep += 1
                let t = min(1.0, Double(currentStep) / Double(steps))
                let newVol = Float((1.0 - t)) * startVolume
                p.volume = newVol
                self.volume = newVol
                if t >= 1.0 {
                    self.stop(resetNowPlaying: true)
                }
            }
    }

    func configureRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()

        center.playCommand.isEnabled = true
        center.pauseCommand.isEnabled = true
        center.togglePlayPauseCommand.isEnabled = true
        center.stopCommand.isEnabled = true

        center.playCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            self.player?.play()
            self.isPlaying = self.player?.isPlaying ?? false
            self.updateNowPlaying(soundName: nil, isPlaying: self.isPlaying)
            return .success
        }

        center.pauseCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            self.player?.pause()
            self.isPlaying = false
            self.updateNowPlaying(soundName: nil, isPlaying: false)
            return .success
        }

        center.togglePlayPauseCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            if self.player?.isPlaying == true {
                self.pause()
            } else {
                self.player?.play()
                self.isPlaying = self.player?.isPlaying ?? false
                self.updateNowPlaying(soundName: nil, isPlaying: self.isPlaying)
            }
            return .success
        }

        center.stopCommand.addTarget { [weak self] _ in
            self?.stop(resetNowPlaying: true)
            return .success
        }
    }

    private func updateNowPlaying(soundName: String?, isPlaying: Bool) {
        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        info[MPMediaItemPropertyTitle] = soundName ?? (info[MPMediaItemPropertyTitle] as? String) ?? "Pure Noise"
        info[MPMediaItemPropertyArtist] = "Pure Noise"
        info[MPNowPlayingInfoPropertyIsLiveStream] = true
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}
