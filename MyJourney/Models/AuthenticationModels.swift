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
    let userId: String
    let username: String
    let token: String
    let apiKey: String
    let font: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case userId
        case username
        case token
        case apiKey
        case font
    }
}

struct DeleteAccountResponse: Codable {
    let success: Bool
    
    enum CodingKeys: String, CodingKey {
        case success
    }
}

struct LoginRequest: Codable {
    let username: String
    let password: String
    let sessionOption: String
}

struct LoginResponse: Codable {
    let success: Bool
    let userId: String
    let username: String
    let token: String
    let apiKey: String
    let font: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case userId
        case username
        case token
        case apiKey
        case font
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
    let userId: String
    let username: String
    let text: String
    let timestamp: String
    let images: [String]?
    let locations: [LocationData]?
    let tags: [TagData]?
}

struct CreateNewEntryResponse: Decodable {
    let id: String
    let userId: String
    let username: String
    let text: String
    let timestamp: String
    let lastUpdated: String
    let images: [String]?
    let locations: [LocationData]?
    let tags: [TagData]?
}

struct UpdateEntryRequest: Codable {
    let id: String
    let userId: String
    let username: String
    let timestamp: String
    let text: String?
    let images: [String]?
    let locations: [LocationData]?
    let tags: [TagData]?
}

struct UpdateEntryResponse: Decodable {
    let success: Bool
}

struct DeleteEntryRequest: Codable {
    let userId: String
    let timestamp: String
}

struct DeleteEntryResponse: Decodable {
    let success: Bool
}

struct AddTagRequest: Codable {
    let username: String
    let userId: String
    let timestamp: String
    let entryId: String
    let tags: [TagData]
}

struct AddTagResponse: Decodable {
    let success: Bool
}

struct DeleteTagRequest: Codable {
    let username: String
    let userId: String
    let timestamp: String
    let entryId: String
    let tags: [TagData]
}

struct DeleteTagResponse: Decodable {
    let success: Bool
}

struct AddLocationRequest: Codable {
    let username: String
    let userId: String
    let timestamp: String
    let entryId: String
    let locations: [LocationData]
}

struct AddLocationResponse: Decodable {
    let success: Bool
}

struct DeleteLocationRequest: Codable {
    let username: String
    let userId: String
    let timestamp: String
    let entryId: String
    let locations: [LocationData]
}

struct DeleteLocationResponse: Decodable {
    let success: Bool
}

struct AddImageRequest: Codable {
    let username: String
    let userId: String
    let timestamp: String
    let entryId: String
    let images: [String]
}

struct AddImageResponse: Decodable {
    let success: Bool
}

struct DeleteImageRequest: Codable {
    let username: String
    let userId: String
    let timestamp: String
    let entryId: String
    let images: [String]
    let imageToDelete: String
}

struct DeleteImageResponse: Decodable {
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
