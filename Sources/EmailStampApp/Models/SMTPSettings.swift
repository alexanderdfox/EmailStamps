import Foundation
import SwiftUI
import Combine

class SMTPSettings: ObservableObject, Codable {
    @Published var enabled: Bool = false
    @Published var server: String = ""
    @Published var port: Int = 587
    @Published var username: String = ""
    @Published var useTLS: Bool = true
    @Published var useSSL: Bool = false
    @Published var authenticationMethod: AuthenticationMethod = .password
    
    // Password is NOT stored in memory - use SecureStorage instead
    // Password is only loaded when explicitly requested
    private var _password: String = ""
    private var _passwordLoaded: Bool = false
    
    // Password property with lazy loading from Keychain
    var password: String {
        get {
            // Lazy load password from Keychain only when accessed
            if !_passwordLoaded {
                if let storedPassword = SecureStorage.retrievePassword(forKey: "smtp_password") {
                    _password = storedPassword
                }
                _passwordLoaded = true
            }
            return _password
        }
        set {
            _password = newValue
            _passwordLoaded = true
        }
    }
    
    // Binding for SwiftUI - allows two-way binding while maintaining security
    var passwordBinding: Binding<String> {
        Binding(
            get: { self.password },
            set: { newValue in
                self._password = newValue
                self._passwordLoaded = true
            }
        )
    }
    
    enum AuthenticationMethod: String, Codable, CaseIterable {
        case password = "Password"
        case oauth2 = "OAuth 2.0"
        case none = "None"
    }
    
    enum CodingKeys: String, CodingKey {
        case enabled, server, port, username, useTLS, useSSL, authenticationMethod
    }
    
    init() {
        loadSettings()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(enabled, forKey: .enabled)
        try container.encode(server, forKey: .server)
        try container.encode(port, forKey: .port)
        try container.encode(username, forKey: .username)
        try container.encode(useTLS, forKey: .useTLS)
        try container.encode(useSSL, forKey: .useSSL)
        try container.encode(authenticationMethod, forKey: .authenticationMethod)
        // Note: password is NEVER saved for security
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        enabled = try container.decode(Bool.self, forKey: .enabled)
        server = try container.decode(String.self, forKey: .server)
        port = try container.decode(Int.self, forKey: .port)
        username = try container.decode(String.self, forKey: .username)
        useTLS = try container.decode(Bool.self, forKey: .useTLS)
        useSSL = try container.decode(Bool.self, forKey: .useSSL)
        authenticationMethod = try container.decode(AuthenticationMethod.self, forKey: .authenticationMethod)
        // Password is never loaded from storage
    }
    
    func saveSettings() {
        // Save non-sensitive settings to UserDefaults
        if let encoded = try? JSONEncoder().encode(self),
           let data = String(data: encoded, encoding: .utf8) {
            UserDefaults.standard.set(data, forKey: "SMTPSettings")
        }
        
        // Handle password storage securely
        let currentPassword = _passwordLoaded ? _password : ""
        
        if !currentPassword.isEmpty {
            // Store password in Keychain
            let success = SecureStorage.storePassword(currentPassword, forKey: "smtp_password")
            if !success {
                // Log error (in production, use proper logging)
                print("Warning: Failed to store SMTP password in Keychain")
            }
            // Clear password from memory after storing
            SecureStorage.secureWipe(&_password)
            _passwordLoaded = false
        } else {
            // If password is empty, delete any stored password
            _ = SecureStorage.deletePassword(forKey: "smtp_password")
            _password = ""
            _passwordLoaded = false
        }
    }
    
    func loadSettings() {
        // Load non-sensitive settings from UserDefaults
        if let data = UserDefaults.standard.string(forKey: "SMTPSettings"),
           let decoded = try? JSONDecoder().decode(SMTPSettings.self, from: Data(data.utf8)) {
            self.enabled = decoded.enabled
            self.server = decoded.server
            self.port = decoded.port
            self.username = decoded.username
            self.useTLS = decoded.useTLS
            self.useSSL = decoded.useSSL
            self.authenticationMethod = decoded.authenticationMethod
        }
        
        // Password is NOT loaded here - it will be lazy loaded when accessed
        // This prevents keeping password in memory unnecessarily
        _password = ""
        _passwordLoaded = false
    }
    
    var isConfigured: Bool {
        !server.isEmpty && !username.isEmpty
    }
    
    // Securely clear password from memory
    func clearPassword() {
        SecureStorage.secureWipe(&_password)
        _passwordLoaded = false
    }
    
    // Delete stored password from Keychain
    func deleteStoredPassword() -> Bool {
        let success = SecureStorage.deletePassword(forKey: "smtp_password")
        clearPassword()
        return success
    }
    
    // Check if password is stored in Keychain (without loading it)
    var hasStoredPassword: Bool {
        return SecureStorage.hasPassword(forKey: "smtp_password")
    }
    
    // Validate SMTP settings
    func validate() -> (isValid: Bool, errorMessage: String?) {
        guard enabled else {
            return (true, nil) // Disabled settings are valid
        }
        
        guard !server.isEmpty else {
            return (false, "SMTP server address is required")
        }
        
        guard port > 0 && port <= 65535 else {
            return (false, "SMTP port must be between 1 and 65535")
        }
        
        guard !username.isEmpty else {
            return (false, "SMTP username is required")
        }
        
        guard InputValidator.isValidEmail(username) else {
            return (false, "SMTP username must be a valid email address")
        }
        
        if authenticationMethod == .password {
            // Password validation is optional - user may enter it later
            // But if they've saved before, we should check if it exists
        }
        
        return (true, nil)
    }
    
    // Common SMTP server presets
    static let commonServers: [String: (server: String, port: Int, useTLS: Bool, useSSL: Bool)] = [
        "Gmail": ("smtp.gmail.com", 587, true, false),
        "Outlook": ("smtp-mail.outlook.com", 587, true, false),
        "Yahoo": ("smtp.mail.yahoo.com", 587, true, false),
        "iCloud": ("smtp.mail.me.com", 587, true, false),
        "Custom": ("", 587, true, false)
    ]
}

