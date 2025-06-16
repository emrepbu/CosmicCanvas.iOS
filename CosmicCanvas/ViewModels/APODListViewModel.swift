//
//  APODListViewModel.swift
//  CosmicCanvas
//
//  Created by emre argana on 16.06.2025.
//

import Foundation

@MainActor
class APODListViewModel: ObservableObject {
    @Published var apods: [APOD] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let service = APODService()
    
    func fetchAPODs() async {
        isLoading = true
        errorMessage = nil
        
        do {
            apods = try await service.fetchAPODs()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
