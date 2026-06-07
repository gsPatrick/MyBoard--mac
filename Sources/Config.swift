import Foundation

enum Config {
    /// URL do front. Em DEBUG usa o Next local; em release, a URL hospedada.
    // Abre direto no app (não na landing de marketing): /dashboard redireciona
    // para /login quando não há sessão — comportamento de app nativo.
    #if DEBUG
    static let appURL = "http://localhost:3000/dashboard"
    #else
    static let appURL = "https://myboard.codebypatrick.dev/dashboard"
    #endif
}
