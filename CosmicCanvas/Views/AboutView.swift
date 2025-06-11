//
//  AboutView.swift
//  CosmicCanvas
//
//  Created by emre argana on 11.06.2025.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Hakkinda")
                    .font(.title)
                Text("Bu uygulama, NASA'nin Astronomy Picture of the Day (APOD) servisini kullanarak gunluk ve gecmise donuk astronomi gorsellerini gosterir.")
                Text("Gelistirici: emre argana")
                Text("Veri kaynagi: NASA APOD API")
            }
            .padding()
        }
        .navigationTitle("Hakkinda")
    }
}
