import Foundation

/// A super-simple place to keep the user's login token.
///
/// For a starter project we just use `UserDefaults`. In a real app
/// you'd store this in the Keychain so it's encrypted, but the idea
/// is exactly the same: save the token, read it back, clear it on logout.
final class TokenStore {

    static let shared = TokenStore()
    private init() {}

    private let key = "auth.accessToken"

    /// The current token, or `nil` if the user is not logged in.
    var token: String? {
        get { UserDefaults.standard.string(forKey: key) }
        set { UserDefaults.standard.setValue(newValue, forKey: key) }
    }

    var isLoggedIn: Bool {
        return token != nil
    }

    func clear() {
        token = nil
    }
}
