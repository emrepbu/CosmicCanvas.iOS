//
//  APODListView.swift
//  CosmicCanvas
//
//  Created by emre argana on 16.06.2025.
//

import SwiftUI

struct APODListView: View {
    @StateObject private var viewModel = APODListViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading && viewModel.apods.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    VStack {
                        Text("Error: \(error)")
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Try againg") {
                            Task {
                                await viewModel.fetchAPODs()
                            }
                        }
                    }
                } else {
                    List(viewModel.apods) { apod in
                        NavigationLink(destination: APODDetailView(apod: apod)) {
                            APODRowView(apod: apod)
                        }
                    }
                }
            }
        }
        .navigationTitle("NASA APOD")
        .task {
            if viewModel.apods.isEmpty {
                await viewModel.fetchAPODs()
            }
        }
        .refreshable {
            await viewModel.fetchAPODs()
        }
    }
}

#Preview {
    APODListView()
}
