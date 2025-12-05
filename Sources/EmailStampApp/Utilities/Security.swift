import Foundation
import CryptoKit
import Security

// MARK: - Secure Storage
class SecureStorage {
    private static let service = "com.emailstamp.app"
    
    // Securely store password (Keychain)
    static func storePassword(_ password: String, forKey key: String) -> Bool {
        // Validate input
        guard !key.isEmpty else { return false }
        guard let data = password.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete existing item first (ignore errors)
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            // Log error for debugging (in production, use proper logging)
            #if DEBUG
            print("Keychain error: \(status) - \(SecCopyErrorMessageString(status, nil) ?? "Unknown error" as CFString)")
            #endif
            return false
        }
        
        return true
    }
    
    // Retrieve password from Keychain
    static func retrievePassword(forKey key: String) -> String? {
        // Validate input
        guard !key.isEmpty else { return nil }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            // Item not found is not an error - just return nil
            if status != errSecItemNotFound {
                #if DEBUG
                print("Keychain retrieve error: \(status)")
                #endif
            }
            return nil
        }
        
        guard let data = result as? Data,
              let password = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return password
    }
    
    // Delete password from Keychain
    static func deletePassword(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    // Check if password exists in Keychain (without retrieving it)
    static func hasPassword(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    // Securely wipe data from memory
    static func secureWipe(_ data: inout Data) {
        data.withUnsafeMutableBytes { bytes in
            guard let base = bytes.baseAddress, bytes.count > 0 else { return }
            memset_s(base, bytes.count, 0, bytes.count)
        }
        data.removeAll(keepingCapacity: false)
    }
    
    // Securely wipe string from memory
    static func secureWipe(_ string: inout String) {
        var data = string.data(using: .utf8) ?? Data()
        secureWipe(&data)
        string.removeAll()
    }
}

// MARK: - Input Validation
struct InputValidator {
    // Validate email address
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // Sanitize HTML input
    static func sanitizeHTML(_ html: String) -> String {
        // Remove potentially dangerous tags and attributes
        var sanitized = html
        let dangerousTags = ["script", "iframe", "object", "embed", "link"]
        let dangerousAttributes = ["onerror", "onload", "onclick", "onmouseover"]
        
        for tag in dangerousTags {
            sanitized = sanitized.replacingOccurrences(
                of: "<\(tag)[^>]*>.*?</\(tag)>",
                with: "",
                options: [.regularExpression, .caseInsensitive]
            )
        }
        
        for attr in dangerousAttributes {
            sanitized = sanitized.replacingOccurrences(
                of: "\(attr)=\"[^\"]*\"",
                with: "",
                options: [.regularExpression, .caseInsensitive]
            )
        }
        
        return sanitized
    }
    
    // Validate file path
    static func isValidFilePath(_ path: String) -> Bool {
        // Check for path traversal attempts
        guard !path.contains("..") else { return false }
        guard !path.contains("~") else { return false }
        
        // Check if file exists and is readable
        return FileManager.default.fileExists(atPath: path) &&
               FileManager.default.isReadableFile(atPath: path)
    }
}

// MARK: - Secure Hash Generation
struct SecureHasher {
    // Generate SHA256 hash with salt
    static func hash(_ data: Data, salt: Data? = nil) -> String {
        var hasher = SHA256()
        
        if let salt = salt {
            hasher.update(data: salt)
        }
        
        hasher.update(data: data)
        let hash = hasher.finalize()
        
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    // Generate random salt
    static func generateSalt(length: Int = 32) -> Data {
        var bytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
        
        guard status == errSecSuccess else {
            // Fallback to arc4random if SecRandom fails
            for i in 0..<length {
                bytes[i] = UInt8(arc4random() % 256)
            }
            return Data(bytes)
        }
        
        return Data(bytes)
    }
}

// MARK: - Secure Key Management
class SecureKeyManager {
    private static let keychainService = "com.emailstamp.app.keys"
    
    // Store PGP key securely
    static func storePGPKey(_ keyData: Data, forKeyID keyID: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keyID,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    // Retrieve PGP key
    static func retrievePGPKey(forKeyID keyID: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keyID,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data else {
            return nil
        }
        
        return data
    }
    
    // Delete PGP key
    static func deletePGPKey(forKeyID keyID: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keyID
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}

