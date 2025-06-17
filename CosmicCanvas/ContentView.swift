//
//  ContentView.swift
//  CosmicCanvas
//
//  Created by emre argana on 10.06.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = APODViewModel()
    @State private var showFullScreen = false
    @State private var showingSettings = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(colorScheme == .dark ? .black : .blue.opacity(0.1)),
                        Color(colorScheme == .dark ? .blue.opacity(0.2) : .white)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        if viewModel.isLoading && viewModel.apod == nil {
                            // Show skeleton loader for initial load
                            SkeletonLoadingView()
                        } else if let apod = viewModel.apod {
                            APODContentView(
                                apod: apod,
                                showFullScreen: $showFullScreen
                            )
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .scale(scale: 0.95)),
                                removal: .opacity
                            ))
                        } else if let error = viewModel.error {
                            ErrorView(error: error) {
                                Task {
                                    await viewModel.fetchAPOD()
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Cosmic Canvas")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .medium))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.fetchAPOD(forceRefresh: true)
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 18, weight: .medium))
                    }
                }
            }
        }
        .task {
            await viewModel.fetchAPOD()
        }
        .fullScreenCover(isPresented: $showFullScreen) {
            if let apod = viewModel.apod, apod.mediaType == "image" {
                let imageURL = apod.hdurl ?? apod.url
                FullScreenImageView(imageURL: imageURL, isPresented: $showFullScreen)
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

#Preview {
    ContentView()
}
