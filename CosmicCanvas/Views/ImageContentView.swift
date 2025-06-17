//
//  ImageContentView.swift
//  CosmicCanvas
//
//  Created by emre argana on 17.06.2025.
//

import SwiftUI

struct ImageContentView: View {
    let imageURL: String
    @Binding var showFullScreen: Bool
    @Binding var selectedImage: String
    @Binding var imageLoaded: Bool
    
    var body: some View {
        if let url = URL(string: imageURL) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 300)
                        
                        ProgressView()
                            .scaleEffect(1.5)
                    }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 10)
                        .onTapGesture {
                            selectedImage = imageURL
                            showFullScreen = true
                        }
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                imageLoaded = true
                            }
                        }
                        .scaleEffect(imageLoaded ? 1 : 0.9)
                        .opacity(imageLoaded ? 1 : 0)
                case .failure(_):
                    VStack(spacing: 16) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Failed to load image")
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.2))
                    )
                @unknown default:
                    EmptyView()
                }
            }
            
            if imageLoaded {
                HStack {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 14))
                    Text("Tap to view full screen")
                        .font(.system(size: 14))
                }
                .foregroundColor(.secondary)
                .padding(.top, 8)
            }
        }
    }
}
