import SwiftUI

extension View {
    @ViewBuilder
    func onChangeCompat<T: Equatable>(of value: T, perform action: @escaping (T) -> Void) -> some View {
        if #available(macOS 14.0, *) {
            self.onChange(of: value) { _, newValue in
                action(newValue)
            }
        } else {
            self.onChange(of: value, perform: action)
        }
    }
}

struct SMTPSettingsView: View {
    @Binding var settings: SMTPSettings
    @Environment(\.dismiss) var dismiss
    @State private var selectedPreset: String = "Custom"
    var showNavigation: Bool = true
    
    var body: some View {
        Group {
            if showNavigation {
                NavigationView {
                    contentView
                }
                #if os(macOS)
                .frame(width: 700, height: 700)
                #else
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                #endif
            } else {
                ScrollView {
                    contentView
                }
            }
        }
        .onAppear {
            // Set preset based on current server
            for (preset, config) in SMTPSettings.commonServers {
                if config.server == settings.server && config.port == settings.port {
                    selectedPreset = preset
                    break
                }
            }
        }
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
                            
                            Image(systemName: "server.rack")
                                .font(.system(size: 24))
                                .foregroundColor(Color.appPrimary)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SMTP Settings")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                            Text("Configure email server connection")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 20)
                    
                    // SMTP Configuration Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "network")
                                .font(.system(size: 14))
                                .foregroundColor(Color.appPrimary)
                            Text("SMTP Configuration")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        
                        Toggle(isOn: $settings.enabled) {
                            Text("Enable SMTP")
                                .font(.system(size: 14))
                        }
                        .toggleStyle(.switch)
                        
                        if settings.enabled {
                            VStack(alignment: .leading, spacing: 16) {
                                // Server Preset
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Server Preset")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .textCase(.uppercase)
                                    
                                    Picker("", selection: $selectedPreset) {
                                        ForEach(Array(SMTPSettings.commonServers.keys.sorted()), id: \.self) { preset in
                                            Text(preset).tag(preset)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .onChangeCompat(of: selectedPreset) { newValue in
                                        if let preset = SMTPSettings.commonServers[newValue] {
                                            settings.server = preset.server
                                            settings.port = preset.port
                                            settings.useTLS = preset.useTLS
                                            settings.useSSL = preset.useSSL
                                        }
                                    }
                                }
                                
                                Divider()
                                
                                // Server Address
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("SMTP Server")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .textCase(.uppercase)
                                    
                                    TextField("smtp.example.com", text: $settings.server)
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
                                }
                                
                                Divider()
                                
                                // Port
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Port")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .textCase(.uppercase)
                                    
                                    HStack(spacing: 12) {
                                        TextField("587", value: $settings.port, format: .number)
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
                                        
                                        // Common ports
                                        HStack(spacing: 8) {
                                            ForEach([25, 465, 587, 993], id: \.self) { port in
                                                Button("\(port)") {
                                                    settings.port = port
                                                }
                                                .font(.system(size: 11))
                                                .foregroundColor(settings.port == port ? .white : Color.appPrimary)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 6)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .fill(settings.port == port ? Color.appPrimary : Color.appPrimary.opacity(0.1))
                                                )
                                            }
                                        }
                                    }
                                }
                                
                                Divider()
                                
                                // Security Options
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Security")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .textCase(.uppercase)
                                    
                                    Toggle(isOn: $settings.useTLS) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Use TLS (STARTTLS)")
                                                .font(.system(size: 14))
                                            Text("Recommended for most servers")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .toggleStyle(.switch)
                                    
                                    Toggle(isOn: $settings.useSSL) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Use SSL (SMTPS)")
                                                .font(.system(size: 14))
                                            Text("Direct SSL connection (port 465)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .toggleStyle(.switch)
                                    .disabled(settings.useTLS)
                                    
                                    if settings.useTLS && settings.useSSL {
                                        HStack(spacing: 6) {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .font(.system(size: 10))
                                                .foregroundColor(.orange)
                                            Text("TLS and SSL cannot be used simultaneously")
                                                .font(.system(size: 10))
                                                .foregroundColor(.secondary.opacity(0.7))
                                        }
                                        .padding(.top, 4)
                                    }
                                }
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
                        // Authentication Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "person.badge.key.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.appPrimary)
                                Text("Authentication")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            
                            VStack(alignment: .leading, spacing: 20) {
                                // Authentication Method
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Authentication Method")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .textCase(.uppercase)
                                    
                                    Picker("", selection: $settings.authenticationMethod) {
                                        ForEach(SMTPSettings.AuthenticationMethod.allCases, id: \.self) { method in
                                            Text(method.rawValue).tag(method)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                }
                                
                                if settings.authenticationMethod == .password {
                                    Divider()
                                    
                                    // Username
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Username / Email")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.secondary)
                                            .textCase(.uppercase)
                                        
                                        TextField("your.email@example.com", text: $settings.username)
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
                                    }
                                    
                                    Divider()
                                    
                                    // Password
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Password")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.secondary)
                                            .textCase(.uppercase)
                                        
                                        SecureField("Enter SMTP password", text: settings.passwordBinding)
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
                                        
                                        HStack(spacing: 8) {
                                            HStack(spacing: 6) {
                                                Image(systemName: "info.circle.fill")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(.secondary.opacity(0.7))
                                                Text("Password is securely stored in Keychain")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(.secondary.opacity(0.7))
                                            }
                                            
                                            if settings.hasStoredPassword {
                                                Spacer()
                                                Button(action: {
                                                    _ = settings.deleteStoredPassword()
                                                }) {
                                                    HStack(spacing: 4) {
                                                        Image(systemName: "trash")
                                                            .font(.system(size: 10))
                                                        Text("Clear")
                                                            .font(.system(size: 10))
                                                    }
                                                    .foregroundColor(.red.opacity(0.8))
                                                }
                                                .buttonStyle(.plain)
                                                .help("Delete stored password from Keychain")
                                            }
                                        }
                                    }
                                } else if settings.authenticationMethod == .oauth2 {
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "info.circle.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(.orange)
                                            Text("OAuth 2.0 authentication is not yet implemented")
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.orange.opacity(0.1))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(Color.orange.opacity(0.2), lineWidth: 1.5)
                                                )
                                        )
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
                        
                        // Connection Status
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.appPrimary)
                                Text("Connection Status")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            
                            HStack(spacing: 8) {
                                Image(systemName: settings.isConfigured ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                    .foregroundColor(settings.isConfigured ? .green : .orange)
                                Text(settings.isConfigured ? "SMTP server configured" : "Please configure server and username")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                settings.isConfigured ? Color.green.opacity(0.1) : Color.orange.opacity(0.1),
                                                settings.isConfigured ? Color.green.opacity(0.05) : Color.orange.opacity(0.05)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(settings.isConfigured ? Color.green.opacity(0.2) : Color.orange.opacity(0.2), lineWidth: 1.5)
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
        }
    }

