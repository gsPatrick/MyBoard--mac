import SwiftUI
import WebKit

/// WKWebView "100% app": sem menu de contexto de browser.
final class AppWebView: WKWebView {
    override func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
        // Remove o menu nativo do WebKit (Recarregar, Voltar, Inspecionar…).
        // Menus próprios da web app (ex.: Excalidraw, que são DOM) continuam funcionando.
        menu.removeAllItems()
    }
}

/// Hospeda o front (mesma web app, pixel-perfect) sem cara de browser.
struct WebView: NSViewRepresentable {
    func makeCoordinator() -> Bridge { Bridge() }

    func makeNSView(context: Context) -> WKWebView {
        let ucc = WKUserContentController()
        ucc.add(context.coordinator, name: "native")
        ucc.addUserScript(
            WKUserScript(
                source: Bridge.injectedJS,
                injectionTime: .atDocumentStart,
                forMainFrameOnly: false
            )
        )

        let config = WKWebViewConfiguration()
        config.userContentController = ucc

        let webView = AppWebView(frame: .zero, configuration: config)
        context.coordinator.webView = webView

        // Tira "vícios de browser"
        webView.allowsBackForwardNavigationGestures = false // sem swipe pra voltar
        webView.allowsMagnification = false                 // sem pinça/zoom

        // Ajustes nativos da janela (roda quando a view já está na janela)
        DispatchQueue.main.async {
            guard let window = webView.window else { return }
            window.isMovableByWindowBackground = true        // arrasta pela área vazia
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.title = "MyBoard"
        }

        if let url = URL(string: Config.appURL) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}
}
