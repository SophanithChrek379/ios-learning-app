import Foundation

/// The body we send to `/auth/register`
struct RegisterRequest: Encodable {
    let email: String
    let password: String
}

/// The body we send to `/auth/login`
struct LoginRequest: Encodable {
    let email: String
    let password: String
}
