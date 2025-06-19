//
//  ImageCacheService.swift
//  CosmicDaily
//
//  Created by emre argana on 17.06.2025.
//
//  Görüntü önbellekleme servisi
//  Disk depolama desteği ile birlikte hem bellek hem de disk önbelleği sağlar

import Foundation

/// Disk depolama destekli görüntü önbellekleme servisi
class ImageCacheService {
    /// Paylaşılan tekil örnek
    static let shared = ImageCacheService()
    
    /// Bellek önbelleği
    private let cache = NSCache<NSString, NSData>()
    
    /// Dosya yöneticisi
    private let fileManager = FileManager.default
    
    /// Dokümanlar dizini
    private let documentsDirectory: URL?
    
    /// Önbellek işlemlerini yönetmek için sıra
    private let cacheQueue = DispatchQueue(label: "com.cosmicdaily.imagecache", attributes: .concurrent)
    
    private init() {
        // Bellekte maksimum 50 görüntü
        cache.countLimit = 50
        // Maksimum 100 MB bellek kullanımı
        cache.totalCostLimit = 100 * 1024 * 1024
        
        // Dokümanlar dizinini al
        documentsDirectory = fileManager.urls(for: .documentDirectory,
                                              in: .userDomainMask).first
        createCacheDirectory()
    }
    
    /// Önbellek dizinini oluştur
    private func createCacheDirectory() {
        guard let documentsDirectory = documentsDirectory else { return }
        let cacheDirectory = documentsDirectory.appendingPathComponent("CachedImages")
        
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory,
                                             withIntermediateDirectories: true,
                                             attributes: nil)
        }
    }
    
    /// Verilen anahtar için dosya URL'ini oluştur
    private func fileURL(for key: String) -> URL? {
        guard let documentsDirectory = documentsDirectory else { return nil }
        // URL'den güvenli dosya adı oluştur
        let safeFileName = key.replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            .replacingOccurrences(of: ".", with: "_")
        return documentsDirectory
            .appendingPathComponent("CachedImages")
            .appendingPathComponent("\(safeFileName).jpg")
    }
    
    /// Görüntü verisini önbelleğe kaydet
    func saveImage(data: Data, forKey key: String) {
        // Bellek önbelleğine kaydet
        cache.setObject(data as NSData, forKey: key as NSString, cost: data.count)
        
        // Asenkron olarak diske kaydet
        cacheQueue.async(flags: .barrier) {
            if let fileURL = self.fileURL(for: key) {
                try? data.write(to: fileURL)
            }
        }
    }
    
    /// Önbellekten görüntü verisini yükle
    func loadImage(forKey key: String) -> Data? {
        // Önce bellek önbelleğini kontrol et
        if let data = cache.object(forKey: key as NSString) as Data? {
            return data
        }
        
        // Sonra diski kontrol et
        var diskData: Data?
        cacheQueue.sync {
            if let fileURL = fileURL(for: key) {
                diskData = try? Data(contentsOf: fileURL)
            }
        }
        
        if let data = diskData {
            // Bellek önbelleğine geri ekle
            cache.setObject(data as NSData, forKey: key as NSString, cost: data.count)
            return data
        }
        
        return nil
    }
    
    /// Tüm önbelleği temizle
    func clearCache() {
        // Bellek önbelleğini temizle
        cache.removeAllObjects()
        
        // Disk önbelleğini temizle
        cacheQueue.async(flags: .barrier) {
            guard let documentsDirectory = self.documentsDirectory else { return }
            let cacheDirectory = documentsDirectory.appendingPathComponent("CachedImages")
            
            // Önbellek dizinindeki tüm dosyaları kaldır
            if let files = try? self.fileManager.contentsOfDirectory(at: cacheDirectory,
                                                                includingPropertiesForKeys: nil) {
                for file in files {
                    try? self.fileManager.removeItem(at: file)
                }
                print("Görüntü önbelleği temizlendi - \(files.count) dosya kaldırıldı")
            }
        }
    }
}
