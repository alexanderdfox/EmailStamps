import SwiftUI

extension View {
    @ViewBuilder
    func onChangeCompat<T: Equatable>(of value: T, perform action: @escaping () -> Void) -> some View {
        if #available(macOS 14.0, *) {
            self.onChange(of: value) { _, _ in
                action()
            }
        } else {
            self.onChange(of: value, perform: { _ in
                action()
            })
        }
    }
}

struct EmailComposeView: View {
    @ObservedObject var viewModel: EmailComposeViewModel
    @State private var showStampPicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Enhanced Professional Toolbar
            HStack(spacing: 12) {
                // Send Button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.sendEmail()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Send")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Group {
                            if viewModel.canSend {
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.appPrimary, Color.appSecondary]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            } else {
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            }
                        }
                    )
                    .cornerRadius(10)
                    .shadow(color: viewModel.canSend ? Color.appPrimary.opacity(0.4) : .clear, radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.canSend)
                
                // Add Stamp Button
                Button(action: {
                    showStampPicker = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "seal.fill")
                            .font(.system(size: 13))
                        Text("Add Stamp")
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
                
                Spacer()
                
                // PGP Toggle
                HStack(spacing: 8) {
                    Image(systemName: viewModel.includePGP ? "lock.fill" : "lock.open")
                        .font(.system(size: 12))
                        .foregroundColor(viewModel.includePGP ? Color.appAccent : .secondary)
                    Toggle("", isOn: $viewModel.includePGP)
                        .toggleStyle(.switch)
                        .labelsHidden()
                    Text("PGP")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.appCard)
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                )
                
                // Unified Settings Button
                Button(action: {
                    viewModel.showSettings = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color.appCard)
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        )
                }
                .buttonStyle(.plain)
                .help("Settings")
            }
            .padding(16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.appBackground, Color.appCard]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.appBorder),
                alignment: .bottom
            )
            
            // Enhanced Compose form
            ScrollView {
                VStack(spacing: 20) {
                    // To Field
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Text("To")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        TextField("Recipient email address", text: $viewModel.recipient)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.appCard)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.appBorder, lineWidth: 1.5)
                                    )
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Subject Field
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "text.bubble.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Text("Subject")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        TextField("Email subject", text: $viewModel.subject)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.appCard)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.appBorder, lineWidth: 1.5)
                                    )
                            )
                    }
                    .padding(.horizontal, 20)
                    
                    // Body Field
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Text("Message")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        TextEditor(text: $viewModel.body)
                            .frame(minHeight: 250)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.appCard)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.appBorder, lineWidth: 1.5)
                                    )
                            )
                    }
                    .padding(.horizontal, 20)
                    
                    // Verification Hash
                    if !viewModel.emailHash.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.appPrimary)
                                Text("Cryptographic Verification")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("SHA256 Hash:")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                
                                HStack {
                                    Text(viewModel.emailHash)
                                        .font(.system(size: 11, design: .monospaced))
                                        .textSelection(.enabled)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Button(action: {
                                        PlatformPasteboard.copy(viewModel.emailHash)
                                    }) {
                                        Image(systemName: "doc.on.doc")
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.appPrimary.opacity(0.05), Color.appSecondary.opacity(0.02)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.appPrimary.opacity(0.2), lineWidth: 1.5)
                                    )
                            )
                        }
                        .padding(.horizontal, 20)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.bottom, 20)
            }
            .background(Color.appBackground)
            
            // Preview
            if viewModel.showPreview {
                Divider()
                ScrollView {
                    HTMLPreviewView(html: viewModel.generatedHTML ?? "")
                        .frame(minHeight: 300)
                }
            }
        }
        .sheet(isPresented: $showStampPicker) {
            StampImagePickerView(selectedImage: $viewModel.stampImage)
        }
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsView(viewModel: viewModel)
        }
        .onChangeCompat(of: viewModel.subject) {
            viewModel.updateHash()
        }
        .onChangeCompat(of: viewModel.body) {
            viewModel.updateHash()
        }
        .onReceive(NotificationCenter.default.publisher(for: .newEmail)) { _ in
            viewModel.composeNewEmail()
        }
    }
}

struct EmailDetailView: View {
    let email: EmailItem
    @ObservedObject var viewModel: EmailComposeViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Enhanced Email header
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(email.subject)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 16) {
                                HStack(spacing: 6) {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                    Text("To: \(email.recipient)")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack(spacing: 6) {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                    Text(email.date, style: .date)
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                viewModel.selectedEmail = nil
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.secondary.opacity(0.6))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.appCard)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                )
                
                // Email content
                HTMLPreviewView(html: email.htmlContent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.appCard)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
            }
            .padding(20)
        }
        .background(Color.appBackground)
    }
}

