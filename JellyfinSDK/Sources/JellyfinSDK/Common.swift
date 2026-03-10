import Foundation

public enum APIError: Error, LocalizedError {
    case invalidURL
    case httpError(statusCode: Int, data: Data)
    case decodingError(Error)
    
    public var errorDescription: String? {
        switch self {
            case .invalidURL: return "Invalid URL"
            case .httpError(let code, _): return "HTTP error: \(code)"
            case .decodingError(let e): return "Decoding failed: \(e.localizedDescription)"
        }
    }
}
