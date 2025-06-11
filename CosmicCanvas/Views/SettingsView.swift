//
//  Settings.swift
//  CosmicCanvas
//
//  Created by emre argana on 11.06.2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("apiKey") var apiKey: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("NASA API Key")) {
                TextField("API anahtarinizi girin", text: $apiKey)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
            }
        }
        .navigationTitle(Text("Ayarlar"))
    }
}

#Preview {
    SettingsView()
}
