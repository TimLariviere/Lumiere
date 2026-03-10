import Foundation

extension JSONDecoder {
    static func pascalCaseDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        
        decoder.keyDecodingStrategy = .custom { keys in
            let key = keys.last!.stringValue
            let camelCaseKey = key.first!.lowercased() + key.dropFirst()
            return AnyCodingKey(stringValue: camelCaseKey)
        }
        
        return decoder
    }
}

struct AnyCodingKey: CodingKey {
    let stringValue: String
    let intValue: Int?
    
    init(stringValue: String) {
        self.intValue = nil
        self.stringValue = stringValue
    }
    
    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = "\(intValue)"
    }
}
