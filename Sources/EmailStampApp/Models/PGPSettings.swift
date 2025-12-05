import Foundation
import SwiftUI
import Combine

class PGPSettings: ObservableObject, Codable {
    @Published var enabled: Bool = true
    @Published var keyFilePath: String = ""
    @Published var keyID: String = ""
    @Published var autoSign: Bool = false
    @Published var signatureStyle: PGPSignatureStyle = .inline
    
    // Password is NOT stored - use SecureStorage instead
    var keyPassword: String = "" {
        didSet {
            // Password is never persisted
        }
    }
    
    enum PGPSignatureStyle: String, Codable, CaseIterable {
        case inline = "Inline"
        case detached = "Detached"
        case clear = "Clear Text"
    }
    
    enum CodingKeys: String, CodingKey {
        case enabled, keyFilePath, keyID, autoSign, signatureStyle
    }
    
    init() {
        loadSettings()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(enabled, forKey: .enabled)
        try container.encode(keyFilePath, forKey: .keyFilePath)
        try container.encode(keyID, forKey: .keyID)
        try container.encode(autoSign, forKey: .autoSign)
        try container.encode(signatureStyle, forKey: .signatureStyle)
        // Note: keyPassword is NEVER saved for security
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        enabled = try container.decode(Bool.self, forKey: .enabled)
        keyFilePath = try container.decode(String.self, forKey: .keyFilePath)
        keyID = try container.decode(String.self, forKey: .keyID)
        autoSign = try container.decode(Bool.self, forKey: .autoSign)
        signatureStyle = try container.decode(PGPSignatureStyle.self, forKey: .signatureStyle)
        // Password is never loaded from storage
    }
    
    func saveSettings() {
        if let encoded = try? JSONEncoder().encode(self),
           let data = String(data: encoded, encoding: .utf8) {
            UserDefaults.standard.set(data, forKey: "PGPSettings")
        }
        
        // Securely store password if provided
        if !keyPassword.isEmpty {
            let _ = SecureStorage.storePassword(keyPassword, forKey: "pgp_key_password")
            // Clear password from memory after storing
            SecureStorage.secureWipe(&keyPassword)
        }
    }
    
    func loadSettings() {
        if let data = UserDefaults.standard.string(forKey: "PGPSettings"),
           let decoded = try? JSONDecoder().decode(PGPSettings.self, from: Data(data.utf8)) {
            self.enabled = decoded.enabled
            self.keyFilePath = decoded.keyFilePath
            self.keyID = decoded.keyID
            self.autoSign = decoded.autoSign
            self.signatureStyle = decoded.signatureStyle
        }
        
        // Load password from secure storage if available
        if let password = SecureStorage.retrievePassword(forKey: "pgp_key_password") {
            self.keyPassword = password
        }
    }
    
    var isConfigured: Bool {
        !keyFilePath.isEmpty || !keyID.isEmpty
    }
    
    // Securely clear password from memory
    func clearPassword() {
        SecureStorage.secureWipe(&keyPassword)
    }
}

