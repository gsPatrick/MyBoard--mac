import Foundation

enum Config {
    /// URL do front. Em DEBUG usa o Next local; em release, a URL hospedada.
    // Abre direto no app (não na landing de marketing): /dashboard redireciona
    // para /login quando não há sessão — comportamento de app nativo.
    // Abre na tela de pré-login do app (/welcome). Se já houver sessão, /welcome
    // redireciona para /dashboard.
    #if DEBUG
    static let appURL = "http://localhost:3000/welcome"
    #else
    static let appURL = "https://myboard.codebypatrick.dev/welcome"
    #endif

    // Base da API (usada por App Intents/Siri nativos).
    static let apiBase = "https://geral-myboard--api.r954jc.easypanel.host/api"
}
