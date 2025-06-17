//
//  ImageCacheService.swift
//  CosmicDaily
//
//  Created by emre argana on 17.06.2025.
//

import Foundation

// Image Cache Service with Disk Storage Support
class ImageCacheService {
    static let shared = ImageCacheService()
    private let cache = NSCache<NSString, NSData>()
    private let fileManager = FileManager.default
    private let documentsDirectory: URL?
    private let cacheQueue = DispatchQueue(label: "com.cosmicdaily.imagecache", attributes: .concurrent)
    
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
        cache.setObject(data as NSData, forKey: key as NSString, cost: data.count)
        
        // Save to disk asynchronously
        cacheQueue.async(flags: .barrier) {
            if let fileURL = self.fileURL(for: key) {
                try? data.write(to: fileURL)
            }
        }
    }
    
    func loadImage(forKey key: String) -> Data? {
        // First check memory cache
        if let data = cache.object(forKey: key as NSString) as Data? {
            return data
        }
        
        // Then check disk
        var diskData: Data?
        cacheQueue.sync {
            if let fileURL = fileURL(for: key) {
                diskData = try? Data(contentsOf: fileURL)
            }
        }
        
        if let data = diskData {
            // Add back to memory cache
            cache.setObject(data as NSData, forKey: key as NSString, cost: data.count)
            return data
        }
        
        return nil
    }
    
    func clearCache() {
        // Clear memory cache
        cache.removeAllObjects()
        
        // Clear disk cache
        cacheQueue.async(flags: .barrier) {
            guard let documentsDirectory = self.documentsDirectory else { return }
            let cacheDirectory = documentsDirectory.appendingPathComponent("CachedImages")
            
            // Remove all files in cache directory
            if let files = try? self.fileManager.contentsOfDirectory(at: cacheDirectory,
                                                                includingPropertiesForKeys: nil) {
                for file in files {
                    try? self.fileManager.removeItem(at: file)
                }
                print("Image cache cleared - removed \(files.count) files")
            }
        }
    }
}
