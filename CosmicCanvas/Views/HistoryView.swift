//
//  HistoryView.swift
//  CosmicCanvas
//
//  Created by emre argana on 11.06.2025.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()

    var body: some View {
        List {
            ForEach(viewModel.apods) { apod in
                VStack(alignment: .leading) {
                    Text(apod.title).font(.headline)
                    Text(apod.date).font(.caption).foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("Son 7 Gun")
        .onAppear {
            viewModel.fetchLastNDays(7)
        }
    }
}

#Preview {
    HistoryView()
}
