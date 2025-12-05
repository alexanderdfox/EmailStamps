import SwiftUI
import CryptoKit
import AppKit
internal import UniformTypeIdentifiers

class EmailStampViewModel: ObservableObject {
    @Published var subject: String = ""
    @Published var body: String = ""
    @Published var stampImage: NSImage?
    @Published var includePGP: Bool = true
    @Published var generatedHTML: String?
    @Published var emailHash: String = ""
    
    @Published var showSuccessAlert = false
    @Published var showErrorAlert = false
    @Published var successMessage = ""
    @Published var errorMessage = ""
    
    private var stampImageData: Data?
    
    func selectStampImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                if let image = NSImage(contentsOf: url) {
                    self.stampImage = image
                    self.stampImageData = try? Data(contentsOf: url)
                }
            }
        }
    }
    
    func generateHTML() {
        guard !subject.isEmpty && !body.isEmpty else {
            showError(message: "Subject and body cannot be empty")
            return
        }
        
        // Compute hash
        let emailContent = "Subject: \(subject)\n\n\(body)"
        emailHash = computeSHA256(content: emailContent)
        
        // Generate QR code
        let qrCodeBase64 = generateQRCode(from: emailHash)
        
        // Generate HTML
        generatedHTML = buildHTMLTemplate(
            subject: subject,
            body: body,
            emailHash: emailHash,
            qrCodeBase64: qrCodeBase64
        )
        
        showSuccess(message: "HTML generated successfully!")
    }
    
    func saveHTMLFile() {
        guard let html = generatedHTML else { return }
        
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.html]
        panel.nameFieldStringValue = "email_stamped.html"
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                do {
                    try html.write(to: url, atomically: true, encoding: .utf8)
                    showSuccess(message: "HTML file saved successfully!")
                } catch {
                    showError(message: "Failed to save file: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func copyToClipboard() {
        guard let html = generatedHTML else { return }
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(html, forType: .string)
        
        showSuccess(message: "HTML copied to clipboard!")
    }
    
    private func computeSHA256(content: String) -> String {
        let data = Data(content.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func generateQRCode(from string: String) -> String {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return ""
        }
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        guard let outputImage = filter.outputImage else {
            return ""
        }
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = outputImage.transformed(by: transform)
        
        let rep = NSCIImageRep(ciImage: scaledImage)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        
        // Convert to PNG data
        guard let tiffData = nsImage.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData) else {
            return ""
        }
        
        guard let pngData = bitmapImage.representation(using: NSBitmapImageRep.FileType.png, properties: [:]) else {
            return ""
        }
        
        return pngData.base64EncodedString()
    }
    
    private func buildHTMLTemplate(
        subject: String,
        body: String,
        emailHash: String,
        qrCodeBase64: String
    ) -> String {
        
        // Convert body to HTML (preserve line breaks)
        let bodyHTML = body
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\n", with: "<br>\n")
        
        // Stamp image HTML
        var stampHTML = ""
        if let imageData = stampImageData {
            let imageBase64 = imageData.base64EncodedString()
            let mimeType = getMimeType(for: imageData)
            stampHTML = """
            <div style="text-align: center; margin: 20px 0;">
                <img src="data:\(mimeType);base64,\(imageBase64)" 
                     alt="Verification Stamp" 
                     style="max-width: 200px; height: auto; border: 2px solid #333; padding: 10px; background: white;">
            </div>
            """
        }
        
        // QR code HTML
        let qrHTML = """
        <div style="text-align: center; margin: 20px 0;">
            <h3 style="color: #333; margin-bottom: 10px;">Email Verification</h3>
            <img src="data:image/png;base64,\(qrCodeBase64)" 
                 alt="Email Hash QR Code" 
                 style="max-width: 200px; height: auto; border: 2px solid #333; padding: 10px; background: white;">
            <p style="font-size: 10px; color: #666; margin-top: 10px; font-family: monospace;">
                Hash: \(emailHash)
            </p>
            <p style="font-size: 12px; color: #666; margin-top: 5px;">
                Scan this QR code to verify the email content integrity
            </p>
        </div>
        """
        
        // PGP signature placeholder
        var pgpHTML = ""
        if includePGP {
            pgpHTML = """
            <div style="margin: 30px 0; padding: 15px; background: #f5f5f5; border-left: 4px solid #007bff;">
                <h4 style="color: #333; margin-top: 0;">PGP Signature</h4>
                <div style="background: white; padding: 10px; border: 1px solid #ddd; font-family: monospace; font-size: 11px; color: #333; white-space: pre-wrap;">
                    -----BEGIN PGP SIGNATURE-----
                    [PGP signature will be inserted here]
                    -----END PGP SIGNATURE-----
                </div>
                <p style="font-size: 12px; color: #666; margin-top: 10px; margin-bottom: 0;">
                    PGP signature for additional cryptographic verification
                </p>
            </div>
            """
        }
        
        // Escape subject for HTML
        let subjectEscaped = subject
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
        
        // Complete HTML template
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>\(subjectEscaped)</title>
            <style>
                body {
                    font-family: Arial, sans-serif;
                    line-height: 1.6;
                    color: #333;
                    max-width: 600px;
                    margin: 0 auto;
                    padding: 20px;
                    background-color: #f9f9f9;
                }
                .email-container {
                    background: white;
                    padding: 30px;
                    border-radius: 8px;
                    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                }
                .subject {
                    font-size: 18px;
                    font-weight: bold;
                    color: #222;
                    margin-bottom: 20px;
                    padding-bottom: 15px;
                    border-bottom: 2px solid #eee;
                }
                .body {
                    font-size: 14px;
                    color: #444;
                    margin: 20px 0;
                }
                .verification-section {
                    margin-top: 30px;
                    padding-top: 20px;
                    border-top: 2px solid #eee;
                }
                .hash-info {
                    background: #f8f9fa;
                    padding: 10px;
                    border-radius: 4px;
                    margin-top: 10px;
                }
            </style>
        </head>
        <body>
            <div class="email-container">
                <div class="subject">\(subjectEscaped)</div>
                
                <div class="body">
                    \(bodyHTML)
                </div>
                
                \(stampHTML)
                
                <div class="verification-section">
                    \(qrHTML)
                </div>
                
                \(pgpHTML)
                
                <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee; font-size: 11px; color: #999; text-align: center;">
                    <p>This email includes cryptographic verification. The QR code contains a SHA256 hash of the email content.</p>
                </div>
            </div>
        </body>
        </html>
        """
    }
    
    private func getMimeType(for data: Data) -> String {
        // Check PNG signature
        if data.count >= 8 {
            let pngSignature: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
            let header = Array(data.prefix(8))
            if header == pngSignature {
                return "image/png"
            }
        }
        
        // Check JPEG signature
        if data.count >= 3 {
            let jpegSignature: [UInt8] = [0xFF, 0xD8, 0xFF]
            let header = Array(data.prefix(3))
            if header == jpegSignature {
                return "image/jpeg"
            }
        }
        
        // Default to PNG
        return "image/png"
    }
    
    private func showSuccess(message: String) {
        successMessage = message
        showSuccessAlert = true
    }
    
    private func showError(message: String) {
        errorMessage = message
        showErrorAlert = true
    }
}

