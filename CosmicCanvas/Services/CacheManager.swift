//
//  CacheManager.swift
//  CosmicCanvas
//
//  Created by emre argana on 11.06.2025.
//

import Foundation


final class CacheManager {
    static let shared = CacheManager()
    
    private init() {}
    
    private let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    
    func save(data: Data, filename: String) {
        let url = cacheDirectory.appendingPathComponent(filename)
        try? data.write(to: url)
    }
    
    func load(filename: String) -> Data? {
        let url = cacheDirectory.appendingPathComponent(filename)
        return try? Data(contentsOf: url)
    }
}
