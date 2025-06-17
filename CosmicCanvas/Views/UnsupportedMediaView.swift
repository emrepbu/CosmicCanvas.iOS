//
//  UnsupportedMediaView.swift
//  CosmicCanvas
//
//  Created by emre argana on 17.06.2025.
//

import SwiftUI

struct UnsupportedMediaView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Unsupported Media Type")
                .font(.headline)
            
            Text("This media format is not currently supported")
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
