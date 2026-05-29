import Foundation

enum APIError: Error, LocalizedError {
    
    case invalidURL
    case invalidResponse
    case decodingFailed
    case encodingFailed
    case networkFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is not valid. Please check the address."
        case .invalidResponse:
            return "sop"
        case .decodingFailed:
            return "We couldn't read the data from the server."
        case .encodingFailed:
            return "Failed to process your request."
        case .networkFailed(let error):
            return "Network problem: \(error.localizedDescription)"
        }
    }
    
}
