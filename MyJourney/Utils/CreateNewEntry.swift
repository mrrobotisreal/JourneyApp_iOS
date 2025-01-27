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

func updateEntryOnServer(entryId: String, username: String, text: String?, images: [String]?, locations: [LocationData]?, tags: [TagData]?) async throws -> Bool {
    let requestBody = UpdateEntryRequest(
        id: entryId,
        username: username,
        text: text,
        images: images,
        locations: locations,
        tags: tags
    )
    
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let jsonData = try encoder.encode(requestBody)
    
    guard let url = URL(string: "https://journeyapp.me/api/entries/update") else {
        throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "PUT"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonData
    
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
        throw URLError(.badServerResponse)
    }
    
    let decoded = try JSONDecoder().decode(UpdateEntryResponse.self, from: data)
    
    return decoded.success
}

func getImageKey(username: String, entryId: String, filename: String) -> String {
    return "images/\(username)/\(entryId)/\(filename)"
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

func uploadImages(username: String, uuid: String, images: [UIImage]) async throws -> Bool {
    var imageKeys: [String] = []
//    var localImageKeys: [String] = [] // TODO: Add localImageKeys to mongoDB model on Go server and update here
    
    for (index, image) in images.enumerated() {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            print("Could not generate JPEG data for image at index \(index). Skipping...")
            continue
        }
        
        let filename = "image\(index).jpg"
        let imageKey = getImageKey(username: username, entryId: uuid, filename: filename)
        imageKeys.append(imageKey)
        
        let presignedURL = try await getPresignedURL(
            username: username,
            uuid: uuid,
            filename: filename
        )
        
        try await uploadImage(data, to: presignedURL)
        
        print("Successfully uploaded image \(index).jpg to S3!")
    }
    
    let isEntryUpdateSuccessful = try await updateEntryOnServer(entryId: uuid, username: username, text: nil, images: imageKeys, locations: nil, tags: nil)
    print("Is entry update successful? ", isEntryUpdateSuccessful)
    
    return isEntryUpdateSuccessful
}

func saveImageLocally(_ uiImage: UIImage, for entryId: String, index: Int) -> URL? {
    guard let data = uiImage.jpegData(compressionQuality: 0.8) else { return nil }
    do {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL = dir.appendingPathComponent("\(entryId)-\(index).jpg")
        try data.write(to: localURL)
        return localURL
    } catch {
        print("Error saving image locally: \(error)")
        return nil
    }
}
