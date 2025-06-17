//
//  APOD.swift
//  CosmicDaily
//
//  Created by emre argana on 10.06.2025.
//

import Foundation

struct APOD: Codable, Identifiable {
    let date: String
    let explanation: String
    let hdurl:String?
    let mediaType: String
    let serviceVersion: String
    let title: String
    let url: String
    let copyright: String?
    
    var id: String {
        date
    }
    
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
