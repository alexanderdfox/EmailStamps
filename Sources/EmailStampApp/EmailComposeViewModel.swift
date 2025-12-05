import SwiftUI
import Foundation
import CryptoKit

class EmailComposeViewModel: ObservableObject {
    @Published var recipient: String = ""
    @Published var subject: String = ""
    @Published var body: String = ""
    @Published var stampImage: NSImage?
    @Published var includePGP: Bool = true
    @Published var emailHash: String = ""
    @Published var generatedHTML: String?
    @Published var showPreview: Bool = false
    @Published var emails: [EmailItem] = []
    @Published var selectedEmail: EmailItem?
    
    private let generator = EmailStampGenerator()
    
    var canSend: Bool {
        !recipient.isEmpty && !subject.isEmpty && !body.isEmpty
    }
    
    init() {
        loadEmails()
    }
    
    func composeNewEmail() {
        recipient = ""
        subject = ""
        body = ""
        stampImage = nil
        emailHash = ""
        generatedHTML = nil
        selectedEmail = nil
        updateHash()
    }
    
    func updateHash() {
        let emailContent = "Subject: \(subject)\n\n\(body)"
        let data = Data(emailContent.utf8)
        let hash = SHA256.hash(data: data)
        emailHash = hash.compactMap { String(format: "%02x", $0) }.joined()
        
        // Update generator with stamp image
        if let imageData = stampImage?.tiffRepresentation {
            generator.setStampImage(imageData)
        }
        
        // Generate HTML preview
        generatedHTML = generator.generateHTML(
            subject: subject,
            body: body,
            includePGP: includePGP
        )
    }
    
    func sendEmail() {
        guard canSend else { return }
        
        // Generate final HTML
        if let imageData = stampImage?.tiffRepresentation {
            generator.setStampImage(imageData)
        }
        
        let html = generator.generateHTML(
            subject: subject,
            body: body,
            includePGP: includePGP
        )
        
        // Create email item
        let email = EmailItem(
            id: UUID(),
            recipient: recipient,
            subject: subject,
            body: body,
            htmlContent: html,
            date: Date(),
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
            // Copy to clipboard
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(email.htmlContent, forType: .html)
            pasteboard.setString(email.body, forType: .string)
            
        case .alertSecondButtonReturn:
            // Save file
            saveEmailToFile(email: email)
            
        default:
            break
        }
    }
    
    private func saveEmailToFile(email: EmailItem) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.html]
        panel.nameFieldStringValue = "\(email.subject.replacingOccurrences(of: " ", with: "_")).html"
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                try? email.htmlContent.write(to: url, atomically: true, encoding: .utf8)
            }
        }
    }
    
    func loadEmails() {
        // Load saved emails from UserDefaults or file
        // For now, start with empty list
        emails = []
    }
    
    func saveEmails() {
        // Save emails to UserDefaults or file
        // Implementation can be added later
    }
    
    func selectEmail(_ email: EmailItem) {
        selectedEmail = email
    }
}

struct EmailItem: Identifiable {
    let id: UUID
    let recipient: String
    let subject: String
    let body: String
    let htmlContent: String
    let date: Date
    let hash: String
}

