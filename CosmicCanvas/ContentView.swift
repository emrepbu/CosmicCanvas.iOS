//
//  ContentView.swift
//  CosmicCanvas
//
//  Created by emre argana on 10.06.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView { TodayView() }
                .tabItem {
                    Label("Bugün", systemImage: "sun.max")
                }
            
            NavigationView { HistoryView() }
                .tabItem {
                    Label("Geçmiş", systemImage: "clock.arrow.circlepath")
                }
            
            NavigationView { SettingsView() }
                .tabItem {
                    Label("Ayarlar", systemImage: "gear")
                }
            
            NavigationView { AboutView() }
                .tabItem {
                    Label("Hakkında", systemImage: "info.circle")
                }
        }
    }
}

#Preview {
    ContentView()
}
