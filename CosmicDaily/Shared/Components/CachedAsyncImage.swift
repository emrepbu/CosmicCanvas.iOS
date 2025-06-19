//
//  CachedAsyncImage.swift
//  CosmicDaily
//
//  Created by emre argana on 17.06.2025.
//
//  Önbellekli asenkron görüntü bileşeni
//  Görüntüleri asenkron olarak yükler ve önbelleğe alır

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
                // Yükleme başarısız
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
        
        // Önce önbelleği kontrol et
        if let cachedData = imageCache.loadImage(forKey: urlString),
           let cachedImage = UIImage(data: cachedData) {
            self.image = cachedImage
            self.isLoading = false
            print("Görüntü önbellekten yüklendi: \(urlString)")
            return
        }
        
        // Önbellekte yoksa, indir
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                if let downloadedImage = UIImage(data: data) {
                    // Önbelleğe kaydet
                    imageCache.saveImage(data: data, forKey: urlString)
                    print("Görüntü indirildi ve önbelleğe kaydedildi: \(urlString)")
                    
                    // UI'ı ana thread'de güncelle
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
                print("Görüntü indirilemedi: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}

/// Basit kullanım durumları için kolaylaştırılmış başlatıcı
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
