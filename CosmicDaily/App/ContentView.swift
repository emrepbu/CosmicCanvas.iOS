//
//  ContentView.swift
//  CosmicDaily
//
//  Created by emre argana on 10.06.2025.
//
//  Ana içerik görünümü - NASA'nın günlük astronomik görüntülerini gösterir

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = APODViewModel()
    @State private var showFullScreen = false
    @State private var showingSettings = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Group {
            
            NavigationView {
                ZStack {
                    // Arka plan gradyanı
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
                .navigationTitle("Cosmic Daily")
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
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .task {
            await viewModel.fetchAPOD()
        }
        .sheet(isPresented: $showFullScreen) {
            if let apod = viewModel.apod, apod.mediaType == "image" {
                let imageURL = apod.hdurl ?? apod.url
                FullScreenImageView(imageURL: imageURL, isPresented: $showFullScreen)
                    .presentationBackground(.black)
                    .presentationCornerRadius(0)
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
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
            
            if viewModel.isLoading && viewModel.apod == nil {
                LoadingView()
            } else if let apod = viewModel.apod {
                if apod.mediaType == "image" {
                    let imageURL = apod.hdurl ?? apod.url
                    ImageDetailView(
                        imageURL: imageURL,
                        showFullScreen: $showFullScreen
                    )
                } else if apod.mediaType == "video", let videoURL = URL(string: apod.url) {
                    VideoContentView(videoURL: videoURL)
                        .padding()
                } else {
                    UnsupportedMediaView()
                        .padding()
                }
            } else if let error = viewModel.error {
                ErrorView(error: error) {
                    Task {
                        await viewModel.fetchAPOD()
                    }
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
    }
    
    func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMMM d, yyyy"
        outputFormatter.locale = Locale(identifier: "en_US")
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }
}

/// Görsel detay view'ı - yakınlaştırma ve kaydırma özellikleriyle
/// Tam ekran görüntüleme için kullanılır
struct ImageDetailView: View {
    let imageURL: String
    @Binding var showFullScreen: Bool
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let url = URL(string: imageURL) {
                    CachedAsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        let delta = value / lastScale
                                        lastScale = value
                                        scale *= delta
                                    }
                                    .onEnded { _ in
                                        lastScale = 1.0
                                        withAnimation(.spring()) {
                                            scale = min(max(scale, 1), 5)
                                        }
                                    }
                            )
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            )
                            .onTapGesture(count: 2) {
                                withAnimation(.spring()) {
                                    if scale > 1 {
                                        scale = 1
                                        offset = .zero
                                        lastOffset = .zero
                                    } else {
                                        scale = 2
                                    }
                                }
                            }
                    } placeholder: {
                        ProgressView()
                            .scaleEffect(1.5)
                    }
                }
            }
        }
        .clipped()
    }
}

#Preview {
    ContentView()
}
