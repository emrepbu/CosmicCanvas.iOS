//
//  HistoryViewModel.swift
//  CosmicCanvas
//
//  Created by emre argana on 11.06.2025.
//

import Foundation

final class HistoryViewModel: ObservableObject {
    @Published var apods: [Apod] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchLastNDays(_ n: Int) {
        guard let apiKey = UserDefaults.standard.string(forKey: "apiKey"), !apiKey.isEmpty else {
            errorMessage = "API anahtarı girilmedi."
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        let today = Date()
        isLoading = true
        let group = DispatchGroup()
        var results: [Apod] = []
        
        for i in 1...n {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let dateString = formatter.string(from: date)
                group.enter()
                ApodService.shared.fetchApod(for: dateString, apiKey: apiKey) { result in
                    if case .success(let apod) = result {
                        results.append(apod)
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            self.apods = results.sorted(by: { $0.date > $1.date })
            self.isLoading = false
        }
    }
}

