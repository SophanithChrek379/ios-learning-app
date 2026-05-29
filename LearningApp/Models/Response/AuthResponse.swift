import Foundation

/// The user object the API sends back inside auth responses.
struct User: Decodable {
    let id: String
    let email: String
}

/// The session info that comes back after login or register.
/// This is where the token we need lives.
struct Session: Decodable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case accessToken  = "access_token"
        case refreshToken = "refresh_token"
        case tokenType    = "token_type"
        case expiresIn    = "expires_in"
    }
}

/// The full shape returned by `/auth/login` and `/auth/register`:
/// `{ "user": { ... }, "session": { ... } }`
struct AuthResponse: Decodable {
    let user: User
    let session: Session
}
