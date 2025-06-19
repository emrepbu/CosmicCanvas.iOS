//
//  TranslationViewModel.swift
//  CosmicDaily
//
//  Created by emre argana on 18.06.2025.
//
//  Çeviri ViewModel
//  Çeviri işlemlerini yönetir ve UI durumunu kontrol eder

import Foundation
import SwiftUI

@MainActor
class TranslationViewModel: ObservableObject {
    /// Seçili dil
    @Published var selectedLanguage: Language = TranslationService.supportedLanguages.first!
    
    /// Çevrilmiş metin
    @Published var translatedText: String?
    
    /// Çeviri durumu
    @Published var isTranslating = false
    
    /// Orijinal metni gösterme durumu
    @Published var showOriginal = true
    
    /// Çeviri hata mesajı
    @Published var translationError: String?
    
    /// Çeviri servisi
    private let translationService = TranslationService.shared
    
    /// Orijinal metin
    private var originalText: String = ""
    
    /// Dil seçimini değiştir
    /// - Parameter language: Seçilecek dil
    func selectLanguage(_ language: Language) {
        selectedLanguage = language
        // Dil değiştiğinde mevcut çeviriyi temizle
        if !showOriginal {
            translatedText = nil
            showOriginal = true
        }
    }
    
    /// Çeviri yap veya orijinal metne dön
    /// - Parameter text: Çevrilecek veya gösterilecek metin
    func toggleTranslation(for text: String) {
        if showOriginal {
            translateText(text)
        } else {
            showOriginalText()
        }
    }
    
    /// Metni çevir
    /// - Parameter text: Çevrilecek metin
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
                print("Çeviri başarısız: \(error)")
            }
        }
    }
    
    /// Orijinal metni göster
    private func showOriginalText() {
        showOriginal = true
        translationError = nil
    }
    
    /// Mevcut görüntülenen metni al
    /// - Parameter originalText: Orijinal metin
    /// - Returns: Gösterilecek metin (orijinal veya çevrilmiş)
    func getCurrentText(originalText: String) -> String {
        if showOriginal || translatedText == nil {
            return originalText
        }
        return translatedText!
    }
}
