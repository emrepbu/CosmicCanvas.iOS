//
//  APODCacheService.swift
//  CosmicDaily
//
//  Created by emre argana on 17.06.2025.
//
//  APOD verilerini önbelleğe alma servisi
//  Performans için hem bellek hem de disk önbelleği kullanır

import Foundation

class APODCacheService {
    /// Paylaşılan tekil örnek
    static let shared = APODCacheService()
    
    /// Önbellek anahtarı
    private let cacheKey = "CachedAPOD"
    
    /// Önbellek zamanı anahtarı
    private let cacheTimeKey = "CachedAPODTime"
    
    /// Önbellek geçerlilik süresi (1 saat)
    private let cacheValidityDuration: TimeInterval = 3600
    
    /// Bellek önbelleği
    private let memoryCache = NSCache<NSString, CacheItem>()
    
    private init() {
        // Bellekte maksimum 10 öğe sakla
        memoryCache.countLimit = 10
    }
    
    /// Önbellek öğesi - APOD verisi ve zaman damgasını saklar
    private class CacheItem: NSObject {
        let apod: APOD
        let timestamp: Date
        
        init(apod: APOD, timestamp: Date) {
            self.apod = apod
            self.timestamp = timestamp
        }
    }
    
    /// APOD verisini önbelleğe kaydet
    func saveToCache(_ apod: APOD) {
        Task.detached(priority: .background) {
            do {
                let encoder = JSONEncoder()
                let encoded = try encoder.encode(apod)
                UserDefaults.standard.set(encoded, forKey: self.cacheKey)
                UserDefaults.standard.set(Date(), forKey: self.cacheTimeKey)
                
                // Aynı zamanda bellek önbelleğine de kaydet
                let cacheItem = CacheItem(apod: apod, timestamp: Date())
                self.memoryCache.setObject(cacheItem, forKey: self.cacheKey as NSString)
            } catch {
                print("APOD önbelleğe kaydedilemedi: \(error)")
            }
        }
    }
    
    /// Önbellekten APOD verisini yükle - Optimize edilmiş asenkron versiyon
    func loadFromCacheAsync() async -> APOD? {
        // Önce bellek önbelleğini kontrol et (çok hızlı)
        if let cacheItem = memoryCache.object(forKey: cacheKey as NSString) {
            if Date().timeIntervalSince(cacheItem.timestamp) <= cacheValidityDuration {
                return cacheItem.apod
            } else {
                memoryCache.removeObject(forKey: cacheKey as NSString)
            }
        }
        
        // Sonra disk önbelleğini asenkron olarak kontrol et
        return await withCheckedContinuation { continuation in
            Task.detached(priority: .userInitiated) {
                guard let cachedData = UserDefaults.standard.data(forKey: self.cacheKey),
                      let cacheTime = UserDefaults.standard.object(forKey: self.cacheTimeKey) as? Date else {
                    continuation.resume(returning: nil)
                    return
                }
                
                // Önbelleğin hala geçerli olup olmadığını kontrol et
                if Date().timeIntervalSince(cacheTime) > self.cacheValidityDuration {
                    // Süresi dolmuş önbelleği temizle
                    Task { @MainActor in
                        self.clearCache()
                    }
                    continuation.resume(returning: nil)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let apod = try decoder.decode(APOD.self, from: cachedData)
                    
                    // Bir sonraki kullanım için bellek önbelleğine kaydet
                    let cacheItem = CacheItem(apod: apod, timestamp: cacheTime)
                    self.memoryCache.setObject(cacheItem, forKey: self.cacheKey as NSString)
                    
                    continuation.resume(returning: apod)
                } catch {
                    print("Önbellekteki APOD çözülemedi: \(error)")
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    /// Önbelleği temizle
    func clearCache() {
        // Bellek önbelleğini temizle
        memoryCache.removeObject(forKey: cacheKey as NSString)
        
        // UserDefaults'u temizle
        UserDefaults.standard.removeObject(forKey: cacheKey)
        UserDefaults.standard.removeObject(forKey: cacheTimeKey)
        
        print("APOD önbelleği temizlendi")
    }
    
    /// Önbelleğin geçerli olup olmadığını kontrol et
    func isCacheValid() -> Bool {
        guard let cacheTime = UserDefaults.standard.object(forKey: cacheTimeKey) as? Date else {
            return false
        }
        return Date().timeIntervalSince(cacheTime) <= cacheValidityDuration
    }
}
