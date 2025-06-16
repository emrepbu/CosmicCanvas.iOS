//
//  ApodService.swift
//  CosmicCanvas
//
//  Created by emre argana on 16.06.2025.
//

import Foundation

class APODService {
    private let apiKey = "DEMO_KEY"
    private let baseURL = "https://api.nasa.gov/planetary/apod"
    
    func fetchAPODs(count: Int = 7) async throws -> [APOD] {
        guard let url = URL(string: "\(baseURL)?api_key=\(apiKey)&count=\(count)") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        let apods = try JSONDecoder().decode([APOD].self, from: data)
        return apods.sorted { $0.date > $1.date }
    }
}
