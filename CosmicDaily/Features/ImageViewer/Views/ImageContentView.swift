//
//  ImageContentView.swift
//  CosmicDaily
//
//  Created by emre argana on 17.06.2025.
//
//  Görüntü içerik görünümü
//  Ana ekranda görüntüleri gösterir ve tam ekran görüntüleme için etkileşim sağlar

import SwiftUI

struct ImageContentView: View {
    let imageURL: String
    @Binding var showFullScreen: Bool
    @Binding var imageLoaded: Bool
    
    var body: some View {
        VStack {
            if let url = URL(string: imageURL) {
                CachedAsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 10)
                        .onTapGesture {
                            print("Görüntüye dokunuldu - URL: \(imageURL)")
                            showFullScreen = true
                        }
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                imageLoaded = true
                            }
                        }
                        .scaleEffect(imageLoaded ? 1 : 0.9)
                        .opacity(imageLoaded ? 1 : 0)
                } placeholder: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 300)
                        
                        ProgressView()
                            .scaleEffect(1.5)
                    }
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    Text("Invalid image URL")
                        .foregroundColor(.secondary)
                }
                .frame(height: 300)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.orange.opacity(0.2))
                )
            }
            
            if imageLoaded {
                HStack {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 14))
                    Text("Tap to view full screen & zoom")
                        .font(.system(size: 14))
                }
                .foregroundColor(.secondary)
                .padding(.top, 8)
            }
        }
    }
}
