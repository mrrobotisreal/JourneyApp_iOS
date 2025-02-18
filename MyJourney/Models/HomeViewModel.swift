//
//  HomeViewModel.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 1/25/25.
//

import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var entries: [EntryListItem] = []
    @Published var isLoading = false
    @Published var hasMore = true
    @Published var page = 0
    @Published var allUniqueLocations: [LocationData] = []
    @Published var allUniqueTags: [TagData] = []
    
    func fetchEntries(apiKey: String, jwt: String, userId: String, username: String) {
        guard !self.isLoading, self.hasMore else { return }
        
        self.isLoading = true
        
        Task {
            do {
                let newEntries = try await fetchEntriesFromServer(apiKey: apiKey, jwt: jwt, userId: userId, username: username, page: page, limit: 20)
                
                if newEntries.count < 10 {
                    self.hasMore = false
                }
                
                DispatchQueue.main.async {
                    self.entries.append(contentsOf: newEntries)
                    self.page += 1
                    self.isLoading = false
                }
            } catch {
                print("Error fetching entries: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
    
    private func fetchEntriesFromServer(apiKey: String, jwt: String, userId: String, username: String, page: Int, limit: Int) async throws -> [EntryListItem] {
        let base = "https://api.journeyapp.me/api/entries/list"
        guard var components = URLComponents(string: base) else {
            throw URLError(.badURL)
        }
        components.queryItems = [
            URLQueryItem(name: "user", value: username),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "sortRule", value: "newest")
        ]
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        
//        do {
//            try NetworkService.shared.addAuthenticationHeaders(to: &request)
//        } catch {
//            throw error
//        }
        
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
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode([EntryListItem].self, from: data)
    }
    
    func searchEntries(
        apiKey: String,
        jwt: String,
        user: String,
        page: Int,
        limit: Int,
        filterOptions: FilterOptions,
        searchQuery: String
    ) async {
        self.isLoading = true
        
        Task {
            do {
//                let newEntries = try await searchEntriesOnServer(
//                    user: user,
//                    page: page,
//                    limit: limit,
//                    searchQuery: searchQuery,
//                    filterOptions: filterOptions
//                )
                print("new search running...")
                let newEntries = try await NetworkService.shared.searchEntries(
                    apiKey: apiKey,
                    jwt: jwt,
                    user: user,
                    page: page,
                    limit: limit,
                    searchQuery: searchQuery,
                    filterOptions: filterOptions
                )
                if (!self.entries.isEmpty && !newEntries.isEmpty) || (self.entries.isEmpty && !newEntries.isEmpty) {
                    self.entries = []
                    self.entries = newEntries
                }
                if (!self.entries.isEmpty && newEntries.isEmpty) || (self.entries.isEmpty && newEntries.isEmpty) {
                    self.entries = []
                }
            } catch {
                print("Error search entries: \(error)")
                // TODO: Handle error
            }
            self.isLoading = false
        }
    }
    
//    private func searchEntriesOnServer(
//        user: String,
//        page: Int,
//        limit: Int,
//        searchQuery: String,
//        filterOptions: FilterOptions
//    ) async throws -> [EntryListItem] {
//        guard var components = URLComponents(string: "https://journeyapp.me/api/entries/search") else {
//            throw URLError(.badURL)
//        }
//        components.queryItems = [
//            URLQueryItem(name: "user", value: user),
//            URLQueryItem(name: "page", value: "\(page)"),
//            URLQueryItem(name: "limit", value: "\(limit)")
//        ]
//        
//        guard let url = components.url else {
//            throw URLError(.badURL)
//        }
//        
//        struct SearchEntriesBody: Encodable {
//            let searchQuery: String
//            let locations: [LocationData]
//            let tags: [TagData]
//            let sortRule: String
//            let timeframe: String
//            let fromDate: String?
//            let toDate: String?
//        }
//        
//        let body = SearchEntriesBody(
//            searchQuery: searchQuery,
//            locations: Array(filterOptions.selectedLocations),
//            tags: Array(filterOptions.selectedTags),
//            sortRule: filterOptions.sortRule.rawValue,
//            timeframe: filterOptions.timeframe.rawValue,
//            fromDate: dateStringIfNeeded(filterOptions.fromDate),
//            toDate: dateStringIfNeeded(filterOptions.toDate)
//        )
//        
//        let jsonData = try JSONEncoder().encode(body)
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = jsonData
//        
//        let (data, response) = try await URLSession.shared.data(for: request)
//        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
//            throw URLError(.badServerResponse)
//        }
//        
//        let decoded = try JSONDecoder().decode([EntryListItem].self, from: data)
//        
//        return decoded
//    }
    
//    private func dateStringIfNeeded(_ date: Date?) -> String? {
//        guard let date = date else { return nil }
//        let formatter = ISO8601DateFormatter()
//        return formatter.string(from: date)
//    }
    
    func fetchUniqueLocationsAndTags(apiKey: String, jwt: String, user: String) {
        self.isLoading = true
        
        Task {
            do {
//                let uniqueLocations = try await fetchUniqueLocationsFromServer(user: user)
//                let uniqueTags = try await fetchUniqueTagsFromServer(user: user)
                
                let uniqueLocations = try await NetworkService.shared.fetchUniqueLocations(apiKey: apiKey, jwt: jwt, user: user)
                let uniqueTags = try await NetworkService.shared.fetchUniqueTags(apiKey: apiKey, jwt: jwt, user: user)
                
                self.allUniqueLocations = uniqueLocations
                self.allUniqueTags = uniqueTags
            } catch {
                print("Error getting unique locations and/or tags: \(error)")
                // TODO: handle errors
            }
            self.isLoading = false
        }
    }
    
//    private func fetchUniqueLocationsFromServer(user: String) async throws -> [LocationData] {
//        let base = "https://journeyapp.me/api/entries/listUniqueLocations"
//        guard var components = URLComponents(string: base) else {
//            throw URLError(.badURL)
//        }
//        components.queryItems = [
//            URLQueryItem(name: "user", value: user)
//        ]
//        
//        guard let url = components.url else {
//            throw URLError(.badURL)
//        }
//        let (data, response) = try await URLSession.shared.data(from: url)
//        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
//            throw URLError(.badServerResponse)
//        }
//        
//        let decoder = JSONDecoder()
//        return try decoder.decode([LocationData].self, from: data)
//    }
//    
//    private func fetchUniqueTagsFromServer(user: String) async throws -> [TagData] {
//        let base = "https://journeyapp.me/api/entries/listUniqueTags"
//        guard var components = URLComponents(string: base) else {
//            throw URLError(.badURL)
//        }
//        components.queryItems = [
//            URLQueryItem(name: "user", value: user)
//        ]
//        
//        guard let url = components.url else {
//            throw URLError(.badURL)
//        }
//        let (data, response) = try await URLSession.shared.data(from: url)
//        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
//            throw URLError(.badServerResponse)
//        }
//        
//        let decoder = JSONDecoder()
//        return try decoder.decode([TagData].self, from: data)
//    }
}

extension Notification.Name {
    static let newEntryCreated = Notification.Name("newEntryCreated")
}

enum Route: Hashable {
    case createNewEntry
    case viewEntry
    case settings
}
