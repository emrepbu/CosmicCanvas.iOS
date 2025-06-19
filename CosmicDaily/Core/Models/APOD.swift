//
//  APOD.swift
//  CosmicDaily
//
//  Created by emre argana on 10.06.2025.
//
//  APOD (Astronomy Picture of the Day) veri modeli
//  NASA'nın günün astronomik görüntüsü API'sinden gelen verileri temsil eder

import Foundation

struct APOD: Codable, Identifiable {
    /// Görüntünün tarihi (yyyy-MM-dd formatında)
    let date: String
    
    /// Görüntü veya videonun bilimsel açıklaması
    let explanation: String
    
    /// Yüksek çözünürlüklü görüntü URL'i (opsiyonel)
    let hdurl:String?
    
    /// Medya tipi ("image" veya "video")
    let mediaType: String
    
    /// API servis versiyonu
    let serviceVersion: String
    
    /// Görüntünün başlığı
    let title: String
    
    /// Standart çözünürlüklü görüntü veya video URL'i
    let url: String
    
    /// Telif hakkı sahibi (opsiyonel)
    let copyright: String?
    
    /// Identifiable protokolü için benzersiz kimlik
    var id: String {
        date
    }
    
    /// JSON anahtar eşleştirmeleri
    enum CodingKeys: String, CodingKey {
        case date
        case explanation
        case hdurl
        case mediaType = "media_type"
        case serviceVersion = "service_version"
        case title
        case url
        case copyright
    }
}
