//
//  UnsupportedMediaView.swift
//  CosmicDaily
//
//  Created by emre argana on 17.06.2025.
//
//  Desteklenmeyen medya görünümü
//  Desteklenmeyen medya türleri için gösterilen uyarı

import SwiftUI

struct UnsupportedMediaView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Desteklenmeyen Medya Türü")
                .font(.headline)
            
            Text("Bu medya formatı şu anda desteklenmiyor")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.1))
        )
    }
}
