//
//  FullScreenImageView.swift
//  CosmicDaily
//
//  Created by emre argana on 17.06.2025.
//

import SwiftUI

struct FullScreenImageView: View {
    let imageURL: String
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var showControls = true
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if !imageURL.isEmpty {
                    if let url = URL(string: imageURL) {
                        CachedAsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(scale)
                                .offset(offset)
                                .gesture(magnificationGesture)
                                .gesture(dragGesture)
                                .onTapGesture(count: 2) {
                                    withAnimation(.spring()) {
                                        scale = scale > 1 ? 1 : 2
                                        offset = .zero
                                        lastOffset = .zero
                                    }
                                }
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        showControls.toggle()
                                    }
                                }
                        } placeholder: {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                        }
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.yellow)
                            Text("Invalid URL")
                                .foregroundColor(.white)
                            Text(imageURL)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        }
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "photo")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                        Text("No image URL provided")
                            .foregroundColor(.white)
                    }
                }
                
                // Control Overlay
                if showControls {
                    VStack {
                        Spacer()
                        
                        // Bottom Controls
                        HStack(spacing: 20) {
                            // Reset Button
                            Button(action: {
                                withAnimation(.spring()) {
                                    scale = 1.0
                                    offset = .zero
                                    lastOffset = .zero
                                    lastScale = 1.0
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.system(size: 20))
                                    Text("Reset")
                                        .font(.system(size: 12))
                                }
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.5))
                                )
                            }
                            .opacity(scale != 1.0 || offset != .zero ? 1 : 0.5)
                            .disabled(scale == 1.0 && offset == .zero)
                            
                            // Zoom Info
                            Text("\(Int(scale * 100))%")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.black.opacity(0.5))
                                )
                            
                            // Fit to Screen Button
                            Button(action: {
                                withAnimation(.spring()) {
                                    scale = 1.0
                                    offset = .zero
                                    lastOffset = .zero
                                    lastScale = 1.0
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                                        .font(.system(size: 20))
                                    Text("Fit")
                                        .font(.system(size: 12))
                                }
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.5))
                                )
                            }
                        }
                        .padding(.bottom, 50)
                    }
                    .transition(.opacity)
                }
                
                // Instructions Overlay (shows briefly)
                if showControls && scale == 1.0 {
                    VStack {
                        Spacer()
                        HStack(spacing: 20) {
                            Label("Pinch to zoom", systemImage: "arrow.up.left.and.arrow.down.right")
                            Label("Double tap to zoom", systemImage: "hand.tap")
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.5))
                        )
                        .padding(.bottom, 120)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // Gesture'ları computed property olarak tanımlayalım
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value
                scale *= delta
            }
            .onEnded { _ in
                lastScale = 1.0
                withAnimation(.spring()) {
                    scale = min(max(scale, 1), 4)
                }
            }
    }
    
    private var dragGesture: some Gesture {
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
    }
}
