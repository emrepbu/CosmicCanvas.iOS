//
//  APODListViewModel.swift
//  CosmicDaily
//
//  Created by emre argana on 16.06.2025.
//

import Foundation
import UIKit
import SwiftUI

@MainActor
class APODViewModel: ObservableObject {
    @Published var apod: APOD?
    @Published var isLoading = false
    @Published var error: String?
    
    private let service = APODService()
    private let cache = APODCacheService.shared
    private let imageCache = ImageCacheService.shared
    
    func fetchAPOD(forceRefresh: Bool = false) async {
        // For initial load, show loading state
        if apod == nil && !forceRefresh {
            isLoading = true
        }
        
        // Try to load from cache first
        if !forceRefresh {
            if let cachedAPOD = await cache.loadFromCacheAsync() {
                // Update UI immediately with cached data
                await MainActor.run {
                    withAnimation(.easeIn(duration: 0.2)) {
                        self.apod = cachedAPOD
                        self.isLoading = false
                    }
                }
                print("Loaded APOD from cache")
                
                // Check if we should refresh in background
                if !cache.isCacheValid() {
                    // Refresh in background without showing loading
                    await fetchFromNetwork()
                }
                return
            }
        }
        
        // If no cache or force refresh, fetch from network
        if forceRefresh {
            isLoading = true
        }
        error = nil
        await fetchFromNetwork()
        isLoading = false
    }
    
    private func fetchFromNetwork() async {
        do {
            let fetchedAPOD = try await service.fetchTodayAPOD()
            
            // Animate the transition if updating existing content
            if self.apod != nil {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.apod = fetchedAPOD
                }
            } else {
                self.apod = fetchedAPOD
            }
            
            // Preload image to cache
            if fetchedAPOD.mediaType == "image" {
                await preloadImage(url: fetchedAPOD.hdurl ?? fetchedAPOD.url)
            }
        } catch {
            self.error = "Veri alınamadı: \(error.localizedDescription)"
            
            // If network fails, try to show cached data even if expired
            if let cachedAPOD = await cache.loadFromCacheAsync() {
                self.apod = cachedAPOD
                self.error = "Çevrimdışı mod: Önbellek verisi gösteriliyor"
            }
        }
    }
    
    private func preloadImage(url: String) async {
        guard let imageURL = URL(string: url) else { return }
        
        // Check if already in cache
        if imageCache.loadImage(forKey: url) != nil {
            print("Image already cached: \(url)")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: imageURL)
            imageCache.saveImage(data: data, forKey: url)
            print("Image preloaded to cache: \(url)")
        } catch {
            print("Failed to preload image: \(error)")
        }
    }
    
    func clearCache() {
        cache.clearCache()
        imageCache.clearCache()
        print("All caches cleared")
    }
}
