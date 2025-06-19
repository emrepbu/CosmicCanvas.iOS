//
//  TranslationView.swift
//  CosmicDaily
//
//  Created by emre argana on 18.06.2025.
//
//  Çeviri görünümü
//  Metin çeviri kontrolleri ve gösterimini sağlar

import SwiftUI

struct TranslationView: View {
    @StateObject private var viewModel = TranslationViewModel()
    let originalText: String
    
    var body: some View {
        // Çeviri Kontrolleri
        HStack {
            // Dil Seçici
            LanguagePickerView(selectedLanguage: $viewModel.selectedLanguage) { language in
                viewModel.selectLanguage(language)
            }
            
            // Çeviri Butonu
            TranslateButton(
                isTranslating: viewModel.isTranslating,
                showOriginal: viewModel.showOriginal
            ) {
                viewModel.toggleTranslation(for: originalText)
            }
        }
        
        VStack(alignment: .leading) {
            // Kontrollerle başlık
            Text("Günün Hikayesi")
                .font(.largeTitle)
                .foregroundColor(.primary)
            
            // İçerik
            VStack(alignment: .leading) {
                // Ana metin
                Text(viewModel.getCurrentText(originalText: originalText))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(6)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.showOriginal)
                
                // Hata mesajı (varsa)
                if let error = viewModel.translationError {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.body)
                        Text(error)
                            .font(.body)
                    }
                    .foregroundColor(.red)
                    .padding()
                }
                
                // Çeviri atfı
                if !viewModel.showOriginal && viewModel.translatedText != nil {
                    HStack {
                        Image(systemName: "info.circle")
                            .font(.body)
                        Text("Google tarafından çevrildi")
                            .font(.body)
                        Spacer()
                    }
                    .foregroundColor(.secondary)
                    .padding()
                }
            }
        }
    }
}

// MARK: - Dil Seçici Görünümü
struct LanguagePickerView: View {
    @Binding var selectedLanguage: Language
    let onSelect: (Language) -> Void
    
    var body: some View {
        Picker("Dil", selection: $selectedLanguage) {
            ForEach(TranslationService.supportedLanguages) { language in
                Text(language.name)
                    .tag(language)
            }
        }
        .pickerStyle(.menu)
        .labelsHidden()
        .onChange(of: selectedLanguage) { newLanguage in
            onSelect(newLanguage)
        }
        .padding()
    }
}

// MARK: - Çeviri Butonu
struct TranslateButton: View {
    let isTranslating: Bool
    let showOriginal: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isTranslating {
                    ProgressView()
                } else {
                    Image(systemName: showOriginal ? "translate" : "arrow.uturn.backward")
                }
                Text(showOriginal ? "Çevir" : "Orijinal")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(showOriginal ? Color.blue : Color(.tertiarySystemBackground))
            )
            .foregroundColor(showOriginal ? .white : .primary)
        }
        .disabled(isTranslating)
    }
}
