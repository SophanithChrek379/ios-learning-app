import Foundation

/// All the auth-related network calls live here, the same way
/// `TaskService` holds all the todo-related calls.
final class AuthService {

    static let shared = AuthService()

    private init() {}

    /// Create a new account.
    /// The server signs us in straight away and returns a session,
    /// so we save the token here too.
    func register(email: String, password: String) async throws -> User {
        let body = RegisterRequest(email: email, password: password)
        let response: AuthResponse = try await APIClient.shared.request(
            .register,
            method: .post,
            body: body
        )
        TokenStore.shared.token = response.session.accessToken
        return response.user
    }

    /// Log in. On success we save the token so every later request is signed.
    func login(email: String, password: String) async throws -> User {
        let body = LoginRequest(email: email, password: password)
        let response: AuthResponse = try await APIClient.shared.request(
            .login,
            method: .post,
            body: body
        )
        TokenStore.shared.token = response.session.accessToken
        return response.user
    }

    /// Ask the server "who am I?" using the saved token.
    /// Useful for showing the user's email or checking if the token is still valid.
    func me() async throws -> User {
        return try await APIClient.shared.request(.me)
    }

    /// Forget the token. Next time the app opens, the user will see Login again.
    func logout() {
        TokenStore.shared.clear()
    }
}
