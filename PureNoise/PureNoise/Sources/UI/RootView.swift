import SwiftUI

struct RootView: View {
    var body: some View {
        ZStack {
            GradientBackground()
                .ignoresSafeArea()

            TabView {
                SoundsView()
                    .tabItem {
                        Label("Sounds", systemImage: "music.note.list")
                    }

                TimerView()
                    .tabItem {
                        Label("Timer", systemImage: "timer")
                    }
            }
        }
        .tint(.white)
    }
}
