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
    
    // Load APOD from cache - Fast async version
    func loadFromCacheAsync() async -> APOD? {
        // First check memory cache
        if let cacheItem = memoryCache.object(forKey: cacheKey as NSString) {
            if Date().timeIntervalSince(cacheItem.timestamp) <= cacheValidityDuration {
                return cacheItem.apod
            } else {
                memoryCache.removeObject(forKey: cacheKey as NSString)
            }
        }
        
        // Then check disk cache
        return await Task.detached(priority: .userInitiated) {
            guard let cachedData = UserDefaults.standard.data(forKey: self.cacheKey),
                  let cacheTime = UserDefaults.standard.object(forKey: self.cacheTimeKey) as? Date else {
                return nil
            }
            
            // Check if cache is still valid
            if Date().timeIntervalSince(cacheTime) > self.cacheValidityDuration {
                await MainActor.run {
                    self.clearCache()
                }
                return nil
            }
            
            do {
                let decoder = JSONDecoder()
                let apod = try decoder.decode(APOD.self, from: cachedData)
                
                // Save to memory cache for next time
                let cacheItem = CacheItem(apod: apod, timestamp: cacheTime)
                self.memoryCache.setObject(cacheItem, forKey: self.cacheKey as NSString)
                
                return apod
            } catch {
                print("Failed to decode cached APOD: \(error)")
                return nil
            }
        }.value
    }
    
    // Load APOD from cache - Legacy sync version
    func loadFromCache() -> APOD? {
        // First check memory cache
        if let cacheItem = memoryCache.object(forKey: cacheKey as NSString) {
            if Date().timeIntervalSince(cacheItem.timestamp) <= cacheValidityDuration {
                return cacheItem.apod
            }
        }
        
        guard let cachedData = UserDefaults.standard.data(forKey: cacheKey),
              let cacheTime = UserDefaults.standard.object(forKey: cacheTimeKey) as? Date else {
            return nil
        }
        
        // Check if cache is still valid
        if Date().timeIntervalSince(cacheTime) > cacheValidityDuration {
            clearCache()
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let apod = try decoder.decode(APOD.self, from: cachedData)
            return apod
        } catch {
            print("Failed to decode cached APOD: \(error)")
            return nil
        }
    }
    
    // Clear cache
    func clearCache() {
        // Clear memory cache
        memoryCache.removeObject(forKey: cacheKey as NSString)
        
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: cacheKey)
        UserDefaults.standard.removeObject(forKey: cacheTimeKey)
        UserDefaults.standard.synchronize()
        
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

// Image Cache Service with Disk Storage Support
class ImageCacheService {
    static let shared = ImageCacheService()
    private let cache = NSCache<NSString, NSData>()
    private let fileManager = FileManager.default
    private let documentsDirectory: URL?
    
    private init() {
        cache.countLimit = 50 // Maximum 50 images in memory
        cache.totalCostLimit = 100 * 1024 * 1024 // 100 MB
        
        // Get documents directory
        documentsDirectory = fileManager.urls(for: .documentDirectory,
                                              in: .userDomainMask).first
        createCacheDirectory()
    }
    
    private func createCacheDirectory() {
        guard let documentsDirectory = documentsDirectory else { return }
        let cacheDirectory = documentsDirectory.appendingPathComponent("CachedImages")
        
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory,
                                             withIntermediateDirectories: true,
                                             attributes: nil)
        }
    }
    
    private func fileURL(for key: String) -> URL? {
        guard let documentsDirectory = documentsDirectory else { return nil }
        // Create safe filename from URL
        let safeFileName = key.replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            .replacingOccurrences(of: ".", with: "_")
        return documentsDirectory
            .appendingPathComponent("CachedImages")
            .appendingPathComponent("\(safeFileName).jpg")
    }
    
    func saveImage(data: Data, forKey key: String) {
        // Save to memory cache
        cache.setObject(data as NSData, forKey: key as NSString)
        
        // Save to disk
        if let fileURL = fileURL(for: key) {
            try? data.write(to: fileURL)
        }
    }
    
    func loadImage(forKey key: String) -> Data? {
        // First check memory cache
        if let data = cache.object(forKey: key as NSString) as Data? {
            return data
        }
        
        // Then check disk
        if let fileURL = fileURL(for: key),
           let data = try? Data(contentsOf: fileURL) {
            // Add back to memory cache
            cache.setObject(data as NSData, forKey: key as NSString)
            return data
        }
        
        return nil
    }
    
    func clearCache() {
        // Clear memory cache
        cache.removeAllObjects()
        
        // Clear disk cache
        guard let documentsDirectory = documentsDirectory else { return }
        let cacheDirectory = documentsDirectory.appendingPathComponent("CachedImages")
        
        // Remove all files in cache directory
        if let files = try? fileManager.contentsOfDirectory(at: cacheDirectory,
                                                            includingPropertiesForKeys: nil) {
            for file in files {
                try? fileManager.removeItem(at: file)
            }
            print("Image cache cleared - removed \(files.count) files")
        }
    }
}
