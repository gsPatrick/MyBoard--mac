import LocalAuthentication

/// Touch ID (com fallback pra senha do Mac).
enum Biometrics {
    static func authenticate(reason: String, completion: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            completion(false, error?.localizedDescription ?? "Biometria indisponível")
            return
        }

        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, evalError in
            DispatchQueue.main.async {
                completion(success, evalError?.localizedDescription)
            }
        }
    }
}
