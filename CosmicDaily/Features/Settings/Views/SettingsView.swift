//
//  SettingsView.swift
//  CosmicDaily
//
//  Created by emre argana on 17.06.2025.
//
//  Ayarlar görünümü
//  Uygulama ayarlarını, API yapılandırmasını ve önbellek yönetimini sağlar

import SwiftUI

struct SettingsView: View {
    @AppStorage("NASA_API_KEY") private var apiKey: String = "DEMO_KEY"
    @State private var tempApiKey: String = ""
    @State private var showingApiKeySaved = false
    @State private var showingClearCache = false
    @State private var showingClearCacheAlert = false
    @State private var showApiKey = false
    @Environment(\.dismiss) private var dismiss
    
    // Uygulama Bilgisi
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    var body: some View {
        NavigationView {
            Form {
                // API Yapılandırma Bölümü
                Section {
                    // API Durumu
                    HStack {
                        Image(systemName: apiKey == "DEMO_KEY" ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
                            .foregroundColor(apiKey == "DEMO_KEY" ? .orange : .green)
                        
                        VStack(alignment: .leading) {
                            Text(apiKey == "DEMO_KEY" ? "Using Demo Key" : "Using Custom Key")
                                .font(.headline)
                            Text(apiKey == "DEMO_KEY" ? "Limited requests" : "Unlimited requests")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // API Anahtarı Girişi
                    HStack {
                        if showApiKey {
                            TextField("Enter NASA API Key", text: $tempApiKey)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        } else {
                            SecureField("NASA API Key", text: $tempApiKey)
                        }
                        
                        Button(action: { showApiKey.toggle() }) {
                            Image(systemName: showApiKey ? "eye.slash" : "eye")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: saveApiKey) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Save API Key")
                        }
                    }
                    .disabled(tempApiKey.isEmpty || tempApiKey == apiKey)
                } header: {
                    Label("API Configuration", systemImage: "key.fill")
                } footer: {
                    Text("Get your free API key from NASA [api.nasa.gov](https://api.nasa.gov) to enjoy unlimited access to space imagery.")
                }
                
                // Depolama Bölümü
                Section {
                    HStack {
                        Label("Cache Size", systemImage: "internaldrive")
                        Spacer()
                        Text(getCacheSize())
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: { showingClearCacheAlert = true }) {
                        HStack {
                            Label("Clear Cache", systemImage: "trash")
                                .foregroundColor(.red)
                            Spacer()
                            if showingClearCache {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                } header: {
                    Text("Storage")
                } footer: {
                    Text("Clear cached images and data to free up space.")
                }
                
                // Hakkında Bölümü
                Section {
                    HStack {
                        Label("Version", systemImage: "app.badge")
                        Spacer()
                        Text("\(appVersion) (\(buildNumber))")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Developer", systemImage: "person.circle")
                        Spacer()
                        Text("Emre Argana")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://github.com/emrepbu/CosmicDaily")!) {
                        HStack {
                            Label("Source Code", systemImage: "chevron.left.forwardslash.chevron.right")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Link(destination: URL(string: "https://apod.nasa.gov/apod/")!) {
                        HStack {
                            Label("NASA APOD Website", systemImage: "globe")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("About")
                } footer: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cosmic Daily")
                            .font(.headline)
                        Text("Discover the cosmos! Each day NASA features a different image or photograph of our fascinating universe.")
                            .font(.caption)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                tempApiKey = apiKey == "DEMO_KEY" ? "" : apiKey
            }
            .alert("API Key Saved", isPresented: $showingApiKeySaved) {
                Button("OK") { }
            } message: {
                Text("Your API key has been saved successfully")
            }
            .alert("Clear Cache?", isPresented: $showingClearCacheAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    clearCache()
                }
            } message: {
                Text("This will remove all cached images and data. You'll need an internet connection to reload content.")
            }
        }
    }
    
    private func saveApiKey() {
        apiKey = tempApiKey.isEmpty ? "DEMO_KEY" : tempApiKey
        showingApiKeySaved = true
        
        // Klavyeyi gizle
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func clearCache() {
        APODCacheService.shared.clearCache()
        ImageCacheService.shared.clearCache()
        
        withAnimation {
            showingClearCache = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showingClearCache = false
            }
        }
    }
    
    private func getCacheSize() -> String {
        var totalSize: Int64 = 0
        
        // UserDefaults önbellek boyutunu al (APOD verisi)
        if let apodData = UserDefaults.standard.data(forKey: "CachedAPOD") {
            totalSize += Int64(apodData.count)
        }
        
        // Dokümanlar dizini önbellek boyutunu al
        let fileManager = FileManager.default
        if let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let cachePath = documentsPath.appendingPathComponent("CachedImages")
            
            if let files = try? fileManager.contentsOfDirectory(at: cachePath, includingPropertiesForKeys: [.fileSizeKey]) {
                for file in files {
                    if let fileSize = try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                        totalSize += Int64(fileSize)
                    }
                }
            }
        }
        
        // İnsan tarafından okunabilir formata dönüştür
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        
        return formatter.string(fromByteCount: totalSize)
    }
}

#Preview {
    SettingsView()
}
