import SwiftUI

struct SoundsListView: View {
    @StateObject private var audioManager = AudioManager.shared
    let sounds = [
        "rain", "brown_noise", "pink_noise", "white_noise", "ocean", "fan", "fireplace", "forest", "thunderstorm", "waves",
        "coffee_shop", "train", "airplane", "wind", "birds", "crickets", "waterfall", "campfire", "city", "river",
        "meditation", "delta_waves", "alpha_waves", "beta_waves", "gamma_waves", "lullaby", "jazz", "classical", "ambient", "lofi"
    ].prefix(8) // First 8 free, rest unlocked via purchase

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.black, .gray]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(sounds, id: \.self) { sound in
                            SoundRow(sound: sound, audioManager: audioManager)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Sounds")
            .overlay(alignment: .bottom) {
                if sounds.count < 30 {
                    Text("Unlock all 30 sounds for $6.99")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(10)
                        .padding(.bottom, 20)
                }
            }
        }
    }
}

struct SoundRow: View {
    let sound: String
    @ObservedObject var audioManager: AudioManager

    var body: some View {
        HStack {
            Image(systemName: getIcon(for: sound))
                .font(.title2)
                .foregroundColor(.white)
            Text(sound.capitalized)
                .foregroundColor(.white)
                .font(.headline)
            Spacer()
            Button(action: toggleSound) {
                Image(systemName: audioManager.currentSound == sound && audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.3))
        .cornerRadius(10)
    }

    private func toggleSound() {
        if audioManager.currentSound == sound && audioManager.isPlaying {
            audioManager.pause()
        } else {
            audioManager.playSound(named: sound)
        }
    }

    private func getIcon(for sound: String) -> String {
        switch sound {
        case "rain": return "cloud.rain"
        case "ocean", "waves", "river": return "water"
        case "fan", "airplane": return "wind"
        case "fireplace", "campfire": return "flame"
        default: return "music.note"
        }
    }
}
