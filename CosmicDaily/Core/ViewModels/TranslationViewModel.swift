//
//  TranslationViewModel.swift
//  CosmicDaily
//
//  Created by emre argana on 18.06.2025.
//

import Foundation
import SwiftUI

@MainActor
class TranslationViewModel: ObservableObject {
    @Published var selectedLanguage: Language = TranslationService.supportedLanguages.first!
    @Published var translatedText: String?
    @Published var isTranslating = false
    @Published var showOriginal = true
    @Published var translationError: String?
    
    private let translationService = TranslationService.shared
    private var originalText: String = ""
    
    // Dil değiştir
    func selectLanguage(_ language: Language) {
        selectedLanguage = language
        // Dil değiştiğinde mevcut çeviriyi temizle
        if !showOriginal {
            translatedText = nil
            showOriginal = true
        }
    }
    
    // Çeviri yap veya orijinale dön
    func toggleTranslation(for text: String) {
        if showOriginal {
            translateText(text)
        } else {
            showOriginalText()
        }
    }
    
    private func translateText(_ text: String) {
        originalText = text
        isTranslating = true
        translationError = nil
        
        Task {
            do {
                let translated = try await translationService.translate(
                    text: text,
                    to: selectedLanguage.code
                )
                
                self.translatedText = translated
                self.showOriginal = false
                self.isTranslating = false
                
            } catch {
                self.isTranslating = false
                self.translationError = error.localizedDescription
                print("Translation failed: \(error)")
            }
        }
    }
    
    private func showOriginalText() {
        showOriginal = true
        translationError = nil
    }
    
    // Mevcut görüntülenen metni al
    func getCurrentText(originalText: String) -> String {
        if showOriginal || translatedText == nil {
            return originalText
        }
        return translatedText!
    }
}
