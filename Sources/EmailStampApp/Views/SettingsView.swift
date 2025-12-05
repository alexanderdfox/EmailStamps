import SwiftUI
#if os(macOS)
import AppKit
#endif

struct SettingsView: View {
    @ObservedObject var viewModel: EmailComposeViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab: SettingsTab = .pgp
    
    enum SettingsTab: String, CaseIterable {
        case pgp = "PGP"
        case smtp = "SMTP"
        case headerFooter = "Header & Footer"
        
        var icon: String {
            switch self {
            case .pgp: return "lock.shield.fill"
            case .smtp: return "server.rack"
            case .headerFooter: return "text.alignleft"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            #if os(macOS)
            HSplitView {
                // Sidebar with tabs
                VStack(alignment: .leading, spacing: 0) {
                    Text("Settings")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                    
                    Divider()
                    
                    ForEach(SettingsTab.allCases, id: \.self) { tab in
                        Button(action: {
                            selectedTab = tab
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: tab.icon)
                                    .font(.system(size: 16))
                                    .frame(width: 24)
                                Text(tab.rawValue)
                                    .font(.system(size: 14, weight: selectedTab == tab ? .semibold : .regular))
                            }
                            .foregroundColor(selectedTab == tab ? Color.appPrimary : .secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedTab == tab ? Color.appPrimary.opacity(0.1) : Color.clear)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Spacer()
                }
                .frame(width: 200)
                .background(Color.appBackground)
                
                // Content area
                VStack(spacing: 0) {
                    Group {
                        switch selectedTab {
                        case .pgp:
                            PGPSettingsView(settings: $viewModel.pgpSettings, showNavigation: false)
                        case .smtp:
                            SMTPSettingsView(settings: $viewModel.smtpSettings, showNavigation: false)
                        case .headerFooter:
                            HeaderFooterSettingsView(viewModel: viewModel, showNavigation: false)
                        }
                    }
                    
                    // Bottom buttons for macOS
                    Divider()
                    HStack(spacing: 12) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .buttonStyle(.bordered)
                        
                        Spacer()
                        
                        Button("Done") {
                            // Save all settings
                            viewModel.pgpSettings.saveSettings()
                            viewModel.smtpSettings.saveSettings()
                            viewModel.updateHash()
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .background(Color.appBackground)
                }
            }
            #else
            TabView(selection: $selectedTab) {
                PGPSettingsView(settings: $viewModel.pgpSettings, showNavigation: false)
                    .tabItem {
                        Label("PGP", systemImage: "lock.shield.fill")
                    }
                    .tag(SettingsTab.pgp)
                
                SMTPSettingsView(settings: $viewModel.smtpSettings, showNavigation: false)
                    .tabItem {
                        Label("SMTP", systemImage: "server.rack")
                    }
                    .tag(SettingsTab.smtp)
                
                HeaderFooterSettingsView(viewModel: viewModel, showNavigation: false)
                    .tabItem {
                        Label("Header & Footer", systemImage: "text.alignleft")
                    }
                    .tag(SettingsTab.headerFooter)
            }
            #endif
        }
        #if os(iOS)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    // Validate SMTP settings before saving
                    let validation = viewModel.smtpSettings.validate()
                    if !validation.isValid, let error = validation.errorMessage {
                        #if os(macOS)
                        let alert = NSAlert()
                        alert.messageText = "Invalid SMTP Settings"
                        alert.informativeText = error
                        alert.addButton(withTitle: "OK")
                        alert.runModal()
                        #else
                        PlatformAlert.show(title: "Invalid SMTP Settings", message: error)
                        #endif
                        return
                    }
                    
                    // Save all settings
                    viewModel.pgpSettings.saveSettings()
                    viewModel.smtpSettings.saveSettings()
                    viewModel.updateHash()
                    dismiss()
                }
                .fontWeight(.semibold)
            }
        }
        #else
        .frame(width: 900, height: 700)
        #endif
    }
}

