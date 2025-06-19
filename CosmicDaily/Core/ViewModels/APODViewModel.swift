//
//  APODListViewModel.swift
//  CosmicDaily
//
//  Created by emre argana on 16.06.2025.
//
//  APOD ViewModel
//  APOD verilerini yönetir ve UI güncellemelerini koordine eder

import Foundation
import UIKit
import SwiftUI

@MainActor
class APODViewModel: ObservableObject {
    /// Mevcut APOD verisi
    @Published var apod: APOD?
    
    /// Yükleme durumu
    @Published var isLoading = false
    
    /// Hata mesajı
    @Published var error: String?
    
    /// APOD servisi
    private let service = APODService()
    
    /// Önbellek servisi
    private let cache = APODCacheService.shared
    
    /// Görüntü önbellek servisi
    private let imageCache = ImageCacheService.shared
    
    /// APOD verisini getir
    /// - Parameter forceRefresh: Önbelleği atlayarak yeni veri getir
    func fetchAPOD(forceRefresh: Bool = false) async {
        // İlk yükleme için yükleme durumunu göster
        if apod == nil && !forceRefresh {
            isLoading = true
        }
        
        // Önce önbellekten yüklemeyi dene
        if !forceRefresh {
            if let cachedAPOD = await cache.loadFromCacheAsync() {
                // Önbellekteki veriyle UI'ı hemen güncelle
                await MainActor.run {
                    withAnimation(.easeIn(duration: 0.2)) {
                        self.apod = cachedAPOD
                        self.isLoading = false
                    }
                }
                print("APOD önbellekten yüklendi")
                
                // Arka planda yenileme gerekip gerekmediğini kontrol et
                if !cache.isCacheValid() {
                    // Yükleme göstermeden arka planda yenile
                    await fetchFromNetwork()
                }
                return
            }
        }
        
        // Önbellek yoksa veya zorla yenileme istenmişse, ağdan getir
        if forceRefresh {
            isLoading = true
        }
        error = nil
        await fetchFromNetwork()
        isLoading = false
    }
    
    /// Ağdan veri getir
    private func fetchFromNetwork() async {
        do {
            let fetchedAPOD = try await service.fetchTodayAPOD()
            
            // Mevcut içerik güncelleniyorsa geçişi animasyonla yap
            if self.apod != nil {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.apod = fetchedAPOD
                }
            } else {
                self.apod = fetchedAPOD
            }
            
            // Görüntüyü önbelleğe yükle
            if fetchedAPOD.mediaType == "image" {
                await preloadImage(url: fetchedAPOD.hdurl ?? fetchedAPOD.url)
            }
        } catch {
            self.error = "Veri alınamadı: \(error.localizedDescription)"
            
            // Ağ başarısız olursa, süresi dolmuş olsa bile önbellekteki veriyi göster
            if let cachedAPOD = await cache.loadFromCacheAsync() {
                self.apod = cachedAPOD
                self.error = "Çevrimdışı mod: Önbellek verisi gösteriliyor"
            }
        }
    }
    
    /// Görüntüyü önyükle
    /// - Parameter url: Görüntü URL'i
    private func preloadImage(url: String) async {
        guard let imageURL = URL(string: url) else { return }
        
        // Önbellekte olup olmadığını kontrol et
        if imageCache.loadImage(forKey: url) != nil {
            print("Görüntü zaten önbellekte: \(url)")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: imageURL)
            imageCache.saveImage(data: data, forKey: url)
            print("Görüntü önbelleğe yüklendi: \(url)")
        } catch {
            print("Görüntü önyüklenemedi: \(error)")
        }
    }
    
    /// Tüm önbellekleri temizle
    func clearCache() {
        cache.clearCache()
        imageCache.clearCache()
        print("Tüm önbellekler temizlendi")
    }
}
