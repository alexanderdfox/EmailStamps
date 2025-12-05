import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - Theme Colors (Dark Mode Support)
extension Color {
    // Primary colors
    static let appPrimary = Color(red: 0.2, green: 0.4, blue: 0.8)
    static let appSecondary = Color(red: 0.3, green: 0.5, blue: 0.9)
    static let appAccent = Color(red: 0.9, green: 0.3, blue: 0.2)
    
    // Adaptive colors for light/dark mode
    static var appBackground: Color {
        #if os(iOS)
        return Color(light: Color(red: 0.96, green: 0.97, blue: 0.98),
                     dark: Color(red: 0.11, green: 0.11, blue: 0.12))
        #elseif os(macOS)
        return Color(light: Color(red: 0.96, green: 0.97, blue: 0.98),
                     dark: Color(red: 0.11, green: 0.11, blue: 0.12))
        #else
        return Color(red: 0.96, green: 0.97, blue: 0.98)
        #endif
    }
    
    static var appCard: Color {
        #if os(iOS)
        return Color(light: .white,
                     dark: Color(red: 0.17, green: 0.17, blue: 0.18))
        #elseif os(macOS)
        return Color(light: .white,
                     dark: Color(red: 0.17, green: 0.17, blue: 0.18))
        #else
        return .white
        #endif
    }
    
    static var appBorder: Color {
        #if os(iOS)
        return Color(light: Color(red: 0.9, green: 0.9, blue: 0.92),
                     dark: Color(red: 0.3, green: 0.3, blue: 0.32))
        #elseif os(macOS)
        return Color(light: Color(red: 0.9, green: 0.9, blue: 0.92),
                     dark: Color(red: 0.3, green: 0.3, blue: 0.32))
        #else
        return Color(red: 0.9, green: 0.9, blue: 0.92)
        #endif
    }
    
    static var appTextPrimary: Color {
        #if os(iOS)
        return Color(light: .black, dark: .white)
        #elseif os(macOS)
        return Color(light: .black, dark: .white)
        #else
        return .black
        #endif
    }
    
    static var appTextSecondary: Color {
        #if os(iOS)
        return Color(light: .secondary, dark: Color(white: 0.7))
        #elseif os(macOS)
        return Color(light: .secondary, dark: Color(white: 0.7))
        #else
        return .secondary
        #endif
    }
}

// Helper extension for adaptive colors
extension Color {
    init(light: Color, dark: Color) {
        #if os(iOS)
        self.init(
            UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(dark)
                default:
                    return UIColor(light)
                }
            }
        )
        #elseif os(macOS)
        self.init(
            NSColor(name: nil) { appearance in
                switch appearance.name {
                case .darkAqua, .vibrantDark, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark:
                    return NSColor(dark)
                default:
                    return NSColor(light)
                }
            }
        )
        #else
        self = light
        #endif
    }
}

// MARK: - Theme View Modifier
struct ThemeModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .preferredColorScheme(colorScheme)
    }
}

extension View {
    func themed() -> some View {
        modifier(ThemeModifier())
    }
}

