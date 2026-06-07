import AppIntents

/// "Quantos projetos ativos eu tenho?" — Siri / Atalhos / Spotlight.
struct ActiveProjectsIntent: AppIntent {
    static var title: LocalizedStringResource = "Projetos ativos"
    static var description = IntentDescription("Mostra quantos projetos ativos você tem no MyBoard.")
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        do {
            let count = try await ApiClient.activeProjectsCount()
            return .result(dialog: "Você tem \(count) projeto(s) ativo(s) no MyBoard.")
        } catch {
            return .result(dialog: "Entre no MyBoard pelo app primeiro para eu poder consultar.")
        }
    }
}

/// "O que tenho na agenda hoje?"
struct TodayAgendaIntent: AppIntent {
    static var title: LocalizedStringResource = "Agenda de hoje"
    static var description = IntentDescription("Mostra quantos compromissos você tem hoje.")
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        do {
            let count = try await ApiClient.todayEventsCount()
            if count == 0 {
                return .result(dialog: "Você não tem compromissos hoje.")
            }
            return .result(dialog: "Você tem \(count) compromisso(s) hoje na agenda.")
        } catch {
            return .result(dialog: "Entre no MyBoard pelo app primeiro para eu poder consultar.")
        }
    }
}

/// Abre o app no MyBoard.
struct OpenMyBoardIntent: AppIntent {
    static var title: LocalizedStringResource = "Abrir MyBoard"
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        return .result()
    }
}

struct MyBoardShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ActiveProjectsIntent(),
            phrases: ["Projetos ativos no \(.applicationName)", "Quantos projetos ativos no \(.applicationName)"],
            shortTitle: "Projetos ativos",
            systemImageName: "folder"
        )
        AppShortcut(
            intent: TodayAgendaIntent(),
            phrases: ["Agenda de hoje no \(.applicationName)", "Meus compromissos no \(.applicationName)"],
            shortTitle: "Agenda de hoje",
            systemImageName: "calendar"
        )
        AppShortcut(
            intent: OpenMyBoardIntent(),
            phrases: ["Abrir \(.applicationName)"],
            shortTitle: "Abrir",
            systemImageName: "square.grid.2x2"
        )
    }
}
