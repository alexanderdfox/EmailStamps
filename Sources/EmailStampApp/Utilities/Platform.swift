import Foundation
import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
internal import UniformTypeIdentifiers
#endif

// MARK: - Platform Detection
enum Platform {
    static var isIOS: Bool {
        #if os(iOS)
        return true
        #else
        return false
        #endif
    }
    
    static var isMacOS: Bool {
        #if os(macOS)
        return true
        #else
        return false
        #endif
    }
    
    static var isIPad: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad
        #else
        return false
        #endif
    }
    
    static var isIPhone: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .phone
        #else
        return false
        #endif
    }
}

// MARK: - Platform-Specific Image Type
#if os(iOS)
typealias PlatformImage = UIImage
#elseif os(macOS)
typealias PlatformImage = NSImage
#endif

// MARK: - Platform-Specific Pasteboard
struct PlatformPasteboard {
    static func copy(_ string: String, asHTML: Bool = false) {
        #if os(iOS)
        UIPasteboard.general.string = string
        if asHTML {
            UIPasteboard.general.setValue(string, forPasteboardType: "public.html")
        }
        #elseif os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        if asHTML {
            pasteboard.setString(string, forType: .html)
        }
        pasteboard.setString(string, forType: .string)
        #endif
    }
}

// MARK: - Platform-Specific File Picker
struct PlatformFilePicker {
    #if os(iOS)
    static func pickImage(completion: @escaping (UIImage?) -> Void) {
        // iOS implementation would use PHPickerViewController
        // For now, return nil - will be implemented in view
        completion(nil)
    }
    #elseif os(macOS)
    static func pickImage(completion: @escaping (NSImage?) -> Void) {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        
        if panel.runModal() == .OK, let url = panel.url {
            completion(NSImage(contentsOf: url))
        } else {
            completion(nil)
        }
    }
    #endif
}

// MARK: - Platform-Specific Save Panel
struct PlatformSavePanel {
    #if os(iOS)
    static func saveFile(content: String, filename: String, completion: @escaping (Bool) -> Void) {
        // iOS uses UIActivityViewController
        completion(false)
    }
    #elseif os(macOS)
    static func saveFile(content: String, filename: String, completion: @escaping (Bool) -> Void) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.html]
        panel.nameFieldStringValue = filename
        
        if panel.runModal() == .OK, let url = panel.url {
            do {
                try content.write(to: url, atomically: true, encoding: .utf8)
                completion(true)
            } catch {
                completion(false)
            }
        } else {
            completion(false)
        }
    }
    #endif
}

// MARK: - Platform-Specific Alert
struct PlatformAlert {
    #if os(iOS)
    static func show(title: String, message: String, completion: (() -> Void)? = nil) {
        // iOS implementation
        completion?()
    }
    #elseif os(macOS)
    static func show(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: "OK")
        alert.runModal()
        completion?()
    }
    #endif
}

