import Foundation

@MainActor
final class AuthViewModel {

    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    private(set) var didSucceed: Bool = false

    /// The view controller hooks into this to refresh the UI.
    var onUpdate: (() -> Void)?

    private let service: AuthService

    init(service: AuthService = .shared) {
        self.service = service
    }

    /// Try to log the user in with the given email and password.
    func login(email: String, password: String) async {
        isLoading = true
        didSucceed = false
        errorMessage = nil
        onUpdate?()

        defer {
            isLoading = false
            onUpdate?()
        }

        do {
            _ = try await service.login(email: email, password: password)
            didSucceed = true
        } catch {
            errorMessage = "Login failed. Please check your email and password."
        }
    }

    /// Create a new account. The server signs the user in for us,
    /// so there's no extra login step here.
    func register(email: String, password: String) async {
        isLoading = true
        didSucceed = false
        errorMessage = nil
        onUpdate?()

        defer {
            isLoading = false
            onUpdate?()
        }

        do {
            _ = try await service.register(email: email, password: password)
            didSucceed = true
        } catch {
            errorMessage = "Sign up failed. Please try a different email."
        }
    }
}
