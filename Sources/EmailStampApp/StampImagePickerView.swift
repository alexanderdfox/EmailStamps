import SwiftUI

#if os(iOS)
import PhotosUI
import UIKit
#elseif os(macOS)
import AppKit
internal import UniformTypeIdentifiers
#endif

struct StampImagePickerView: View {
    @Binding var selectedImage: PlatformImage?
    @Environment(\.dismiss) var dismiss
    #if os(iOS)
    @State private var selectedPhoto: PhotosPickerItem?
    #endif
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select Stamp Image")
                .font(.title2)
                .fontWeight(.bold)
            
            if let image = selectedImage {
                #if os(iOS)
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .border(Color.gray, width: 1)
                #elseif os(macOS)
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .border(Color.gray, width: 1)
                #endif
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                    .frame(width: 200, height: 200)
                    .border(Color.gray, width: 1)
            }
            
            HStack(spacing: 15) {
                #if os(iOS)
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Text("Choose Image")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.appPrimary, Color.appSecondary]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10)
                }
                #elseif os(macOS)
                Button("Choose Image") {
                    selectImage()
                }
                .buttonStyle(.borderedProminent)
                #endif
                
                if selectedImage != nil {
                    Button("Remove") {
                        selectedImage = nil
                    }
                    .buttonStyle(.bordered)
                }
                
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        #if os(macOS)
        .frame(width: 400, height: 350)
        #else
        .frame(maxWidth: .infinity)
        #endif
        #if os(iOS)
        .onChange(of: selectedPhoto) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                }
            }
        }
        #endif
    }
    
    #if os(macOS)
    private func selectImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                selectedImage = NSImage(contentsOf: url)
            }
        }
    }
    #endif
}

