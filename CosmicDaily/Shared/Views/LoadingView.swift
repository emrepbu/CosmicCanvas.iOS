//
//  LoadingView.swift
//  CosmicDaily
//
//  Created by emre argana on 17.06.2025.
//
//  Yükleme görünümü
//  Yükleme durumunu animasyonlu bir şekilde gösterir

import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(lineWidth: 4)
                    .opacity(0.3)
                    .foregroundColor(.blue)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.blue)
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            }
            
            Text("Loading cosmic wonders...")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(50)
        .onAppear {
            isAnimating = true
        }
    }
}
