import SwiftUI

struct SoundsView: View {
    @EnvironmentObject private var audio: AudioManager
    @EnvironmentObject private var purchases: PurchasesManager

    @State private var showingPaywall = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    if !purchases.isUnlocked {
                        UnlockBanner(price: purchases.displayPrice) {
                            showingPaywall = true
                        }
                    }

                    LazyVStack(spacing: 10) {
                        ForEach(SoundCatalog.sounds) { sound in
                            SoundRow(sound: sound)
                                .opacity(sound.isFree || purchases.isUnlocked ? 1.0 : 0.55)
                                .onTapGesture {
                                    if sound.isFree || purchases.isUnlocked {
                                        audio.toggle(sound: sound)
                                    } else {
                                        showingPaywall = true
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .navigationTitle("Sounds")
            .toolbarTitleDisplayMode(.large)
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}

private struct SoundRow: View {
    @EnvironmentObject private var audio: AudioManager
    @EnvironmentObject private var purchases: PurchasesManager

    let sound: Sound

    private var isLocked: Bool {
        !(sound.isFree || purchases.isUnlocked)
    }

    private var isThisSound: Bool {
        audio.currentSoundID == sound.id
    }

    var body: some View {
        GlassCard {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.10))
                        .frame(width: 44, height: 44)
                    Image(systemName: sound.systemImage)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(sound.name)
                            .font(.headline)
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        if isLocked {
                            Image(systemName: "lock.fill")
                                .font(.footnote)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    Text(sound.isFree ? "Free" : "Premium")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.65))
                }

                Spacer()

                Button {
                    if isLocked {
                        // handled by tap gesture
                        return
                    }
                    audio.toggle(sound: sound)
                } label: {
                    Image(systemName: isThisSound && audio.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(width: 40, height: 40)
                        .background(.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
                }
                .buttonStyle(.plain)
                .disabled(isLocked)
            }
        }
    }
}

private struct UnlockBanner: View {
    let price: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            GlassCard {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.white)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Unlock all sounds")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("One-time purchase \(price)")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.white.opacity(0.75))
                }
            }
        }
        .buttonStyle(.plain)
    }
}
