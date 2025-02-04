//
//  EntryListItemView.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 1/25/25.
//

import SwiftUI

struct EntryListItemView: View {
    let entryListItem: EntryListItem
    let query: String
    
    @State private var presignedURLs: [URL] = []
    @State private var isLoading: Bool = false
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(getWeekdayStr(fromISO: entryListItem.timestamp))
                    .font(.custom("Nexa Script Heavy", size: 16))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(getFullDateStr(fromISO: entryListItem.timestamp))
                    .font(.custom("Nexa Script Heavy", size: 20))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(getTimeStr(fromISO: entryListItem.timestamp))
                    .font(.custom("Nexa Script Heavy", size: 16))
                    .foregroundColor(.white)
            }
            
            if !entryListItem.imageURLs.isEmpty {
                if presignedURLs.isEmpty {
                    Text("Loading images...")
                        .foregroundColor(.gray)
                } else {
                    if presignedURLs.count == 1 {
                        HStack {
                            Spacer()
                            
                            ResilientAsyncImage(url: presignedURLs[0], progressColor: .white)
                            
                            Spacer()
                        }
                    }
                    
                    if presignedURLs.count == 2 {
                        HStack {
                            Spacer()
                            
                            ResilientAsyncImage(url: presignedURLs[0], progressColor: .white)
                            
                            Spacer()
                            
                            ResilientAsyncImage(url: presignedURLs[1], progressColor: .white)
                            
                            Spacer()
                        }
                    }
                    
                    if presignedURLs.count >= 3 {
                        ScrollView(.horizontal) {
                            HStack {
                                    ForEach(presignedURLs, id: \.self) { url in
                                        ResilientAsyncImage(url: url, progressColor: .white)
                                    }
                            }
                            .padding(.vertical, 7)
                            .padding(.horizontal, 3)
                        }
                    }
                }
            }
            
            let matches = findSubstrings(in: entryListItem.text, query: query)
            if matches.isEmpty {
                let attributed = parseAdvancedMarkdown(entryListItem.text)
                HStack {
                    Spacer()
                    
                    Text(attributed)
                        .font(.custom("Nexa Script Light", size: 14))
                        .foregroundColor(.white)
                        .lineLimit(3)
                        .truncationMode(.tail)
                    
                    Spacer()
                }
            } else {
                let highlighted = highlightSubstringMatches(text: entryListItem.text, matches: matches)
                HStack {
                    Spacer()
                    
                    Text(highlighted)
                        .padding()
                        .cornerRadius(12)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.008, green: 0.157, blue: 0.251), lineWidth: 2)
                        )
                    
                    Spacer()
                }
            }
            
            HStack {
                let locs = entryListItem.locations.prefix(3).map { IdentifiableLocationData(
                    latitude: $0.latitude,
                    longitude: $0.longitude,
                    displayName: $0.displayName
                ) }
                VStack(alignment: .leading) {
                    if !locs.isEmpty {
                        HStack {
                            Image(systemName: "location")
                                .foregroundColor(.white)
                                .font(.title2)
                            Text("Locations:")
                                .font(.custom("Nexa Script Heavy", size: 16))
                                .foregroundColor(.white)
                        }
                    }
                    
                    ForEach(locs) { loc in
                        Text("• \(loc.displayName ?? "Unknown location")")
                            .padding(.horizontal)
                            .font(.custom("Nexa Script Light", size: 16))
                            .foregroundColor(.white)
                    }
                    
                    if !entryListItem.locations.isEmpty && entryListItem.locations.count > 3 {
                        Text("+\(entryListItem.locations.count - 3) more...")
                            .padding(.horizontal)
                            .font(.custom("Nexa Script Light", size: 16))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                
                let tags = entryListItem.tags.prefix(3).map { IdentifiableTagData(
                    key: $0.key,
                    value: $0.value
                ) }
                VStack(alignment: .leading) {
                    if !tags.isEmpty {
                        HStack {
                            Image(systemName: "tag")
                                .foregroundColor(.white)
                                .font(.title2)
                            Text("Tags:")
                                .font(.custom("Nexa Script Heavy", size: 16))
                                .foregroundColor(.white)
                        }
                    }
                    
                    ForEach(tags) { tag in
                        HStack {
                            Text("• \(tag.key)")
                                .font(.custom("Nexa Script Light", size: 16))
                                .foregroundColor(.white)
                                
                            if let value = tag.value {
                                Text("(\(value))")
                                    .font(.custom("Nexa Script Light", size: 16))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    if !entryListItem.tags.isEmpty && entryListItem.tags.count > 3 {
                        Text("+\(entryListItem.tags.count - 3) more...")
                            .padding(.horizontal)
                            .font(.custom("Nexa Script Light", size: 16))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding()
        .cornerRadius(12)
        .background(Color(red: 0.039, green: 0.549, blue: 0.749))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.008, green: 0.157, blue: 0.251), lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.9), radius: 7, x: 0, y: 5)
        .onAppear {
            if !entryListItem.imageURLs.isEmpty && presignedURLs.isEmpty {
                isLoading = true
                
                Task {
                    do {
                         await fetchPresignedURLs()
                    } catch {
                        print("Error in onAppear task: \(error)")
                    }
                    isLoading = false
                }
            }
        }
    }
    
    private func fetchPresignedURLs() async {
        var tempURLs: [URL] = []
        
        for (_, key) in entryListItem.imageURLs.enumerated() {
            do {
                let presignedURL = try await NetworkService.shared.getPresignedURLForKey(key)
                tempURLs.append(presignedURL)
            } catch {
                print("Error getting presigned URL for \(key): \(error)")
            }
        }
        
        await MainActor.run {
            self.presignedURLs = tempURLs
        }
    }
}

extension EntryListItem {
    static let mock = EntryListItem(
        id: "8d483fed-a0f7-46b7-ba97-d705ad6bba2b",
        text: """
    # My Title
    Some text with *bold* and ~underline~, which also should wrap around since this sentence is actually very long y'all.
    - A bullet list item
    - [ ] An unchecked checkbox
    
    ## Subheading
    
    Here is -strikethrough- and {color: red}red text{color} and nesting like *bold ~underlined nested~ inside*.
    """,
        imageURLs: [
//            "images/test/07238b12-7eb5-42ca-888f-3d69c87a6258/image0.jpg",
//            "images/test/07238b12-7eb5-42ca-888f-3d69c87a6258/image1.jpg",
            "images/test/07238b12-7eb5-42ca-888f-3d69c87a6258/image2.jpg"
        ],
        timestamp: "2025-01-26T06:19:51Z",
        locations: [LocationData(latitude: 47.61945051921359, longitude: -122.33775910597386, displayName: "Seattle"), LocationData(latitude: 47.61945051921359, longitude: -122.33775910597386, displayName: "Vancouver"), LocationData(latitude: 47.61945051921359, longitude: -122.33775910597386, displayName: "Delta"), LocationData(latitude: 47.61945051921359, longitude: -122.33775910597386, displayName: "Kyiv"), LocationData(latitude: 47.61945051921359, longitude: -122.33775910597386, displayName: "Vienna")],
        tags: [TagData(key: "Home", value: "Seattle"), TagData(key: "Home", value: "Vancouver"), TagData(key: "Home", value: "Delta"), TagData(key: "Vacation", value: "Kyiv")]
    )
}

#Preview {
    let testAppState = AppState()
    testAppState.isLoggedIn = true
    testAppState.username = "test"
    
    return EntryListViewPreviewWrapper().environmentObject(testAppState)
}

struct EntryListViewPreviewWrapper: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        EntryListItemView(entryListItem: .mock, query: "wrap")
    }
}
