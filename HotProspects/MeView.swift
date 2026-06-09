//
//  MeView.swift
//  HotProspects
//
//  Created by sovanmakara on 8/6/26.
//

import CoreImage.CIFilterBuiltins
import SwiftUI

struct MeView: View {
    @AppStorage("name") private var name = "Anonymous"
    @AppStorage("emailAddress") private var emailAddress = "Anonymous@HotProspects.com"
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    @State private var qrCode = UIImage()
    
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)
        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    func updateCode() {
        qrCode = generateQRCode(from: "\(name)\n\(emailAddress)")
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    
                    // MARK: - Profile Fields
                    VStack(spacing: 12) {
                        profileField(
                            icon: "person.fill",
                            placeholder: "Name",
                            value: $name,
                            contentType: .name
                        )
                        profileField(
                            icon: "envelope.fill",
                            placeholder: "Email address",
                            value: $emailAddress,
                            contentType: .emailAddress
                        )
                    }
                    .padding(.horizontal)
                    
                    // MARK: - QR Card
                    VStack(spacing: 20) {
                        Text("Your QR Code")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 6)
                            
                            VStack(spacing: 20) {
                                Image(uiImage: qrCode)
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                VStack(spacing: 4) {
                                    Text(name)
                                        .font(.headline)
                                    Text(emailAddress)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                
                                ShareLink(
                                    item: Image(uiImage: qrCode),
                                    preview: SharePreview("My QR Code", image: Image(uiImage: qrCode))
                                ) {
                                    Label("Share QR Code", systemImage: "square.and.arrow.up")
                                        .font(.subheadline.weight(.semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(.blue)
                                        .foregroundStyle(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                            }
                            .padding(24)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.large)
            .onAppear(perform: updateCode)
            .onChange(of: name, updateCode)
            .onChange(of: emailAddress, updateCode)
        }
    }
    
    // MARK: - Profile Field Component
    @ViewBuilder
    func profileField(
        icon: String,
        placeholder: String,
        value: Binding<String>,
        contentType: UITextContentType
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 20)
            
            TextField(placeholder, text: value)
                .textContentType(contentType)
                .font(.body)
                .keyboardType(contentType == .emailAddress ? .emailAddress : .default)
                .autocorrectionDisabled(contentType == .emailAddress)
                .textInputAutocapitalization(contentType == .emailAddress ? .never : .words)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    MeView()
}
