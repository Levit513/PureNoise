import SwiftUI

struct TimerView: View {
    @EnvironmentObject private var sleepTimer: SleepTimerManager

    @State private var customMinutes: Int = 45

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Sleep Timer")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.white)

                            if sleepTimer.isActive {
                                Text("Ends in \(format(seconds: sleepTimer.remainingSeconds))")
                                    .font(.headline)
                                    .foregroundStyle(.white.opacity(0.9))
                            } else {
                                Text("Fade out and stop audio at the end.")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.7))
                            }

                            HStack(spacing: 10) {
                                TimerPresetButton(title: "15 min") { sleepTimer.start(minutes: 15) }
                                TimerPresetButton(title: "30 min") { sleepTimer.start(minutes: 30) }
                                TimerPresetButton(title: "60 min") { sleepTimer.start(minutes: 60) }
                            }

                            Divider().overlay(Color.white.opacity(0.15))

                            HStack {
                                Text("Custom")
                                    .foregroundStyle(.white)
                                Spacer()
                                Stepper("\(customMinutes) min", value: $customMinutes, in: 1...240)
                                    .labelsHidden()
                                    .tint(.white)
                            }
                            Button {
                                sleepTimer.start(minutes: customMinutes)
                            } label: {
                                Text("Start \(customMinutes) min")
                                    .font(.headline)
                                    .foregroundStyle(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            .buttonStyle(.plain)

                            if sleepTimer.isActive {
                                Button(role: .destructive) {
                                    sleepTimer.cancel()
                                } label: {
                                    Text("Cancel Timer")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .tint(.red)
                            }
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tip")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text("You can control playback from the Lock Screen and Apple Watch Now Playing.")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .navigationTitle("Timer")
            .toolbarTitleDisplayMode(.large)
        }
    }

    private func format(seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

private struct TimerPresetButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
