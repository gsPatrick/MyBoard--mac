import WebKit
import Foundation

/// Ponte JS <-> Swift. O front chama `window.MyBoardNative.*` e cai aqui.
final class Bridge: NSObject, WKScriptMessageHandler {
    weak var webView: WKWebView?

    /// Injetado no front. Expõe window.MyBoardNative (promessas) e a flag de detecção.
    static let injectedJS = """
    window.__MYBOARD_NATIVE__ = true;
    (function () {
      const pending = {};
      let seq = 0;
      function call(action, payload) {
        return new Promise((resolve, reject) => {
          const id = String(++seq);
          pending[id] = { resolve, reject };
          window.webkit.messageHandlers.native.postMessage({ id: id, action: action, payload: payload || {} });
        });
      }
      window.MyBoardNative = {
        platform: "macos",
        // Touch ID — resolve true se autenticar
        biometricUnlock: (reason) => call("biometricUnlock", { reason: reason }),
        // Keychain (Secure Enclave)
        keychainSet: (key, value) => call("keychainSet", { key: key, value: value }),
        keychainGet: (key) => call("keychainGet", { key: key }),
        keychainDelete: (key) => call("keychainDelete", { key: key }),
        // Notificações nativas + badge no Dock
        notify: (title, body) => call("notify", { title: title, body: body }),
        setBadge: (count) => call("setBadge", { count: count }),
        requestNotificationPermission: () => call("requestNotificationPermission", {}),
        _resolve: (id, value) => { const p = pending[id]; if (p) { p.resolve(value); delete pending[id]; } },
        _reject: (id, err) => { const p = pending[id]; if (p) { p.reject(new Error(err)); delete pending[id]; } }
      };
    })();
    """

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard
            let body = message.body as? [String: Any],
            let id = body["id"] as? String,
            let action = body["action"] as? String
        else { return }
        let payload = body["payload"] as? [String: Any] ?? [:]

        switch action {
        case "biometricUnlock":
            let reason = payload["reason"] as? String ?? "Confirme sua identidade"
            Biometrics.authenticate(reason: reason) { [weak self] ok, err in
                if ok {
                    self?.resolve(id, jsValue: "true")
                } else {
                    self?.reject(id, error: err ?? "Falha na autenticação")
                }
            }

        case "keychainSet":
            if let key = payload["key"] as? String, let value = payload["value"] as? String {
                Keychain.set(value, for: key)
                resolve(id, jsValue: "true")
            } else {
                reject(id, error: "Parâmetros inválidos")
            }

        case "keychainGet":
            let key = payload["key"] as? String ?? ""
            resolve(id, jsValue: jsString(Keychain.get(key)))

        case "keychainDelete":
            let key = payload["key"] as? String ?? ""
            Keychain.delete(key)
            resolve(id, jsValue: "true")

        case "notify":
            NativeNotifications.show(
                title: payload["title"] as? String ?? "MyBoard",
                body: payload["body"] as? String ?? ""
            )
            resolve(id, jsValue: "true")

        case "setBadge":
            let count = (payload["count"] as? NSNumber)?.intValue ?? 0
            NativeNotifications.setBadge(count)
            resolve(id, jsValue: "true")

        case "requestNotificationPermission":
            NativeNotifications.requestPermission { [weak self] granted in
                self?.resolve(id, jsValue: granted ? "true" : "false")
            }

        default:
            reject(id, error: "Ação desconhecida: \(action)")
        }
    }

    /// `jsValue` é um literal JS (ex.: "true", "null", "\"texto\"").
    private func resolve(_ id: String, jsValue: String) {
        webView?.evaluateJavaScript("window.MyBoardNative._resolve(\"\(id)\", \(jsValue));")
    }

    private func reject(_ id: String, error: String) {
        let safe = error.replacingOccurrences(of: "\"", with: "'")
        webView?.evaluateJavaScript("window.MyBoardNative._reject(\"\(id)\", \"\(safe)\");")
    }

    private func jsString(_ s: String?) -> String {
        guard let s = s else { return "null" }
        let escaped = s
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        return "\"\(escaped)\""
    }
}
