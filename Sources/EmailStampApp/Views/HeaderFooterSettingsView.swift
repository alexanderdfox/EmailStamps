import SwiftUI

struct HeaderFooterSettingsView: View {
    @ObservedObject var viewModel: EmailComposeViewModel
    @Environment(\.dismiss) var dismiss
    @State private var useAsDefault: Bool = false
    var showNavigation: Bool = true
    
    var body: some View {
        Group {
            if showNavigation {
        NavigationView {
                    contentView
                }
                #if os(macOS)
                .frame(width: 700, height: 750)
                #else
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                #endif
            } else {
                ScrollView {
                    contentView
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
                            
                            Image(systemName: "text.alignleft")
                                .font(.system(size: 24))
                                .foregroundColor(Color.appPrimary)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Header & Footer")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                            Text("Customize email headers and footers")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Header Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "textformat.size")
                                .font(.system(size: 14))
                                .foregroundColor(Color.appPrimary)
                            Text("Email Header")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Header appears at the top of your email")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            
                            TextEditor(text: $viewModel.header)
                                .frame(minHeight: 120)
                                .padding(8)
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
                                Text("Supports basic HTML formatting")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary.opacity(0.7))
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.appCard)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                    
                    // Footer Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "text.alignleft")
                                .font(.system(size: 14))
                                .foregroundColor(Color.appPrimary)
                            Text("Email Footer")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Footer appears at the bottom of your email")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            
                            TextEditor(text: $viewModel.footer)
                                .frame(minHeight: 120)
                                .padding(8)
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
                                Text("Supports basic HTML formatting")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary.opacity(0.7))
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.appCard)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                    
                    // Default Settings
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "star.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color.appPrimary)
                            Text("Default Settings")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        
                        Toggle(isOn: $useAsDefault) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Save as Default")
                                    .font(.system(size: 14))
                                Text("Use these header and footer for all new emails")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .toggleStyle(.switch)
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
                    
                    // Information Section
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color.appPrimary)
                            Text("Tips")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.green)
                                Text("Headers and footers are sanitized for security")
                            }
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.green)
                                Text("You can use basic HTML: <b>, <i>, <a>, <br>, etc.")
                            }
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.orange)
                                Text("Dangerous HTML tags and scripts are automatically removed")
                            }
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        }
                        .padding(.top, 8)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.appCard)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                    
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
                            if useAsDefault {
                                viewModel.saveDefaultHeader()
                                viewModel.saveDefaultFooter()
                            }
                            viewModel.updateHash()
                            dismiss()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14))
                                Text("Save")
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


