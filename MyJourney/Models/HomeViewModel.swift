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
    
    func fetchEntries(username: String) {
        guard !isLoading, hasMore else { return }
        
        isLoading = true
        
        Task {
            do {
                let newEntries = try await fetchEntriesFromServer(username: username, page: page, limit: 10)
                
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
    
    private func fetchEntriesFromServer(username: String, page: Int, limit: Int) async throws -> [EntryListItem] {
        let base = "https://journeyapp.me/api/entries/list"
        guard var components = URLComponents(string: base) else {
            throw URLError(.badURL)
        }
        components.queryItems = [
            URLQueryItem(name: "user", value: username),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode([EntryListItem].self, from: data)
    }
    
    func searchEntries(
        user: String,
        page: Int,
        limit: Int,
        filterOptions: FilterOptions,
        searchQuery: String
    ) {
        isLoading = true
        
        Task {
            do {
                let newEntries = try await searchEntriesOnServer(
                    user: user,
                    page: page,
                    limit: limit,
                    searchQuery: searchQuery,
                    filterOptions: filterOptions
                )
                self.entries = newEntries
            } catch {
                print("Error search entries: \(error)")
                // TODO: Handle error
            }
            isLoading = false
        }
    }
    
    private func searchEntriesOnServer(
        user: String,
        page: Int,
        limit: Int,
        searchQuery: String,
        filterOptions: FilterOptions
    ) async throws -> [EntryListItem] {
        guard var components = URLComponents(string: "https://journeyapp.me/api/entries/search") else {
            throw URLError(.badURL)
        }
        components.queryItems = [
            URLQueryItem(name: "user", value: user),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        guard let url = components.url else {
            throw URLError(.badURL)
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
        
        let body = SearchEntriesBody(
            searchQuery: searchQuery,
            locations: Array(filterOptions.selectedLocations),
            tags: Array(filterOptions.selectedTags),
            sortRule: filterOptions.sortRule.rawValue,
            timeframe: filterOptions.timeframe.rawValue,
            fromDate: dateStringIfNeeded(filterOptions.fromDate),
            toDate: dateStringIfNeeded(filterOptions.toDate)
        )
        
        let jsonData = try JSONEncoder().encode(body)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode([EntryListItem].self, from: data)
        
        return decoded
    }
    
    private func dateStringIfNeeded(_ date: Date?) -> String? {
        guard let date = date else { return nil }
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: date)
    }
    
    func fetchUniqueLocationsAndTags(user: String) {
        isLoading = true
        
        Task {
            do {
                let uniqueLocations = try await fetchUniqueLocationsFromServer(user: user)
                let uniqueTags = try await fetchUniqueTagsFromServer(user: user)
                
                allUniqueLocations = uniqueLocations
                allUniqueTags = uniqueTags
            } catch {
                print("Error getting unique locations and/or tags \(error)")
                // TODO: handle errors
            }
            isLoading = false
        }
    }
    
    private func fetchUniqueLocationsFromServer(user: String) async throws -> [LocationData] {
        let base = "https://journeyapp.me/api/entries/listUniqueLocations"
        guard var components = URLComponents(string: base) else {
            throw URLError(.badURL)
        }
        components.queryItems = [
            URLQueryItem(name: "user", value: user)
        ]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode([LocationData].self, from: data)
    }
    
    private func fetchUniqueTagsFromServer(user: String) async throws -> [TagData] {
        let base = "https://journeyapp.me/api/entries/listUniqueTags"
        guard var components = URLComponents(string: base) else {
            throw URLError(.badURL)
        }
        components.queryItems = [
            URLQueryItem(name: "user", value: user)
        ]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode([TagData].self, from: data)
    }
}

enum Route: Hashable {
    case createNewEntry
    case viewEntry
    case settings
}
