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
        VStack(alignment: .leading, spacing: 12) {
            // Header with controls
            HStack {
                Text("Today's Story")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Translation Controls
                HStack(spacing: 8) {
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
            }
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    // Main text
                    Text(viewModel.getCurrentText(originalText: originalText))
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.showOriginal)
                    
                    // Error message if any
                    if let error = viewModel.translationError {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 12))
                            Text(error)
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.red)
                        .padding(.top, 4)
                    }
                    
                    // Translation attribution
                    if !viewModel.showOriginal && viewModel.translatedText != nil {
                        HStack {
                            Image(systemName: "info.circle")
                                .font(.system(size: 12))
                            Text("Translated by Google")
                                .font(.system(size: 12))
                            Spacer()
                        }
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                    }
                }
            }
            .frame(maxHeight: 300)
        }
    }
}

// MARK: - Language Picker View
struct LanguagePickerView: View {
    @Binding var selectedLanguage: Language
    let onSelect: (Language) -> Void
    
    var body: some View {
        Menu {
            ForEach(TranslationService.supportedLanguages) { language in
                Button(action: {
                    selectedLanguage = language
                    onSelect(language)
                }) {
                    HStack {
                        Text(language.name)
                        if selectedLanguage.id == language.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "globe")
                Text(selectedLanguage.code.uppercased())
                    .font(.system(size: 12, weight: .semibold))
                Image(systemName: "chevron.down")
                    .font(.system(size: 10))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.tertiarySystemBackground))
            )
        }
    }
}

// MARK: - Translate Button
struct TranslateButton: View {
    let isTranslating: Bool
    let showOriginal: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if isTranslating {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: showOriginal ? "character.book.closed" : "arrow.uturn.backward")
                        .font(.system(size: 14))
                }
                Text(showOriginal ? "Translate" : "Original")
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(showOriginal ? Color.blue : Color(.tertiarySystemBackground))
            )
            .foregroundColor(showOriginal ? .white : .primary)
        }
        .disabled(isTranslating)
    }
}
