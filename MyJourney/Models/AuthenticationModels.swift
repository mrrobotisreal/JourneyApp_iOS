//
//  AuthenticationModels.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 2/3/25.
//

import Foundation

struct CreateAccountRequest: Codable {
    let username: String
    let password: String
    let sessionOption: String
}

struct CreateAccountResponse: Codable {
    let success: Bool
    let token: String?
    let apiKey: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case token
        case apiKey = "apiKey"
    }
}

struct LoginRequest: Codable {
    let username: String
    let password: String
    let sessionOption: String
}

struct LoginResponse: Codable {
    let success: Bool
    let token: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case token
    }
}

struct SearchEntriesBody: Encodable {
    let searchQuery: String
    let locations: [LocationData]
    let tags: [TagData]
    let sortRule: String
    let timeframe: String
    let fromDate: String?
    let toDate: String?
}

struct CreateNewEntryRequest: Codable {
    let username: String
    let text: String
    let timestamp: String
    let locations: [LocationData]?
    let tags: [TagData]?
}

struct CreateNewEntryResponse: Decodable {
    let uuid: String
}

struct UpdateEntryRequest: Codable {
    let id: String
    let username: String
    let text: String?
    let images: [String]?
    let locations: [LocationData]?
    let tags: [TagData]?
}

struct UpdateEntryResponse: Decodable {
    let success: Bool
}

struct LocationData: Codable, Hashable {
    let latitude: Double
    let longitude: Double
    let displayName: String?
}

struct IdentifiableLocationData: Identifiable, Hashable {
    var id = UUID()
    let latitude: Double
    let longitude: Double
    let displayName: String?
}

struct TagData: Codable, Hashable {
    let key: String
    let value: String?
}

struct IdentifiableTagData: Identifiable, Hashable {
    var id = UUID()
    let key: String
    let value: String?
}

enum SortRule: String, CaseIterable, Identifiable {
    case newest = "Newest"
    case oldest = "Oldest"
    
    var id: String { self.rawValue }
}

enum Timeframe: String, CaseIterable, Identifiable {
    case all = "All time"
    case past30Days = "Past 30 days"
    case past3Months = "Past 3 months"
    case past6Months = "Past 6 months"
    case pastYear = "Past year"
    case customRange = "Select a timeframe"
    
    var id: String { self.rawValue }
}

struct FilterOptions {
    var selectedLocations: Set<LocationData> = []
    var selectedTags: Set<TagData> = []
    
    var sortRule: SortRule = .newest
    
    // If user picks customRange, they can specify a date "from" and "to"
    var timeframe: Timeframe = .all
    var fromDate: Date? = nil
    var toDate: Date? = nil
}

struct UploadImagesReturns {
    let success: Bool
    let imageURLs: [String]
}
