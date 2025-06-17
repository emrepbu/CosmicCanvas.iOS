//
//  ApodService.swift
//  CosmicCanvas
//
//  Created by emre argana on 16.06.2025.
//

import Foundation
import SwiftUI

class APODService {
    @AppStorage("NASA_API_KEY") private var apiKey: String = "DEMO_KEY"
    private let baseURL = "https://api.nasa.gov/planetary/apod"
    private let cache = APODCacheService.shared
    
    func fetchAPODs(count: Int = 7) async throws -> [APOD] {
        guard let url = URL(string: "\(baseURL)?api_key=\(apiKey)&count=\(count)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let apods = try JSONDecoder().decode([APOD].self, from: data)
        return apods.sorted { $0.date > $1.date }
    }
    
    func fetchTodayAPOD() async throws -> APOD {
        // Check cache first
        if let cachedAPOD = cache.loadFromCache() {
            print("Loaded APOD from cache")
            return cachedAPOD
        }
        
        // If not in cache or expired, fetch from API
        guard let url = URL(string: "\(baseURL)?api_key=\(apiKey)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let apod = try JSONDecoder().decode(APOD.self, from: data)
        
        // Save to cache
        cache.saveToCache(apod)
        print("Fetched fresh APOD and saved to cache")
        
        return apod
    }
}
