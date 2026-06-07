import Foundation

enum Config {
    /// URL do front. Em DEBUG usa o Next local; em release, a URL hospedada.
    #if DEBUG
    static let appURL = "http://localhost:3000"
    #else
    static let appURL = "https://myboard.codebypatrick.dev/"
    #endif
}
