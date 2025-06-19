//
//  VideoContentView.swift
//  CosmicDaily
//
//  Created by emre argana on 17.06.2025.
//
//  Video içerik görünümü
//  Video türündeki APOD içeriklerini oynatır

import SwiftUI
import AVKit

struct VideoContentView: View {
    let videoURL: URL
    @State private var player: AVPlayer?
    
    var body: some View {
        VStack {
            VideoPlayer(player: player)
                .frame(height: 300)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 10)
                .onAppear {
                    player = AVPlayer(url: videoURL)
                }
            
            HStack(spacing: 20) {
                Button(action: {
                    player?.play()
                }) {
                    Label("Play", systemImage: "play.fill")
                        .font(.system(size: 16, weight: .medium))
                }
                .buttonStyle(.bordered)
                
                Button(action: {
                    player?.pause()
                }) {
                    Label("Pause", systemImage: "pause.fill")
                        .font(.system(size: 16, weight: .medium))
                }
                .buttonStyle(.bordered)
            }
            .padding(.top, 8)
        }
    }
}
