import SwiftUI
import WebKit

/// WKWebView "100% app": sem menu de contexto de browser.
final class AppWebView: WKWebView {
    override func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
        // Remove o menu nativo do WebKit (Recarregar, Voltar, Inspecionar…).
        // Menus próprios da web app (ex.: Excalidraw, DOM) continuam funcionando.
        menu.removeAllItems()
    }
}

/// Hospeda o front (mesma web app, pixel-perfect) com janela nativa do macOS.
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

        // Tira "vícios de browser" mantendo a janela nativa.
        webView.allowsBackForwardNavigationGestures = false
        webView.allowsMagnification = false

        // Título na barra nativa do macOS.
        DispatchQueue.main.async {
            webView.window?.title = "MyBoard"
        }

        // Recarregar via ⌘R (comando nativo do app).
        NotificationCenter.default.addObserver(
            forName: .myboardReload,
            object: nil,
            queue: .main
        ) { [weak webView] _ in
            webView?.reload()
        }

        if let url = URL(string: Config.appURL) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}
}
