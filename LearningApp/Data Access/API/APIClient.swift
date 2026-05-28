import Foundation

final class APIClient {

    static let shared = APIClient()
    private let session: URLSession

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        return e
    }()

    private init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetch<T: Codable>(from endpoint: APIEndPoint) async throws -> T {
           
       guard let url = URL(string: endpoint.url) else {
           throw APIError.invalidURL
       }
       
       let (data, response): (Data, URLResponse)
       do {
           (data, response) = try await session.data(from: url)
       } catch {
           throw APIError.networkFailed(error)
       }
       
       guard let httpResponse = response as? HTTPURLResponse,
             (200...299).contains(httpResponse.statusCode) else {
           throw APIError.invalidResponse
       }
       
       do {
           let decodedData = try JSONDecoder().decode(T.self, from: data)
           return decodedData
       } catch {
           throw APIError.decodingFailed
       }
    }
    
    func post<T: Decodable>(to endpoint: APIEndPoint, body: some Encodable ) async throws -> T {
        guard let url = URL(string: endpoint.url) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try encoder.encode(body)
        } catch {
            throw APIError.encodingFailed
        }
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.networkFailed(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch {
            throw APIError.encodingFailed
        }
    }
    
    func put<T: Decodable>(to endpoint: APIEndPoint, body: some Encodable) async throws -> T {
        guard let url = URL(string: endpoint.url) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try encoder.encode(body)
        } catch {
            throw APIError.encodingFailed
        }
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.networkFailed(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.encodingFailed
        }
    }
}
