import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = EmailComposeViewModel()
    @State private var hoveredEmailID: UUID?
    
    var body: some View {
        #if os(macOS)
        HSplitView {
            emailListSidebar
            emailContentArea
        }
        #else
        NavigationView {
            emailListSidebar
            emailContentArea
        }
        #endif
    }
    
    private var emailListSidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
                // Professional Header with gradient
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [Color.appPrimary, Color.appSecondary]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    HStack {
                        HStack(spacing: 12) {
                            Image(systemName: "seal.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Email Stamp")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Text("Cryptographic Email")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.composeNewEmail()
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                Text("New")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.white.opacity(0.25))
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.white.opacity(0.1))
                                            .blur(radius: 10)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .help("New Email")
                    }
                    .padding()
                }
                .frame(height: 80)
                
                Divider()
                
                // Email list
                if viewModel.emails.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundColor(.gray.opacity(0.4))
                        Text("No emails yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Click 'New' to compose your first email")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(viewModel.emails) { email in
                                EmailRowView(
                                    email: email,
                                    isSelected: viewModel.selectedEmail?.id == email.id,
                                    isHovered: hoveredEmailID == email.id
                                )
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3)) {
                                        viewModel.selectEmail(email)
                                    }
                                }
                                .onHover { hovering in
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        hoveredEmailID = hovering ? email.id : nil
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            #if os(macOS)
            .frame(minWidth: 280, maxWidth: 320)
            #else
            .frame(maxWidth: .infinity)
            #endif
            .background(Color.appBackground)
    }
    
    private var emailContentArea: some View {
        Group {
            if let selectedEmail = viewModel.selectedEmail {
                EmailDetailView(email: selectedEmail, viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            } else {
                EmailComposeView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }
        }
        .background(Color.appBackground)
        .onReceive(NotificationCenter.default.publisher(for: .newEmail)) { _ in
            withAnimation {
                viewModel.composeNewEmail()
            }
        }
    }
}

struct EmailRowView: View {
    let email: EmailItem
    let isSelected: Bool
    let isHovered: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.appPrimary.opacity(0.2), Color.appSecondary.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: "envelope.fill")
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? Color.appPrimary : .gray)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(email.subject)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? Color.appPrimary : .primary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                    Text(email.recipient)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary.opacity(0.7))
                    Text(email.date, style: .relative)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary.opacity(0.7))
                }
            }
            
            Spacer()
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.appPrimary.opacity(0.1) : Color.appCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSelected ? Color.appPrimary.opacity(0.3) : Color.appBorder,
                            lineWidth: isSelected ? 2 : 1
                        )
                )
        )
        .shadow(
            color: isHovered || isSelected ? Color.black.opacity(0.08) : Color.black.opacity(0.03),
            radius: isHovered || isSelected ? 8 : 4,
            x: 0,
            y: isHovered || isSelected ? 4 : 2
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
    }
}
