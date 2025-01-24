//
//  CreateNewEntry.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 1/23/25.
//

import Foundation
import UIKit

struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
    let displayName: String?
}

struct TagData: Codable {
    let key: String
    let value: String?
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

func getDateString() -> String {
    let today = Date.now
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMMM y"
    
    return formatter.string(from: today)
}

func getTimestampString() -> String {
    return ISO8601DateFormatter().string(from: Date.now)
}

func createNewEntryOnServer(
    username: String,
    text: String,
    locations: [LocationData]?,
    tags: [TagData]?
) async throws -> String {
    let timestamp = getTimestampString()
    let requestBody = CreateNewEntryRequest(
        username: username,
        text: text,
        timestamp: timestamp,
        locations: locations,
        tags: tags
    )
    
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let jsonData = try encoder.encode(requestBody)
    
    guard let url = URL(string: "https://journeyapp.me/api/entries/create") else {
        throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonData
    
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
        throw URLError(.badServerResponse)
    }
    
    let decoded = try JSONDecoder().decode(CreateNewEntryResponse.self, from: data)
    
    return decoded.uuid
}

private func getPresignedURL(
    username: String,
    uuid: String,
    filename: String
) async throws -> URL {
    guard var components = URLComponents(string: "https://journeyapp.me/api/entries/getPresignedURL") else {
        throw URLError(.badURL)
    }
    
    components.queryItems = [
        URLQueryItem(name: "username", value: username),
        URLQueryItem(name: "uuid", value: uuid),
        URLQueryItem(name: "filename", value: filename)
    ]
    
    guard let url = components.url else {
        throw URLError(.badURL)
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
        throw URLError(.badServerResponse)
    }
    
    if let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let urlString = dict["url"] as? String, let presignedURL = URL(string: urlString) {
        return presignedURL
    }
    
    throw URLError(.cannotParseResponse)
}

private func uploadImage(_ imageData: Data, to presignedURL: URL) async throws {
    var request = URLRequest(url: presignedURL)
    request.httpMethod = "PUT"
    request.setValue("image/*", forHTTPHeaderField: "Content-Type")
    
    let (_, response) = try await URLSession.shared.upload(for: request, from: imageData)
    
    guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
        throw URLError(.badServerResponse)
    }
}

func uploadImages(username: String, uuid: String, images: [UIImage]) async throws {
    for (index, image) in images.enumerated() {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            print("Could not generate JPEG data for image at index \(index). Skipping...")
            continue
        }
        
        let filename = "image\(index).jpg"
        
        let presignedURL = try await getPresignedURL(
            username: username,
            uuid: uuid,
            filename: filename
        )
        
        try await uploadImage(data, to: presignedURL)
        
        print("Successfully uploaded image \(index).jpg to S3!")
    }
}
