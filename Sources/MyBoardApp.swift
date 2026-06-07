import SwiftUI

@main
struct MyBoardApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1024, minHeight: 700)
                .ignoresSafeArea()
        }
        // Sem barra de título "de browser" — a UI web ocupa a janela toda.
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
    }
}

struct ContentView: View {
    var body: some View {
        WebView()
            .ignoresSafeArea()
    }
}
