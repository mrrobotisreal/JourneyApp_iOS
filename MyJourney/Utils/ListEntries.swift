//
//  ListEntries.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 1/24/25.
//

import Foundation

struct EntryListItem: Identifiable, Decodable, Equatable, Hashable {
    let id: String
    let text: String
    let imageURLs: [String]
    let timestamp: String
    let locations: [LocationData]
    let tags: [TagData]
    // add locations and tags later...
    
    init(id: String, text: String, imageURLs: [String], timestamp: String, locations: [LocationData], tags: [TagData]) {
        self.id = id
        self.text = text
        self.imageURLs = imageURLs
        self.timestamp = timestamp
        self.locations = locations
        self.tags = tags
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case images
        case timestamp
        case locations
        case tags
        // add locations and tags later...
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        self.id = id
        
        self.text = try container.decode(String.self, forKey: .text)
        self.imageURLs = try container.decodeIfPresent([String].self, forKey: .images) ?? []
        self.timestamp = try container.decode(String.self, forKey: .timestamp)
        self.locations = try container.decode([LocationData].self, forKey: .locations)
        self.tags = try container.decode([TagData].self, forKey: .tags)
    }
}

func getPresignedURLForKey(_ key: String) async throws -> URL {
    guard var components = URLComponents(string: "https://journeyapp.me/api/entries/getImageURL") else {
        throw URLError(.badURL)
    }
    components.queryItems = [
        URLQueryItem(name: "key", value: key)
    ]
    guard let url = components.url else {
        throw URLError(.badURL)
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
        print("Bad server response while fetching presignedURL")
        throw URLError(.badServerResponse)
    }
    
    if let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let urlString = dict["url"] as? String, let presignedURL = URL(string: urlString) {
        return presignedURL
    }
    
    throw URLError(.cannotParseResponse)
}
