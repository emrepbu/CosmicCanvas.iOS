//
//  TranslationService.swift
//  CosmicDaily
//
//  Created by emre argana on 18.06.2025.
//
//  Çeviri servisi
//  Google Translate API kullanarak metinleri farklı dillere çevirir

import Foundation

// MARK: - Çeviri Modelleri
/// Dil modeli - Desteklenen dilleri temsil eder
struct Language: Identifiable, Hashable {
    /// Benzersiz tanımlayıcı
    let id: String
    
    /// Dil kodu (ISO 639-1)
    let code: String
    
    /// Dilin kendi dilindeki adı
    let name: String
    
    /// Dilin İngilizce adı
    let englishName: String
    
    // Hashable için gerekli
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Equatable için gerekli (Hashable'ın bir parçası)
    static func == (lhs: Language, rhs: Language) -> Bool {
        lhs.id == rhs.id
    }
}

/// Çeviri yanıt modeli
struct TranslationResponse: Codable {
    /// Çevrilmiş metin
    let translatedText: String
    
    /// Algılanan kaynak dil (opsiyonel)
    let detectedLanguage: String?
}

// MARK: - Çeviri Servisi
/// Metin çeviri servisi
class TranslationService {
    /// Paylaşılan tekil örnek
    static let shared = TranslationService()
    private init() {}
    
    /// Desteklenen diller listesi
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
    
    /// Çeviri önbelleği - daha hızlı erişim için çevirileri saklar
    private var translationCache: [String: String] = [:]
    
    /// Önbellek anahtarı oluştur
    /// - Parameters:
    ///   - text: Çevrilecek metin
    ///   - targetLanguage: Hedef dil kodu
    /// - Returns: Benzersiz önbellek anahtarı
    private func cacheKey(text: String, targetLanguage: String) -> String {
        return "\(targetLanguage)_\(text.hashValue)"
    }
    
    /// Metni belirtilen dile çevir
    func translate(text: String, to targetLanguage: String) async throws -> String {
        // Önbellek kontrolü
        let key = cacheKey(text: text, targetLanguage: targetLanguage)
        if let cachedTranslation = translationCache[key] {
            return cachedTranslation
        }
        
        // Google Translate API çağrısı
        let translation = try await performGoogleTranslation(text: text, targetLanguage: targetLanguage)
        
        // Önbelleğe kaydet
        translationCache[key] = translation
        
        return translation
    }
    
    /// Google Translate API ile çeviri yap
    /// - Parameters:
    ///   - text: Çevrilecek metin
    ///   - targetLanguage: Hedef dil kodu
    /// - Returns: Çevrilmiş metin
    private func performGoogleTranslation(text: String, targetLanguage: String) async throws -> String {
        // Metni URL için encode et
        guard let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw TranslationError.encodingFailed
        }
        
        // API URL'ini oluştur
        let urlString = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=\(targetLanguage)&dt=t&q=\(encodedText)"
        
        guard let url = URL(string: urlString) else {
            throw TranslationError.invalidURL
        }
        
        // HTTP isteği yap
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Yanıtı kontrol et
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TranslationError.invalidResponse
        }
        
        // JSON verisini parse et
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [Any],
              let translations = json.first as? [[Any]] else {
            throw TranslationError.parsingFailed
        }
        
        // Çeviri parçalarını birleştir
        var translatedText = ""
        for translation in translations {
            if let text = translation.first as? String {
                translatedText += text
            }
        }
        
        // Sonuç boşsa hata fırlat
        if translatedText.isEmpty {
            throw TranslationError.emptyTranslation
        }
        
        return translatedText
    }
    
    /// Çeviri önbelleğini temizle
    func clearCache() {
        translationCache.removeAll()
    }
}

// MARK: - Çeviri Hataları
/// Çeviri servisi hata türleri
enum TranslationError: LocalizedError {
    /// Metin kodlama hatası
    case encodingFailed
    
    /// Geçersiz URL
    case invalidURL
    
    /// Geçersiz API yanıtı
    case invalidResponse
    
    /// JSON parse hatası
    case parsingFailed
    
    /// Boş çeviri sonucu
    case emptyTranslation
    
    /// Ağ hatası
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Çeviri için metin kodlanamadı"
        case .invalidURL:
            return "Geçersiz çeviri URL'i"
        case .invalidResponse:
            return "Çeviri servisinden geçersiz yanıt"
        case .parsingFailed:
            return "Çeviri yanıtı işlenemedi"
        case .emptyTranslation:
            return "Çeviri boş sonuç döndürdü"
        case .networkError(let error):
            return "Ağ hatası: \(error.localizedDescription)"
        }
    }
}
