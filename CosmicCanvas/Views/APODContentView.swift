//
//  APODContentView.swift
//  CosmicCanvas
//
//  Created by emre argana on 17.06.2025.
//

import SwiftUI

struct APODContentView: View {
    let apod: APOD
    @Binding var showFullScreen: Bool
    @Binding var selectedImage: String
    @State private var imageLoaded = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Header Card
            VStack(alignment: .leading, spacing: 12) {
                Text(apod.title)
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack {
                    Label(formatDate(apod.date), systemImage: "calendar")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if let copyright = apod.copyright {
                        Label(copyright, systemImage: "c.circle")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            
            // Media Content
            if apod.mediaType == "image" {
                ImageContentView(
                    imageURL: apod.hdurl ?? apod.url,
                    showFullScreen: $showFullScreen,
                    selectedImage: $selectedImage,
                    imageLoaded: $imageLoaded
                )
            } else if apod.mediaType == "video", let videoURL = URL(string: apod.url) {
                VideoContentView(videoURL: videoURL)
            } else {
                UnsupportedMediaView()
            }
            
            // Description Card
            VStack(alignment: .leading, spacing: 12) {
                Text("Today's Story")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(apod.explanation)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
        }
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
