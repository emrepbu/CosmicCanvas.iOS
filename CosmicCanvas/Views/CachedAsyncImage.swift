//
//  CachedAsyncImage.swift
//  CosmicCanvas
//
//  Created by emre argana on 17.06.2025.
//

import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var hasAppeared = false
    
    private let imageCache = ImageCacheService.shared
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = image {
                content(Image(uiImage: image))
            } else if isLoading {
                placeholder()
            } else {
                // Failed to load
                VStack(spacing: 16) {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("Failed to load image")
                        .foregroundColor(.secondary)
                    
                    Button("Retry") {
                        isLoading = true
                        loadImage()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .onAppear {
            if !hasAppeared {
                hasAppeared = true
                loadImage()
            }
        }
    }
    
    private func loadImage() {
        guard let url = url else {
            isLoading = false
            return
        }
        
        let urlString = url.absoluteString
        
        // First check cache
        if let cachedData = imageCache.loadImage(forKey: urlString),
           let cachedImage = UIImage(data: cachedData) {
            self.image = cachedImage
            self.isLoading = false
            print("Loaded image from cache: \(urlString)")
            return
        }
        
        // If not in cache, download
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                if let downloadedImage = UIImage(data: data) {
                    // Save to cache
                    imageCache.saveImage(data: data, forKey: urlString)
                    print("Downloaded and cached image: \(urlString)")
                    
                    // Update UI on main thread
                    await MainActor.run {
                        withAnimation(.easeIn(duration: 0.3)) {
                            self.image = downloadedImage
                            self.isLoading = false
                        }
                    }
                } else {
                    await MainActor.run {
                        self.isLoading = false
                    }
                }
            } catch {
                print("Failed to download image: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}

// Convenience initializer for simple use cases
extension CachedAsyncImage where Placeholder == AnyView {
    init(url: URL?, @ViewBuilder content: @escaping (Image) -> Content) {
        self.init(url: url, content: content) {
            AnyView(
                ProgressView()
                    .scaleEffect(1.5)
            )
        }
    }
}
