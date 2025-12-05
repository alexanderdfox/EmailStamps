import SwiftUI
internal import UniformTypeIdentifiers

struct PGPSettingsView: View {
    @Binding var settings: PGPSettings
    @Environment(\.dismiss) var dismiss
    @State private var showKeyFilePicker = false
    var showNavigation: Bool = true
    
    var body: some View {
        Group {
            if showNavigation {
                NavigationView {
                    contentView
                }
            } else {
                ScrollView {
                    contentView
                }
            }
        }
        #if os(macOS)
        .fileImporter(
            isPresented: $showKeyFilePicker,
            allowedContentTypes: [.data, .text],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result,
               let url = urls.first {
                settings.keyFilePath = url.path
            }
        }
        #endif
    }
    
    private var contentView: some View {
        ScrollView {
                VStack(spacing: 24) {
                    // Professional Header
                    HStack {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.appPrimary.opacity(0.2), Color.appSecondary.opacity(0.1)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color.appPrimary)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("PGP Settings")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                            Text("Configure cryptographic signing")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 20)
                    
                    // PGP Signing Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color.appPrimary)
                            Text("PGP Signing")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        
                        Toggle(isOn: $settings.enabled) {
                            Text("Enable PGP Signing")
                                .font(.system(size: 14))
                        }
                        .toggleStyle(.switch)
                        
                        if settings.enabled {
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Signature Style")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .textCase(.uppercase)
                                    
                                    Picker("", selection: $settings.signatureStyle) {
                                        ForEach(PGPSettings.PGPSignatureStyle.allCases, id: \.self) { style in
                                            Text(style.rawValue).tag(style)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                }
                                
                                Divider()
                                
                                Toggle(isOn: $settings.autoSign) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Auto-sign All Emails")
                                            .font(.system(size: 14))
                                        Text("Automatically sign all outgoing emails")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .toggleStyle(.switch)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.appCard)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.appBorder, lineWidth: 1.5)
                                    )
                            )
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.appCard)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                    
                    if settings.enabled {
                        // Key Configuration Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "key.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.appPrimary)
                                Text("PGP Key Configuration")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            
                            VStack(alignment: .leading, spacing: 20) {
                                // Key File Path
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Key File Path")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .textCase(.uppercase)
                                    
                                    HStack(spacing: 8) {
                                        TextField("Path to PGP key file", text: $settings.keyFilePath)
                                            .textFieldStyle(.plain)
                                            .padding(12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(Color.appBackground)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(Color.appBorder, lineWidth: 1.5)
                                                    )
                                            )
                                        
                                        Button(action: {
                                            showKeyFilePicker = true
                                        }) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "folder.fill")
                                                    .font(.system(size: 11))
                                                Text("Browse")
                                                    .font(.system(size: 12, weight: .medium))
                                            }
                                            .foregroundColor(Color.appPrimary)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(Color.appPrimary.opacity(0.1))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(Color.appPrimary.opacity(0.3), lineWidth: 1.5)
                                                    )
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    
                                    if !settings.keyFilePath.isEmpty {
                                        HStack(spacing: 6) {
                                            Image(systemName: settings.isConfigured ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                                .foregroundColor(settings.isConfigured ? .green : .orange)
                                            Text(settings.isConfigured ? "Key file configured" : "Key file not found")
                                                .font(.system(size: 11))
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.top, 4)
                                    }
                                }
                                
                                Divider()
                                
                                // Key ID
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Key ID (Optional)")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .textCase(.uppercase)
                                    
                                    TextField("e.g., 0x12345678 or user@example.com", text: $settings.keyID)
                                        .textFieldStyle(.plain)
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.appBackground)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(Color.appBorder, lineWidth: 1.5)
                                                )
                                        )
                                    
                                    Text("Leave empty to use default key from GPG keyring")
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary.opacity(0.7))
                                }
                                
                                Divider()
                                
                                // Key Password
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Key Password (Optional)")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .textCase(.uppercase)
                                    
                                    SecureField("Enter key password if required", text: $settings.keyPassword)
                                        .textFieldStyle(.plain)
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.appBackground)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(Color.appBorder, lineWidth: 1.5)
                                                )
                                        )
                                    
                                    HStack(spacing: 6) {
                                        Image(systemName: "info.circle.fill")
                                            .font(.system(size: 10))
                                            .foregroundColor(.secondary.opacity(0.7))
                                        Text("Password is securely stored in Keychain")
                                            .font(.system(size: 10))
                                            .foregroundColor(.secondary.opacity(0.7))
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.appCard)
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                        )
                        
                        // Information Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.appPrimary)
                                Text("Information")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Supported Key Formats:")
                                    .font(.system(size: 13, weight: .semibold))
                                
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.green)
                                    Text("Private key files (.asc, .gpg, .key)")
                                }
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.green)
                                    Text("Key ID (hexadecimal or email)")
                                }
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.green)
                                    Text("System keychain (if configured)")
                                }
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            }
                            .padding(.top, 8)
                            
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.orange)
                                Text("Note: Actual PGP signing requires GPG to be installed and configured on your system.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary.opacity(0.8))
                            }
                            .padding(.top, 8)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.orange.opacity(0.1), Color.orange.opacity(0.05)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.orange.opacity(0.2), lineWidth: 1.5)
                                    )
                            )
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.appPrimary.opacity(0.05), Color.appSecondary.opacity(0.02)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.appPrimary.opacity(0.2), lineWidth: 1.5)
                                )
                        )
                    }
                    
                    // Action Buttons (only show when standalone)
                    if showNavigation {
                        HStack(spacing: 12) {
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Cancel")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.appCard)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.appBorder, lineWidth: 1.5)
                                            )
                                    )
                            }
                            .buttonStyle(.plain)
                            
                            Spacer()
                            
                            Button(action: {
                                settings.saveSettings()
                                dismiss()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 14))
                                    Text("Save Settings")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.appPrimary, Color.appSecondary]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(10)
                                .shadow(color: Color.appPrimary.opacity(0.4), radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
                .padding(.horizontal, 20)
            }
            .background(Color.appBackground)
            #if os(macOS)
            .frame(width: showNavigation ? 700 : nil, height: showNavigation ? 700 : nil)
            #else
            .frame(maxWidth: showNavigation ? .infinity : nil, maxHeight: showNavigation ? .infinity : nil)
            #endif
        }
}
