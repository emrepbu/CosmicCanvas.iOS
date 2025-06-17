//
//  APODCacheService.swift
//  CosmicCanvas
//
//  Created by emre argana on 17.06.2025.
//

import Foundation

class APODCacheService {
    static let shared = APODCacheService()
    private let cacheKey = "CachedAPOD"
    private let cacheTimeKey = "CachedAPODTime"
    private let cacheValidityDuration: TimeInterval = 3600 // 1 hour
    private let memoryCache = NSCache<NSString, CacheItem>()
    
    private init() {
        memoryCache.countLimit = 10
    }
    
    private class CacheItem: NSObject {
        let apod: APOD
        let timestamp: Date
        
        init(apod: APOD, timestamp: Date) {
            self.apod = apod
            self.timestamp = timestamp
        }
    }
    
    // Save APOD to cache
    func saveToCache(_ apod: APOD) {
        Task.detached(priority: .background) {
            do {
                let encoder = JSONEncoder()
                let encoded = try encoder.encode(apod)
                UserDefaults.standard.set(encoded, forKey: self.cacheKey)
                UserDefaults.standard.set(Date(), forKey: self.cacheTimeKey)
                
                // Also save to memory cache
                let cacheItem = CacheItem(apod: apod, timestamp: Date())
                self.memoryCache.setObject(cacheItem, forKey: self.cacheKey as NSString)
            } catch {
                print("Failed to cache APOD: \(error)")
            }
        }
    }
    
    // Load APOD from cache - Optimized async version
    func loadFromCacheAsync() async -> APOD? {
        // First check memory cache (super fast)
        if let cacheItem = memoryCache.object(forKey: cacheKey as NSString) {
            if Date().timeIntervalSince(cacheItem.timestamp) <= cacheValidityDuration {
                return cacheItem.apod
            } else {
                memoryCache.removeObject(forKey: cacheKey as NSString)
            }
        }
        
        // Then check disk cache asynchronously
        return await withCheckedContinuation { continuation in
            Task.detached(priority: .userInitiated) {
                guard let cachedData = UserDefaults.standard.data(forKey: self.cacheKey),
                      let cacheTime = UserDefaults.standard.object(forKey: self.cacheTimeKey) as? Date else {
                    continuation.resume(returning: nil)
                    return
                }
                
                // Check if cache is still valid
                if Date().timeIntervalSince(cacheTime) > self.cacheValidityDuration {
                    // Clear expired cache
                    Task { @MainActor in
                        self.clearCache()
                    }
                    continuation.resume(returning: nil)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let apod = try decoder.decode(APOD.self, from: cachedData)
                    
                    // Save to memory cache for next time
                    let cacheItem = CacheItem(apod: apod, timestamp: cacheTime)
                    self.memoryCache.setObject(cacheItem, forKey: self.cacheKey as NSString)
                    
                    continuation.resume(returning: apod)
                } catch {
                    print("Failed to decode cached APOD: \(error)")
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    // Clear cache
    func clearCache() {
        // Clear memory cache
        memoryCache.removeObject(forKey: cacheKey as NSString)
        
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: cacheKey)
        UserDefaults.standard.removeObject(forKey: cacheTimeKey)
        
        print("APOD cache cleared")
    }
    
    // Check if cache is valid
    func isCacheValid() -> Bool {
        guard let cacheTime = UserDefaults.standard.object(forKey: cacheTimeKey) as? Date else {
            return false
        }
        return Date().timeIntervalSince(cacheTime) <= cacheValidityDuration
    }
}
