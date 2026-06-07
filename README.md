# MyBoard — App Mac (Swift + WKWebView)

Casca nativa macOS que hospeda o **mesmo front** do MyBoard num `WKWebView`
(layout pixel-perfect, zero reescrita) e adiciona recursos nativos da Apple via
uma ponte JS↔Swift.

## Por que assim
- A UI é a sua web app → **idêntica**, um código só.
- A casca Swift dá acesso a Touch ID, Keychain, Siri/App Intents, Widgets e ao
  LLM on-device (Apple Intelligence) sem trocar o frontend.

## Rodar (dev)
1. `brew install xcodegen` (uma vez)
2. `xcodegen generate` (gera o `MyBoard.xcodeproj`)
3. Suba o front local: no `frontend/`, `npm run dev` (fica em `http://localhost:3000`)
4. `open MyBoard.xcodeproj` e dê Run (⌘R) — ou:
   `xcodebuild -scheme MyBoard -configuration Debug build`

> Em **release**, ajuste `Config.appURL` para a URL hospedada do front (EasyPanel).

## Ponte nativa (já pronta no esqueleto)
No front, quando rodando dentro do app, existe `window.__MYBOARD_NATIVE__ === true`
e a API:

```js
if (window.__MYBOARD_NATIVE__) {
  const ok = await window.MyBoardNative.biometricUnlock("Revelar credenciais");
  await window.MyBoardNative.keychainSet("token", "abc");
  const t = await window.MyBoardNative.keychainGet("token");
}
```

- `biometricUnlock(reason)` → Touch ID (true/false)
- `keychainSet/get/delete` → Keychain (Secure Enclave)

O front continua funcionando **igual no navegador** (as chamadas nativas ficam
atrás do `if (window.__MYBOARD_NATIVE__)`), então nada quebra na versão web.

## Estrutura
```
MyBoard-Mac/
  project.yml        # spec do XcodeGen (fonte da verdade do projeto)
  Info.plist
  Sources/
    MyBoardApp.swift # @main + janela sem cara de browser
    WebView.swift    # WKWebView (sem swipe/zoom/abas)
    Bridge.swift     # ponte JS<->Swift + JS injetado
    Biometrics.swift # Touch ID (LocalAuthentication)
    Keychain.swift   # armazenamento seguro
    Config.swift     # URL do front (dev/prod)
```

## Distribuição (sem App Store)
1. Conta Apple Developer ($99/ano) → assinar + **notarizar**.
2. `xcodebuild -scheme MyBoard -configuration Release archive` → exportar `.app`.
3. Empacotar num `.dmg`, notarizar (`notarytool`), grampear (`stapler`).
4. Hospedar o `.dmg` (GitHub Releases ou seu servidor) e linkar na landing.

> Sem notarizar funciona pra você (botão direito → Abrir). Pra distribuir limpo,
> notarize.

## Roadmap
- [x] Fase 1: casca + WebView + Touch ID + Keychain + ponte
- [ ] Fase 2: App Intents/Siri + Widget (reaproveitando as tools do Bordie)
- [ ] Fase 3: Foundation Models (LLM on-device) + Live Text (OCR de PDF/imagem)
