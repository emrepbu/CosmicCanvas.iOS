//
//  ApodService.swift
//  CosmicCanvas
//
//  Created by emre argana on 11.06.2025.
//

import Foundation

final class ApodService {
    static let shared = ApodService()
    
    private init() {}
    
    func fetchApod(for date: String?, apiKey: String, completion: @escaping (Result<Apod, Error>) -> Void) {
        var urlString = "https://api.nasa.gov/planetary/apod?api_key=\(apiKey)"
        if let date = date {
            urlString += "&date=\(date)"
        }
        
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let cacheKey = date ?? "today"
        if let cacheData = CacheManager.shared.load(filename: "apod_\(cacheKey).json"),
           let apod = try? JSONDecoder().decode(Apod.self, from: cacheData) {
            completion(.success(apod))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            do {
                let apod = try JSONDecoder().decode(Apod.self, from: data)
                CacheManager.shared.save(data: data, filename: "apod_\(cacheKey).son")
                completion(.success(apod))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
