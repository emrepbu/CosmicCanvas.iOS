//
//  Today.swift
//  CosmicCanvas
//
//  Created by emre argana on 11.06.2025.
//

import SwiftUI

import SwiftUI

struct TodayView: View {
    @StateObject private var viewModel = TodayViewModel()
    
    @State private var showImage = false
    @State private var showTitle = false
    @State private var showExplanation = false

    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView("Yükleniyor...")
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.blue))
                    .scaleEffect(1.5)
            } else if let apod = viewModel.apod {
                VStack(alignment: .leading, spacing: 16) {
                    Text(apod.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top, 40)
                        .opacity(showTitle ? 1 : 0)
                        .animation(.easeOut(duration: 1.2), value: showTitle)
                        .onAppear {
                            showTitle = true
                        }

                    if apod.mediaType == "image" {
                        AsyncImage(url: URL(string: apod.url)) { image in
                            image.resizable()
                                 .aspectRatio(contentMode: .fit)
                                 .frame(maxWidth: .infinity)
                                 .transition(.scale)
                        } placeholder: {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.blue))
                        }
                        .opacity(showImage ? 1 : 0)
                        .animation(.easeOut(duration: 1), value: showImage)
                        .onAppear {
                            showImage = true
                        }
                    } else {
                        Text("Video türündeki medya bu uygulamada desteklenmiyor.")
                            .foregroundColor(.gray)
                    }

                    Text(apod.explanation)
                        .font(.body)
                        .foregroundColor(.black)
                        .opacity(showExplanation ? 1 : 0)
                        .animation(.easeIn(duration: 1), value: showExplanation)
                        .onAppear {
                            showExplanation = true
                        }
                }
                .padding()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .navigationTitle("Bugünün APOD'u")
        .onAppear {
            viewModel.fetchToday()
        }
    }
}

#Preview {
    TodayView()
}
