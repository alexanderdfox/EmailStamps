import Foundation
import CryptoKit
import CoreImage

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

class EmailStampGenerator {
    
    private var stampImageData: Data?
    
    func setStampImage(_ imageData: Data?) {
        self.stampImageData = imageData
    }
    
    func generateHTML(
        subject: String,
        body: String,
        header: String = "",
        footer: String = "",
        includePGP: Bool = true,
        pgpSettings: PGPSettings? = nil
    ) -> String {
        
        // Compute hash (header and footer are not included in hash for content integrity)
        let emailContent = "Subject: \(subject)\n\n\(body)"
        let emailHash = computeSHA256(content: emailContent)
        
        // Generate QR code
        let qrCodeBase64 = generateQRCode(from: emailHash)
        
        // Build HTML
        return buildHTMLTemplate(
            subject: subject,
            body: body,
            header: header,
            footer: footer,
            emailHash: emailHash,
            qrCodeBase64: qrCodeBase64,
            includePGP: includePGP,
            pgpSettings: pgpSettings
        )
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
        
        #if os(iOS)
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return ""
        }
        let uiImage = UIImage(cgImage: cgImage)
        guard let pngData = uiImage.pngData() else {
            return ""
        }
        #elseif os(macOS)
        let rep = NSCIImageRep(ciImage: scaledImage)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        
        guard let tiffData = nsImage.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData) else {
            return ""
        }
        
        guard let pngData = bitmapImage.representation(
            using: NSBitmapImageRep.FileType.png,
            properties: [:]
        ) else {
            return ""
        }
        #endif
        
        return pngData.base64EncodedString()
    }
    
    private func buildHTMLTemplate(
        subject: String,
        body: String,
        header: String,
        footer: String,
        emailHash: String,
        qrCodeBase64: String,
        includePGP: Bool,
        pgpSettings: PGPSettings?
    ) -> String {
        
        // Convert header to HTML (sanitize but allow basic HTML)
        let headerHTML = InputValidator.sanitizeHTML(header)
            .replacingOccurrences(of: "\n", with: "<br>\n")
        
        // Convert body to HTML (preserve line breaks, escape HTML)
        let bodyHTML = body
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\n", with: "<br>\n")
        
        // Convert footer to HTML (sanitize but allow basic HTML)
        let footerHTML = InputValidator.sanitizeHTML(footer)
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
            let signatureStyle: PGPSettings.PGPSignatureStyle
            let keyInfo: String
            
            if let settings = pgpSettings {
                signatureStyle = settings.signatureStyle
                if settings.isConfigured {
                    keyInfo = !settings.keyID.isEmpty ? "Key ID: \(settings.keyID)" : "Key file: \(settings.keyFilePath)"
                } else {
                    keyInfo = "No key configured"
                }
            } else {
                signatureStyle = .inline
                keyInfo = "No key configured"
            }
            
            let signatureType: String
            switch signatureStyle {
            case .inline:
                signatureType = "Inline Signature"
            case .detached:
                signatureType = "Detached Signature"
            case .clear:
                signatureType = "Clear Text Signature"
            }
            
            pgpHTML = """
            <div style="margin: 30px 0; padding: 15px; background: #f5f5f5; border-left: 4px solid #007bff;">
                <h4 style="color: #333; margin-top: 0;">PGP Signature (\(signatureType))</h4>
                <div style="background: white; padding: 10px; border: 1px solid #ddd; font-family: monospace; font-size: 11px; color: #333; white-space: pre-wrap;">
                    -----BEGIN PGP SIGNATURE-----
                    [PGP signature will be inserted here]
                    \(keyInfo)
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
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif;
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
                .header {
                    font-size: 12px;
                    color: #666;
                    margin-bottom: 20px;
                    padding-bottom: 15px;
                    border-bottom: 1px solid #eee;
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
                .footer {
                    font-size: 12px;
                    color: #666;
                    margin-top: 30px;
                    padding-top: 15px;
                    border-top: 1px solid #eee;
                }
                .verification-section {
                    margin-top: 30px;
                    padding-top: 20px;
                    border-top: 2px solid #eee;
                }
            </style>
        </head>
        <body>
            <div class="email-container">
                \(headerHTML.isEmpty ? "" : "<div class=\"header\">\(headerHTML)</div>")
                
                <div class="subject">\(subjectEscaped)</div>
                
                <div class="body">
                    \(bodyHTML)
                </div>
                
                \(stampHTML)
                
                <div class="verification-section">
                    \(qrHTML)
                </div>
                
                \(pgpHTML)
                
                \(footerHTML.isEmpty ? "" : "<div class=\"footer\">\(footerHTML)</div>")
                
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
}

