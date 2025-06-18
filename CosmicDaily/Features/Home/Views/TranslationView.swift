//
//  TranslationView.swift
//  CosmicDaily
//
//  Created by emre argana on 18.06.2025.
//

import SwiftUI

struct TranslationView: View {
    @StateObject private var viewModel = TranslationViewModel()
    let originalText: String
    
    var body: some View {
        // Translation Controls
        HStack {
            // Language Picker
            LanguagePickerView(selectedLanguage: $viewModel.selectedLanguage) { language in
                viewModel.selectLanguage(language)
            }
            
            // Translate Button
            TranslateButton(
                isTranslating: viewModel.isTranslating,
                showOriginal: viewModel.showOriginal
            ) {
                viewModel.toggleTranslation(for: originalText)
            }
        }
        
        VStack(alignment: .leading) {
            // Header with controls
            Text("Today's Story")
                .font(.largeTitle)
                .foregroundColor(.primary)
            
            // Content
            VStack(alignment: .leading) {
                // Main text
                Text(viewModel.getCurrentText(originalText: originalText))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(6)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.showOriginal)
                
                // Error message if any
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
                
                // Translation attribution
                if !viewModel.showOriginal && viewModel.translatedText != nil {
                    HStack {
                        Image(systemName: "info.circle")
                            .font(.body)
                        Text("Translated by Google")
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

// MARK: - Language Picker View
struct LanguagePickerView: View {
    @Binding var selectedLanguage: Language
    let onSelect: (Language) -> Void
    
    var body: some View {
        Picker("Language", selection: $selectedLanguage) {
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

// MARK: - Translate Button
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
                Text(showOriginal ? "Translate" : "Original")
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
