//
//  APODRowView.swift
//  CosmicCanvas
//
//  Created by emre argana on 16.06.2025.
//

import SwiftUI

struct APODRowView: View {
    let apod: APOD
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: apod.url)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 80, height: 80)
            .clipped(antialiased: true)
            .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(apod.title)
                    .font(.headline)
                    .lineLimit(2)
                Text(apod.date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
