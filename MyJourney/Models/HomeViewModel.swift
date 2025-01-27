//
//  HomeViewModel.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 1/25/25.
//

import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    @Published var entries: [EntryListItem] = []
    @Published var isLoading = false
    @Published var hasMore = true
    @Published var page = 0
    
    func fetchEntries(username: String) {
        guard !isLoading, hasMore else { return }
        
        isLoading = true
        
        Task {
            do {
                print("Fetching entries from server...")
                let newEntries = try await fetchEntriesFromServer(username: username, page: page, limit: 10)
                
                if newEntries.count < 10 {
                    self.hasMore = false
                }
                print("NewEntries count:", newEntries.count)
                
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
}
