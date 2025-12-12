import SwiftUI

struct TimerView: View {
    @State private var timeRemaining = 60 * 15 // 15 min default
    @State private var isActive = false
    @State private var showingCustom = false

    let timerOptions = [15, 30, 60]

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.black, .gray]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack {
                Text(timeString)
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                Button("Start Timer") {
                    isActive.toggle()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                if isActive {
                    Text("Fading out in \(timeRemaining / 60) min")
                        .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $showingCustom) {
                CustomTimerView(timeRemaining: $timeRemaining)
            }
        }
        .navigationTitle("Sleep Timer")
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if isActive && timeRemaining > 0 {
                timeRemaining -= 1
                if timeRemaining == 0 {
                    // Fade out audio
                    AudioManager.shared.stop()
                    isActive = false
                }
            }
        }
    }

    private var timeString: String {
        let min = timeRemaining / 60
        let sec = timeRemaining % 60
        return String(format: "%d:%02d", min, sec)
    }
}

struct CustomTimerView: View {
    @Binding var timeRemaining: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Text("Custom Minutes")
            TextField("Minutes", value: $timeRemaining, format: .number)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Set") { dismiss() }
        }
        .padding()
    }
}
