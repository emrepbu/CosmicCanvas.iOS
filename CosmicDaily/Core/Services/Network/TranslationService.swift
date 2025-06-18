//
//  TranslationService.swift
//  CosmicDaily
//
//  Created by emre argana on 18.06.2025.
//

import Foundation

// MARK: - Translation Models
struct Language: Identifiable {
    let id: String
    let code: String
    let name: String
    let englishName: String
}

struct TranslationResponse: Codable {
    let translatedText: String
    let detectedLanguage: String?
}

// MARK: - Translation Service
class TranslationService {
    static let shared = TranslationService()
    private init() {}
    
    // Desteklenen diller
    static let supportedLanguages: [Language] = [
        Language(id: "tr", code: "tr", name: "Türkçe", englishName: "Turkish"),
        Language(id: "es", code: "es", name: "Español", englishName: "Spanish"),
        Language(id: "fr", code: "fr", name: "Français", englishName: "French"),
        Language(id: "de", code: "de", name: "Deutsch", englishName: "German"),
        Language(id: "it", code: "it", name: "Italiano", englishName: "Italian"),
        Language(id: "pt", code: "pt", name: "Português", englishName: "Portuguese"),
        Language(id: "ru", code: "ru", name: "Русский", englishName: "Russian"),
        Language(id: "ja", code: "ja", name: "日本語", englishName: "Japanese"),
        Language(id: "zh", code: "zh", name: "中文", englishName: "Chinese"),
        Language(id: "ko", code: "ko", name: "한국어", englishName: "Korean"),
        Language(id: "hi", code: "hi", name: "हिन्दी", englishName: "Hindi")
    ]
    
    // Cache için dictionary
    private var translationCache: [String: String] = [:]
    
    // Cache key oluştur
    private func cacheKey(text: String, targetLanguage: String) -> String {
        return "\(targetLanguage)_\(text.hashValue)"
    }
    
    // Çeviri yap
    func translate(text: String, to targetLanguage: String) async throws -> String {
        // Cache kontrol
        let key = cacheKey(text: text, targetLanguage: targetLanguage)
        if let cachedTranslation = translationCache[key] {
            return cachedTranslation
        }
        
        // Google Translate API çağrısı
        let translation = try await performGoogleTranslation(text: text, targetLanguage: targetLanguage)
        
        // Cache'e kaydet
        translationCache[key] = translation
        
        return translation
    }
    
    private func performGoogleTranslation(text: String, targetLanguage: String) async throws -> String {
        // Text'i encode et
        guard let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw TranslationError.encodingFailed
        }
        
        // URL oluştur
        let urlString = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=\(targetLanguage)&dt=t&q=\(encodedText)"
        
        guard let url = URL(string: urlString) else {
            throw TranslationError.invalidURL
        }
        
        // Request yap
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Response kontrol
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TranslationError.invalidResponse
        }
        
        // JSON parse et
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [Any],
              let translations = json.first as? [[Any]] else {
            throw TranslationError.parsingFailed
        }
        
        // Çevrilmiş metni birleştir
        var translatedText = ""
        for translation in translations {
            if let text = translation.first as? String {
                translatedText += text
            }
        }
        
        // Boşsa hata fırlat
        if translatedText.isEmpty {
            throw TranslationError.emptyTranslation
        }
        
        return translatedText
    }
    
    // Cache temizle
    func clearCache() {
        translationCache.removeAll()
    }
}

// MARK: - Translation Errors
enum TranslationError: LocalizedError {
    case encodingFailed
    case invalidURL
    case invalidResponse
    case parsingFailed
    case emptyTranslation
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode text for translation"
        case .invalidURL:
            return "Invalid translation URL"
        case .invalidResponse:
            return "Invalid response from translation service"
        case .parsingFailed:
            return "Failed to parse translation response"
        case .emptyTranslation:
            return "Translation returned empty result"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
