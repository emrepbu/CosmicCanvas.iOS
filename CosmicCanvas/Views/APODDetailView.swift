//
//  APODDetailView.swift
//  CosmicCanvas
//
//  Created by emre argana on 16.06.2025.
//

import SwiftUI

struct APODDetailView: View {
    let apod: APOD
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: URL(string: apod.url)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                        .frame(height: 300)
                        .frame(maxWidth: .infinity)
                }
                
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(apod.title)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text(apod.date)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "heart")
                    }
                    
                    Text(apod.explanation)
                        .font(.body)
                        .padding(.top)
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
