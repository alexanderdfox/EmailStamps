import SwiftUI
import Foundation
import CryptoKit
import Combine

class EmailComposeViewModel: ObservableObject {
    @Published var recipient: String = ""
    @Published var subject: String = ""
    @Published var body: String = ""
    @Published var header: String = ""
    @Published var footer: String = ""
    @Published var stampImage: PlatformImage?
    @Published var includePGP: Bool = true
    @Published var emailHash: String = ""
    @Published var generatedHTML: String?
    @Published var showPreview: Bool = false
    @Published var emails: [EmailItem] = []
    @Published var selectedEmail: EmailItem?
    @Published var showPGPSettings: Bool = false
    @Published var showHeaderFooterSettings: Bool = false
    
    @Published var pgpSettings = PGPSettings()
    
    private let generator = EmailStampGenerator()
    
    var canSend: Bool {
        !recipient.isEmpty && 
        !subject.isEmpty && 
        !body.isEmpty &&
        InputValidator.isValidEmail(recipient)
    }
    
    init() {
        loadEmails()
        header = loadDefaultHeader()
        footer = loadDefaultFooter()
    }
    
    func composeNewEmail() {
        recipient = ""
        subject = ""
        body = ""
        header = loadDefaultHeader()
        footer = loadDefaultFooter()
        stampImage = nil
        emailHash = ""
        generatedHTML = nil
        selectedEmail = nil
        updateHash()
    }
    
    func loadDefaultHeader() -> String {
        return UserDefaults.standard.string(forKey: "DefaultEmailHeader") ?? ""
    }
    
    func loadDefaultFooter() -> String {
        return UserDefaults.standard.string(forKey: "DefaultEmailFooter") ?? ""
    }
    
    func saveDefaultHeader() {
        UserDefaults.standard.set(header, forKey: "DefaultEmailHeader")
    }
    
    func saveDefaultFooter() {
        UserDefaults.standard.set(footer, forKey: "DefaultEmailFooter")
    }
    
    func updateHash() {
        let emailContent = "Subject: \(subject)\n\n\(body)"
        let data = Data(emailContent.utf8)
        let hash = SHA256.hash(data: data)
        emailHash = hash.compactMap { String(format: "%02x", $0) }.joined()
        
        // Update generator with stamp image
        if let image = stampImage {
            #if os(iOS)
            if let imageData = image.pngData() {
                generator.setStampImage(imageData)
            }
            #elseif os(macOS)
            if let imageData = image.tiffRepresentation {
                generator.setStampImage(imageData)
            }
            #endif
        }
        
        // Generate HTML preview
        generatedHTML = generator.generateHTML(
            subject: subject,
            body: body,
            header: header,
            footer: footer,
            includePGP: includePGP && pgpSettings.enabled,
            pgpSettings: pgpSettings
        )
    }
    
    func sendEmail() {
        guard canSend else { return }
        
        // Validate inputs
        guard InputValidator.isValidEmail(recipient) else {
            PlatformAlert.show(title: "Invalid Email", message: "Please enter a valid email address")
            return
        }
        
        // Generate final HTML
        if let image = stampImage {
            #if os(iOS)
            if let imageData = image.pngData() {
                generator.setStampImage(imageData)
            }
            #elseif os(macOS)
            if let imageData = image.tiffRepresentation {
                generator.setStampImage(imageData)
            }
            #endif
        }
        
        let html = generator.generateHTML(
            subject: subject,
            body: body,
            header: header,
            footer: footer,
            includePGP: includePGP && pgpSettings.enabled,
            pgpSettings: pgpSettings
        )
        
        // Sanitize HTML before storing
        let sanitizedHTML = InputValidator.sanitizeHTML(html)
        
        // Create email item
        let email = EmailItem(
            recipient: recipient,
            subject: subject,
            body: body,
            htmlContent: sanitizedHTML,
            hash: emailHash
        )
        
        // Add to emails list
        emails.insert(email, at: 0)
        saveEmails()
        
        // Show email sending options
        showEmailSendingOptions(email: email)
        
        // Reset compose view
        composeNewEmail()
    }
    
    private func showEmailSendingOptions(email: EmailItem) {
        #if os(macOS)
        let alert = NSAlert()
        alert.messageText = "Email Ready to Send"
        alert.informativeText = """
        Your email has been prepared with cryptographic verification.
        
        Options:
        1. Copy HTML to clipboard (paste into your email client)
        2. Save HTML file
        3. Export for sending
        """
        alert.addButton(withTitle: "Copy HTML")
        alert.addButton(withTitle: "Save File")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        
        switch response {
        case .alertFirstButtonReturn:
            PlatformPasteboard.copy(email.htmlContent, asHTML: true)
            
        case .alertSecondButtonReturn:
            saveEmailToFile(email: email)
            
        default:
            break
        }
        #elseif os(iOS)
        // iOS: Show action sheet
        PlatformAlert.show(title: "Email Ready", message: "Your email has been prepared. Use the share button to send it.")
        #endif
    }
    
    private func saveEmailToFile(email: EmailItem) {
        #if os(macOS)
        PlatformSavePanel.saveFile(
            content: email.htmlContent,
            filename: "\(email.subject.replacingOccurrences(of: " ", with: "_")).html"
        ) { success in
            if !success {
                PlatformAlert.show(title: "Error", message: "Failed to save file")
            }
        }
        #endif
    }
    
    func loadEmails() {
        // Load saved emails from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "SavedEmails"),
           let decoded = try? JSONDecoder().decode([EmailItem].self, from: data) {
            emails = decoded
        }
    }
    
    func saveEmails() {
        // Save emails to UserDefaults
        if let encoded = try? JSONEncoder().encode(emails) {
            UserDefaults.standard.set(encoded, forKey: "SavedEmails")
        }
    }
    
    func selectEmail(_ email: EmailItem) {
        selectedEmail = email
    }
}

extension Notification.Name {
    static let newEmail = Notification.Name("newEmail")
}

