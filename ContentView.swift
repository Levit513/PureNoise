import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SoundsListView()
                .tabItem { Label("Sounds", systemImage: "music.note") }
            TimerView()
                .tabItem { Label("Timer", systemImage: "clock") }
        }
        .accentColor(.blue)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
