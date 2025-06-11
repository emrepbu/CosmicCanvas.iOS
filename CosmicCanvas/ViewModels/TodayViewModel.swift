//
//  TodayViewModel.swift
//  CosmicCanvas
//
//  Created by emre argana on 11.06.2025.
//

import Foundation

final class TodayViewModel: ObservableObject {
    @Published var apod: Apod?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    func fetchToday() {
        guard let apiKey = UserDefaults.standard.string(forKey: "apiKey"),
              !apiKey.isEmpty else {
            errorMessage = "API anahtari bulunamadi."
            return
        }
        
        isLoading = true
        ApodService.shared.fetchApod(for: nil, apiKey: apiKey) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let apod):
                    self.apod = apod
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
