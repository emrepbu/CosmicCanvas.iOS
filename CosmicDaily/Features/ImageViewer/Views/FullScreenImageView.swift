//
//  FullScreenImageView.swift
//  CosmicDaily
//
//  Created by emre argana on 17.06.2025.
//
//  Tam ekran görüntü görünümü
//  Yakınlaştırma ve kaydırma özellikleri ile tam ekran görüntü gösterimi sağlar

import SwiftUI

/// Yakınlaştırma ve kaydırma özellikleri ile tam ekran görüntü görüntüleyici
struct FullScreenImageView: View {
    // MARK: - Özellikler
    
    let imageURL: String
    @Binding var isPresented: Bool
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var isPinching = false
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Ana Görünüm
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if !imageURL.isEmpty {
                if let url = URL(string: imageURL) {
                    GeometryReader { geometry in
                        CachedAsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .scaleEffect(scale)
                                .offset(offset)
                                .gesture(
                                    SimultaneousGesture(
                                        magnificationGesture,
                                        dragGesture
                                    )
                                )
                                .onTapGesture(count: 2) {
                                    handleDoubleTap()
                                }
                        } placeholder: {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                    }
                } else {
                    invalidURLView
                }
            } else {
                noImageProvidedView
            }
            
            closeButton
            bottomControls
            instructionsOverlay
        }
        .preferredColorScheme(.dark)
        .statusBar(hidden: true)
    }
    
    // MARK: - Görünüm Bileşenleri
    
    /// Sağ üstte konumlandırılmış kapat butonu
    private var closeButton: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                        .background(Circle().fill(Color.black.opacity(0.5)))
                }
                .padding()
            }
            Spacer()
        }
    }
    
    /// Görüntü kontrolü için alt kontrol butonları
    private var bottomControls: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 20) {
                resetButton
                zoomInfoLabel
                fitToScreenButton
            }
            .padding(.bottom, 50)
        }
    }
    
    /// Görüntüyü orijinal durumuna getiren sıfırlama butonu
    private var resetButton: some View {
        Button(action: resetImageState) {
            VStack(spacing: 4) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 20))
                Text("Sıfırla")
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
    }
    
    /// Mevcut yakınlaştırma seviyesi göstergesi
    private var zoomInfoLabel: some View {
        Text("\(Int(scale * 100))%")
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.5))
            )
    }
    
    /// Ekrana sığdırma butonu
    private var fitToScreenButton: some View {
        Button(action: resetImageState) {
            VStack(spacing: 4) {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 20))
                Text("Sığdır")
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
    
    /// Görüntü varsayılan ölçekte olduğunda gösterilen talimatlar
    private var instructionsOverlay: some View {
        Group {
            if scale == 1.0 {
                VStack {
                    Spacer()
                    HStack(spacing: 20) {
                        Label("Yakınlaştırmak için sıkıştır", systemImage: "arrow.up.left.and.arrow.down.right")
                        Label("Çift dokun", systemImage: "hand.tap")
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
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.5), value: scale)
            }
        }
    }
    
    /// Geçersiz URL için hata görünümü
    private var invalidURLView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.yellow)
            Text("Geçersiz URL")
                .foregroundColor(.white)
            Text(imageURL)
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal)
        }
    }
    
    /// Görüntü URL'i sağlanmadığında gösterilen hata görünümü
    private var noImageProvidedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo")
                .font(.system(size: 50))
                .foregroundColor(.white)
            Text("Görüntü URL'i sağlanmadı")
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Hareketler
    
    /// Yakınlaştırma için sıkıştırma hareketi
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                isPinching = true
                let delta = value / lastScale
                lastScale = value
                
                var transaction = Transaction()
                transaction.animation = nil
                
                withTransaction(transaction) {
                    let newScale = scale * delta
                    scale = min(max(newScale, 0.8), 6)
                }
            }
            .onEnded { _ in
                isPinching = false
                lastScale = 1.0
                
                var transaction = Transaction()
                transaction.animation = .spring(response: 0.3, dampingFraction: 0.8)
                
                withTransaction(transaction) {
                    if scale < 1 {
                        scale = 1
                        offset = .zero
                        lastOffset = .zero
                    } else if scale > 5 {
                        scale = 5
                    }
                }
            }
    }
    
    /// Kaydırma için sürükleme hareketi
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                isDragging = true
                
                guard scale > 1 else { return }
                
                var transaction = Transaction()
                transaction.animation = nil
                
                withTransaction(transaction) {
                    offset = CGSize(
                        width: lastOffset.width + value.translation.width,
                        height: lastOffset.height + value.translation.height
                    )
                }
            }
            .onEnded { _ in
                isDragging = false
                lastOffset = offset
                
                if scale <= 1 {
                    var transaction = Transaction()
                    transaction.animation = .spring(response: 0.3, dampingFraction: 0.8)
                    
                    withTransaction(transaction) {
                        offset = .zero
                        lastOffset = .zero
                    }
                }
            }
    }
    
    // MARK: - Metodlar
    
    /// Yakınlaştırmayı açıp kapatmak için çift dokunma hareketini işler
    private func handleDoubleTap() {
        var transaction = Transaction()
        transaction.animation = .spring(response: 0.3, dampingFraction: 0.8)
        
        withTransaction(transaction) {
            if scale > 1 {
                scale = 1
                offset = .zero
                lastOffset = .zero
            } else {
                scale = 2.5
            }
        }
    }
    
    /// Görüntüyü orijinal durumuna sıfırlar
    private func resetImageState() {
        var transaction = Transaction()
        transaction.animation = .spring(response: 0.3, dampingFraction: 0.8)
        
        withTransaction(transaction) {
            scale = 1.0
            offset = .zero
            lastOffset = .zero
            lastScale = 1.0
        }
    }
}
