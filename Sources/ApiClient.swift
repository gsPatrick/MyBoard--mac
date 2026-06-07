import Foundation

/// Cliente HTTP nativo (usado por App Intents/Siri). Autentica com o token
/// guardado no Keychain pela web ao logar no app.
enum ApiClient {
    enum ApiError: Error { case noToken, badURL, http(Int) }

    static func authedGET(_ path: String) async throws -> Data {
        guard let token = Keychain.get("myboard_auth_token") else { throw ApiError.noToken }
        guard let url = URL(string: Config.apiBase + path) else { throw ApiError.badURL }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(status) else { throw ApiError.http(status) }
        return data
    }

    private static func json(_ data: Data) -> [String: Any]? {
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }

    /// Total de projetos ativos (em andamento).
    static func activeProjectsCount() async throws -> Int {
        let data = try await authedGET("/v1/projects?status=in_progress&limit=1")
        let body = json(data)
        if let meta = body?["meta"] as? [String: Any], let total = meta["total"] as? Int {
            return total
        }
        if let arr = body?["data"] as? [Any] { return arr.count }
        return 0
    }

    /// Quantidade de eventos da agenda hoje.
    static func todayEventsCount() async throws -> Int {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let today = fmt.string(from: Date())
        let data = try await authedGET("/v1/agenda?from=\(today)T00:00&to=\(today)T23:59")
        let body = json(data)
        if let arr = body?["data"] as? [Any] { return arr.count }
        return 0
    }
}
