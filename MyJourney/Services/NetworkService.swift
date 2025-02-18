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
    private let baseURL = "https://api.journeyapp.me/api"
    
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
    
    func deleteAccount(apiKey: String, jwt: String, username: String) async throws -> DeleteAccountResponse {
        guard var components = URLComponents(string: "\(baseURL)/users/delete") else {
            throw NetworkError.invalidURL
        }
        
        components.queryItems = [
            URLQueryItem(name: "user", value: username)
        ]
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        
//        do {
//            try addAuthenticationHeaders(to: &request)
//        } catch {
//            throw error
//        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.requestFailed
        }
        
        do {
            let deleteAccountResponse = try JSONDecoder().decode(DeleteAccountResponse.self, from: data)
            return deleteAccountResponse
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    //
    // Entry API calls
    //
    
    func createNewEntry(
        apiKey: String,
        jwt: String,
        userId: String,
        username: String,
        text: String,
        images: [String]?,
        locations: [LocationData]?,
        tags: [TagData]?
    ) async throws -> CreateNewEntryResponse {
        guard let url = URL(string: "\(baseURL)/entries/create") else {
            print("It's the url at the beginning")
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        
//        do {
//            try addAuthenticationHeaders(to: &request)
//        } catch {
//            print("It's the addAuthentication headers")
//            throw error
//        }
        
        let timestamp = getTimestampString()
        let requestBody = CreateNewEntryRequest(
            userId: userId,
            username: username,
            text: text,
            timestamp: timestamp,
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
        
        do {
            let decoded = try JSONDecoder().decode(CreateNewEntryResponse.self, from: data)
            return decoded
        } catch {
            print("It's the decoder")
            throw NetworkError.decodingError
        }
    }
    
    func updateEntry(
        apiKey: String,
        jwt: String,
        entryId: String,
        userId: String,
        username: String,
        timestamp: String,
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
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        
//        do {
//            try addAuthenticationHeaders(to: &request)
//        } catch {
//            throw error
//        }
        
        let requestBody = UpdateEntryRequest(
            id: entryId,
            userId: userId,
            username: username,
            timestamp: timestamp,
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
        apiKey: String,
        jwt: String,
        username: String,
        id: String,
        filename: String
    ) async throws -> URL {
        guard var components = URLComponents(string: "\(baseURL)/entries/getPresignedPutURL") else {
            throw NetworkError.invalidURL
        }
        
        components.queryItems = [
            URLQueryItem(name: "user", value: username),
            URLQueryItem(name: "entryId", value: id),
            URLQueryItem(name: "filename", value: filename)
        ]
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        
//        try addAuthenticationHeaders(to: &request)
        
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
        
        print("Got the presigned Put URL successfully!!!")
        
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
        apiKey: String,
        jwt: String,
        userId: String,
        username: String,
        timestamp: String,
        id: String,
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
            let imageKey = getImageKey(username: username, entryId: id, filename: filename)
            imageKeys.append(imageKey)
            
            let presignedURL = try await getPresignedURL(
                apiKey: apiKey,
                jwt: jwt,
                username: username,
                id: id,
                filename: filename
            )
            print("Presigned URL: \(presignedURL)")
            
            try await uploadImage(data, to: presignedURL)
            print("Successfully uploaded image \(imgId).jpg to S3!")
        }
        
        let updateResult = try await updateEntry(
            apiKey: apiKey,
            jwt: jwt,
            entryId: id,
            userId: userId,
            username: username,
            timestamp: timestamp,
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
    
    func getPresignedURLForKey(_ key: String, apiKey: String, jwt: String) async throws -> URL {
        guard var components = URLComponents(string: "\(baseURL)/entries/getPresignedGetURL") else {
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
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        
//        do {
//            try addAuthenticationHeaders(to: &request)
//        } catch {
//            throw error
//        }
        
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
    
    func deleteEntry(apiKey: String, jwt: String, userId: String, username: String, timestamp: String, id: String) async throws -> DeleteEntryResponse {
        guard var components = URLComponents(string: "\(baseURL)/entries/delete") else {
            throw NetworkError.invalidURL
        }
        
        components.queryItems = [
            URLQueryItem(name: "id", value: id),
            URLQueryItem(name: "user", value: username)
        ]
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        
        let body = DeleteEntryRequest(
            userId: userId, timestamp: timestamp
        )
        
        request.httpBody = try JSONEncoder().encode(body)
        
//        do {
//            try addAuthenticationHeaders(to: &request)
//        } catch {
//            throw error
//        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.requestFailed
        }
        
        do {
            let deleteEntryResponse = try JSONDecoder().decode(DeleteEntryResponse.self, from: data)
            return deleteEntryResponse
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func searchEntries(
        apiKey: String,
        jwt: String,
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
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        
//        try addAuthenticationHeaders(to: &request)
        
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
    
    func fetchUniqueLocations(apiKey: String, jwt: String, user: String) async throws -> [LocationData] {
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
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        
//        try addAuthenticationHeaders(to: &request)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.requestFailed
        }
        
        return try JSONDecoder().decode([LocationData].self, from: data)
    }
    
    func fetchUniqueTags(apiKey: String, jwt: String, user: String) async throws -> [TagData] {
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
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        
//        try addAuthenticationHeaders(to: &request)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.requestFailed
        }
        
        return try JSONDecoder().decode([TagData].self, from: data)
    }
    
    func addTag(apiKey: String, jwt: String, username: String, userId: String, timestamp: String, entryId: String, tags: [TagData]) async throws -> AddTagResponse {
        guard let url = URL(string: "\(baseURL)/entries/addTag") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        
        let body = AddTagRequest(
            username: username, userId: userId, timestamp: timestamp, entryId: entryId, tags: tags
        )
        
        request.httpBody = try JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            // Handle data...
        }
        task.resume()
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.requestFailed
        }
        
        return try JSONDecoder().decode(AddTagResponse.self, from: data)
    }
    
    func deleteTag(apiKey: String, jwt: String, username: String, userId: String, timestamp: String, entryId: String, tags: [TagData]) async throws -> DeleteTagResponse {
        guard let url = URL(string: "\(baseURL)/entries/deleteTag") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        
        let body = DeleteTagRequest(
            username: username, userId: userId, timestamp: timestamp, entryId: entryId, tags: tags
        )
        
        request.httpBody = try JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            // Handle data...
        }
        task.resume()
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.requestFailed
        }
        
        return try JSONDecoder().decode(DeleteTagResponse.self, from: data)
    }
    
    func addLocation(apiKey: String, jwt: String, username: String, userId: String, timestamp: String, entryId: String, locations: [LocationData]) async throws -> AddLocationResponse {
        guard let url = URL(string: "\(baseURL)/entries/addLocation") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        
        let body = AddLocationRequest(
            username: username, userId: userId, timestamp: timestamp, entryId: entryId, locations: locations
        )
        
        request.httpBody = try JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            // Handle data...
        }
        task.resume()
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.requestFailed
        }
        
        return try JSONDecoder().decode(AddLocationResponse.self, from: data)
    }
    
    func deleteLocation(apiKey: String, jwt: String, username: String, userId: String, timestamp: String, entryId: String, locations: [LocationData]) async throws -> DeleteLocationResponse {
        guard let url = URL(string: "\(baseURL)/entries/deleteLocation") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        
        let body = DeleteLocationRequest(
            username: username, userId: userId, timestamp: timestamp, entryId: entryId, locations: locations
        )
        
        request.httpBody = try JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            // Handle data...
        }
        task.resume()
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.requestFailed
        }
        
        return try JSONDecoder().decode(DeleteLocationResponse.self, from: data)
    }
    
    func addImage(apiKey: String, jwt: String, username: String, userId: String, timestamp: String, entryId: String, images: [String]) async throws -> AddImageResponse {
        guard let url = URL(string: "\(baseURL)/entries/addImage") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        
        let body = AddImageRequest(
            username: username, userId: userId, timestamp: timestamp, entryId: entryId, images: images
        )
        
        request.httpBody = try JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            // Handle data...
        }
        task.resume()
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.requestFailed
        }
        
        return try JSONDecoder().decode(AddImageResponse.self, from: data)

    }
    
    func deleteImage(apiKey: String, jwt: String, username: String, userId: String, timestamp: String, entryId: String, images: [String], imageToDelete: String) async throws -> DeleteImageResponse {
        guard let url = URL(string: "\(baseURL)/entries/deleteImage") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        
        let body = DeleteImageRequest(
            username: username, userId: userId, timestamp: timestamp, entryId: entryId, images: images, imageToDelete: imageToDelete
        )
        
        request.httpBody = try JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            // Handle data...
        }
        task.resume()
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.requestFailed
        }
        
        return try JSONDecoder().decode(DeleteImageResponse.self, from: data)
    }
    
    //
    // Helper functions are below
    //
    
    func addAuthenticationHeaders(to request: inout URLRequest) throws {
        do {
            print("trying apiKey now")
            guard let apiKey = try AuthenticationManager.shared.getStoredAPIKey() else {
                print("Something's up with the apiKey in addAuthHeaders")
                throw NetworkError.authenticationError
            }
            request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        } catch {
            print("getStoredAPIKey ERROR: \(error)")
        }
        
        do {
            print("trying JWT bullshit now")
            if let jwt = try AuthenticationManager.shared.getStoredJWT() {
                request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
            } else {
                print("Something's up with the JWT in addAuthHeaders")
            }
        } catch {
            print("getStoredJWT ERROR: \(error)")
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
//            let testJWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjIwNjAxMDM2OTgsImlhdCI6MTczODYwOTI5OCwidXNlcm5hbWUiOiJ0ZXN0In0.fBSANL0qfo-LTGl3tUDsunjjaNSryDatr-gdZsBS9xk"
//            let testAPIKey = "sk_92e9b641349b8d3f6e85357092959b4660731f677ac12eea5ded9e78d7b1184e"
            let testJWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjIwNjA1NTQxNTIsImlhdCI6MTczOTA1OTc1MiwidXNlcm5hbWUiOiJkZWxldGVhYmxlIn0.bYlNuXDLAzhKKDcXgMRUtvqm6bjsaE8lb6BMmQV2EL4"
            let testAPIKey = "sk_a2d7dda5be53ecb9fa14035d93c33fcf8b076bd7b75c71c6281a9a79f4111823"
            
            try AuthenticationManager.shared.handleLoginResponse(LoginResponse(
                success: true,
                userId: "efbb99ac-42dc-4557-8364-abcd57993b8a",
                username: "mwintrow",
                token: testJWT,
                apiKey: testAPIKey,
                font: "Default"
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
