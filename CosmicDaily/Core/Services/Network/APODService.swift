//
//  ApodService.swift
//  CosmicDaily
//
//  Created by emre argana on 16.06.2025.
//
//  APOD API servisi
//  NASA'nın APOD API'si ile iletişimi yönetir

import Foundation
import SwiftUI

class APODService {
    /// NASA API anahtarı (kullanıcı ayarlarından yönetilir)
    @AppStorage("NASA_API_KEY") private var apiKey: String = "DEMO_KEY"
    
    /// APOD API temel URL'i
    private let baseURL = "https://api.nasa.gov/planetary/apod"
    
    /// Önbellek servisi
    private let cache = APODCacheService.shared
    
    /// Birden fazla APOD verisini getir
    /// - Parameter count: Getirilecek APOD sayısı (varsayılan: 7)
    /// - Returns: APOD dizisi (tarihe göre sıralı)
    func fetchAPODs(count: Int = 7) async throws -> [APOD] {
        guard let url = URL(string: "\(baseURL)?api_key=\(apiKey)&count=\(count)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let apods = try JSONDecoder().decode([APOD].self, from: data)
        return apods.sorted { $0.date > $1.date }
    }
    
    /// Bugünün APOD verisini getir
    /// - Returns: Bugünkü APOD verisi
    func fetchTodayAPOD() async throws -> APOD {
        // Önce önbelleği kontrol et
        if let cachedAPOD = await cache.loadFromCacheAsync() {
            print("APOD önbellekten yüklendi")
            return cachedAPOD
        }
        
        // Önbellekte yoksa veya süresi dolmuşsa, API'den getir
        guard let url = URL(string: "\(baseURL)?api_key=\(apiKey)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let apod = try JSONDecoder().decode(APOD.self, from: data)
        
        // Önbelleğe kaydet
        cache.saveToCache(apod)
        print("Yeni APOD getirildi ve önbelleğe kaydedildi")
        
        return apod
    }
}
