import SwiftUI
import WebKit

/// Hospeda o front (mesma web app, pixel-perfect) num WKWebView sem cara de browser.
struct WebView: NSViewRepresentable {
    func makeCoordinator() -> Bridge { Bridge() }

    func makeNSView(context: Context) -> WKWebView {
        let ucc = WKUserContentController()
        // Ponte JS -> Swift
        ucc.add(context.coordinator, name: "native")
        // Injeta a API window.MyBoardNative antes do conteúdo carregar
        ucc.addUserScript(
            WKUserScript(
                source: Bridge.injectedJS,
                injectionTime: .atDocumentStart,
                forMainFrameOnly: false
            )
        )

        let config = WKWebViewConfiguration()
        config.userContentController = ucc

        let webView = WKWebView(frame: .zero, configuration: config)
        context.coordinator.webView = webView

        // Tira "vícios de browser"
        webView.allowsBackForwardNavigationGestures = false // sem swipe pra voltar
        webView.allowsMagnification = false                 // sem pinça/zoom

        if let url = URL(string: Config.appURL) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}
}
