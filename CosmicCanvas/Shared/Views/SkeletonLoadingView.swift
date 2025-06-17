//
//  SkeletonLoadingView.swift
//  CosmicDaily
//
//  Created by emre argana on 17.06.2025.
//

import SwiftUI

struct SkeletonLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Header Card Skeleton
            VStack(alignment: .leading, spacing: 12) {
                // Title skeleton
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 32)
                    .frame(maxWidth: .infinity)
                    .shimmer(isAnimating: isAnimating)
                
                // Date skeleton
                HStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 20)
                        .shimmer(isAnimating: isAnimating)
                    
                    Spacer()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            
            // Image Skeleton
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 300)
                .shimmer(isAnimating: isAnimating)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            // Description Card Skeleton
            VStack(alignment: .leading, spacing: 12) {
                // Section title
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 150, height: 24)
                    .shimmer(isAnimating: isAnimating)
                
                // Text lines
                VStack(spacing: 8) {
                    ForEach(0..<4) { _ in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 16)
                            .shimmer(isAnimating: isAnimating)
                    }
                    
                    // Last line shorter
                    HStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 16)
                            .frame(maxWidth: 200)
                            .shimmer(isAnimating: isAnimating)
                        Spacer()
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

// Shimmer Effect Modifier
struct ShimmerModifier: ViewModifier {
    let isAnimating: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    if isAnimating {
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0),
                                Color.white.opacity(0.5),
                                Color.white.opacity(0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geometry.size.width * 2)
                        .offset(x: isAnimating ? geometry.size.width : -geometry.size.width)
                        .animation(
                            .linear(duration: 1.5)
                            .repeatForever(autoreverses: false),
                            value: isAnimating
                        )
                    }
                }
                .clipped()
            )
    }
}

extension View {
    func shimmer(isAnimating: Bool) -> some View {
        modifier(ShimmerModifier(isAnimating: isAnimating))
    }
}

#Preview {
    SkeletonLoadingView()
        .padding()
}
