import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

/// LLM on-device do Apple Intelligence (Foundation Models, macOS 26+).
/// Retorna nil quando indisponível (versão antiga ou recurso desligado).
enum OnDeviceAI {
    static func run(_ prompt: String) async -> String? {
        #if canImport(FoundationModels)
        if #available(macOS 26.0, *) {
            do {
                let session = LanguageModelSession()
                let response = try await session.respond(to: prompt)
                return response.content
            } catch {
                return nil
            }
        }
        #endif
        return nil
    }

    static func summarize(_ text: String) async -> String? {
        await run("Resuma o texto a seguir em português do Brasil, de forma curta e clara:\n\n\(text)")
    }
}
