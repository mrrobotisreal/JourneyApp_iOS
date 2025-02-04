//
//  NetworkService.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 2/3/25.
//

import Foundation
import UIKit

enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case decodingError
    case authenticationError
}

class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "https://journeyapp.me/api"
    
    private init() {}
    
    //
    // User API calls
    //
    
    func login(username: String, password: String, sessionOption: String) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/users/login") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginRequest = LoginRequest(
            username: username,
            password: password,
            sessionOption: sessionOption
        )
        
        request.httpBody = try JSONEncoder().encode(loginRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.requestFailed
        }
        
        do {
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            return loginResponse
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func createAccount(username: String, password: String, sessionOption: String) async throws -> CreateAccountResponse {
        guard let url = URL(string: "\(baseURL)/users/create") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let createAccountRequest = CreateAccountRequest(
            username: username,
            password: password,
            sessionOption: sessionOption
        )
        
        request.httpBody = try JSONEncoder().encode(createAccountRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.requestFailed
        }
        
        do {
            let createAccountResponse = try JSONDecoder().decode(CreateAccountResponse.self, from: data)
            return createAccountResponse
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    //
    // Entry API calls
    //
    
    func createNewEntry(
        username: String,
        text: String,
        locations: [LocationData]?,
        tags: [TagData]?
    ) async throws -> String {
        guard let url = URL(string: "\(baseURL)/entries/create") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        try addAuthenticationHeaders(to: &request)
        
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
        request.httpBody = try encoder.encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.requestFailed
        }
        
        let decoded = try JSONDecoder().decode(CreateNewEntryResponse.self, from: data)
        return decoded.uuid
    }
    
    func updateEntry(
        entryId: String,
        username: String,
        text: String?,
        images: [String]?,
        locations: [LocationData]?,
        tags: [TagData]?
    ) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/entries/update") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        try addAuthenticationHeaders(to: &request)
        
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
        request.httpBody = try encoder.encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.requestFailed
        }
        
        let decoded = try JSONDecoder().decode(UpdateEntryResponse.self, from: data)
        return decoded.success
    }
    
    func getPresignedURL(
        username: String,
        uuid: String,
        filename: String
    ) async throws -> URL {
        guard var components = URLComponents(string: "\(baseURL)/entries/getPresignedURL") else {
            throw NetworkError.invalidURL
        }
        
        components.queryItems = [
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "uuid", value: uuid),
            URLQueryItem(name: "filename", value: filename)
        ]
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        
        try addAuthenticationHeaders(to: &request)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.requestFailed
        }
        
        guard let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let urlString = dict["url"] as? String,
              let presignedURL = URL(string: urlString) else {
            throw NetworkError.decodingError
        }
        
        return presignedURL
    }
    
    func uploadImage(_ imageData: Data, to presignedURL: URL) async throws {
        var request = URLRequest(url: presignedURL)
        request.httpMethod = "PUT"
        request.setValue("image/*", forHTTPHeaderField: "Content-Type")
        
        let (_, response) = try await URLSession.shared.upload(for: request, from: imageData)
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.requestFailed
        }
    }
    
    func uploadImages(
        username: String,
        uuid: String,
        images: [UIImage]
    ) async throws -> UploadImagesReturns {
        var imageKeys: [String] = []
        
        for (index, image) in images.enumerated() {
            guard let data = image.jpegData(compressionQuality: 0.8) else {
                print("Could not generate JPEG data for image at index \(index). Skipping...")
                continue
            }
            
            let imgId = UUID()
            let filename = "image\(imgId).jpg"
            let imageKey = getImageKey(username: username, entryId: uuid, filename: filename)
            imageKeys.append(imageKey)
            
            let presignedURL = try await getPresignedURL(
                username: username,
                uuid: uuid,
                filename: filename
            )
            
            try await uploadImage(data, to: presignedURL)
            print("Successfully uploaded image \(imgId).jpg to S3!")
        }
        
        let updateResult = try await updateEntry(
            entryId: uuid,
            username: username,
            text: nil,
            images: imageKeys,
            locations: nil,
            tags: nil
        )
        
        if updateResult {
            print("Successfully updated entry!")
        } else {
            print("Unable to update entry!")
        }
        
        return UploadImagesReturns(
            success: updateResult,
            imageURLs: imageKeys
        )
    }
    
    func getPresignedURLForKey(_ key: String) async throws -> URL {
        guard var components = URLComponents(string: "\(baseURL)/entries/getImageURL") else {
            throw NetworkError.invalidURL
        }
        
        components.queryItems = [
            URLQueryItem(name: "key", value: key)
        ]
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            try addAuthenticationHeaders(to: &request)
        } catch {
            throw error
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.requestFailed
        }
        
        guard let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let urlString = dict["url"] as? String,
              let presignedURL = URL(string: urlString) else {
            throw NetworkError.decodingError
        }
        
        return presignedURL
    }
    
    func searchEntries(
        user: String,
        page: Int,
        limit: Int,
        searchQuery: String,
        filterOptions: FilterOptions
    ) async throws -> [EntryListItem] {
        guard var components = URLComponents(string: "\(baseURL)/entries/search") else {
            throw NetworkError.invalidURL
        }
        
        components.queryItems = [
            URLQueryItem(name: "user", value: user),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        try addAuthenticationHeaders(to: &request)
        
        let body = SearchEntriesBody(
            searchQuery: searchQuery,
            locations: Array(filterOptions.selectedLocations),
            tags: Array(filterOptions.selectedTags),
            sortRule: filterOptions.sortRule.id,
            timeframe: filterOptions.timeframe.id,
            fromDate: dateStringIfNeeded(filterOptions.fromDate),
            toDate: dateStringIfNeeded(filterOptions.toDate)
        )
        
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.requestFailed
        }
        
        return try JSONDecoder().decode([EntryListItem].self, from: data)
    }
    
    func fetchUniqueLocations(user: String) async throws -> [LocationData] {
        guard var components = URLComponents(string: "\(baseURL)/entries/listUniqueLocations") else {
            throw NetworkError.invalidURL
        }
        
        components.queryItems = [
            URLQueryItem(name: "user", value: user)
        ]
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        try addAuthenticationHeaders(to: &request)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.requestFailed
        }
        
        return try JSONDecoder().decode([LocationData].self, from: data)
    }
    
    func fetchUniqueTags(user: String) async throws -> [TagData] {
        guard var components = URLComponents(string: "\(baseURL)/entries/listUniqueTags") else {
            throw NetworkError.invalidURL
        }
        
        components.queryItems = [
            URLQueryItem(name: "user", value: user)
        ]
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        try addAuthenticationHeaders(to: &request)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.requestFailed
        }
        
        return try JSONDecoder().decode([TagData].self, from: data)
    }
    
    //
    // Helper functions are below
    //
    
    private func addAuthenticationHeaders(to request: inout URLRequest) throws {
        guard let apiKey = try AuthenticationManager.shared.getStoredAPIKey() else {
            throw NetworkError.authenticationError
        }
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        
        if let jwt = try AuthenticationManager.shared.getStoredJWT() {
            request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        }
    }
    
    private func dateStringIfNeeded(_ date: Date?) -> String? {
        guard let date = date else { return nil }
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: date)
    }
    
    private func getImageKey(username: String, entryId: String, filename: String) -> String {
        return "images/\(username)/\(entryId)/\(filename)"
    }
    
    private func getTimestampString() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: Date())
    }
    
    func tempInit() {
        do {
            let testJWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjIwNjAxMDM2OTgsImlhdCI6MTczODYwOTI5OCwidXNlcm5hbWUiOiJ0ZXN0In0.fBSANL0qfo-LTGl3tUDsunjjaNSryDatr-gdZsBS9xk"
            let testAPIKey = "sk_92e9b641349b8d3f6e85357092959b4660731f677ac12eea5ded9e78d7b1184e"
            
            try AuthenticationManager.shared.handleLoginResponse(LoginResponse(
                success: true,
                token: testJWT
            ))
            
            // Since APIKey comes from account creation, we'll need to store it directly
            try KeychainManager.shared.save(
                testAPIKey.data(using: .utf8)!,
                forKey: .apiKey
            )
            
            print("Successfully stored test credentials!")
        } catch {
            print("Error storing test credentials: \(error)")
        }
    }
}
