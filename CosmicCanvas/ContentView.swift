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
    @State private var selectedImage: String = ""
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
                        if viewModel.isLoading {
                            LoadingView()
                        } else if let apod = viewModel.apod {
                            APODContentView(
                                apod: apod,
                                showFullScreen: $showFullScreen,
                                selectedImage: $selectedImage
                            )
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
        .sheet(isPresented: $showFullScreen) {
            FullScreenImageView(imageURL: selectedImage, isPresented: $showFullScreen)
                .edgesIgnoringSafeArea(.all)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}
