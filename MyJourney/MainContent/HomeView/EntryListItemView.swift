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
//    let onTap: (EntryListItem) -> Void
//    @Binding var path: NavigationPath
    
    @State private var presignedURLs: [URL] = []
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(getWeekdayStr(fromISO: entryListItem.timestamp))
                    .font(.custom("Nexa Script Heavy", size: 20))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(getFullDateStr(fromISO: entryListItem.timestamp))
                    .font(.custom("Nexa Script Heavy", size: 26))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "square.and.arrow.up")
                    .font(.title2)
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
//                        .onTapGesture {
//                            onTap(entryListItem)
//                        }
                    
                    Spacer()
                }
            }
            
            HStack {
                if entryListItem.locations.count >= 1 {
                    Image(systemName: "location")
                        .foregroundColor(.white)
                        .font(.title2)
                    Text(entryListItem.locations[0].displayName ?? "Unknown")
                        .font(.custom("Nexa Script Heavy", size: 16))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                if entryListItem.tags.count >= 1 {
                    Image(systemName: "tag")
                        .foregroundColor(.white)
                        .font(.title2)
                    Text(entryListItem.tags[0].key)
                        .font(.custom("Nexa Script Heavy", size: 16))
                        .foregroundColor(.white)
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
            if entryListItem.imageURLs.count > 0 {
                if presignedURLs.isEmpty {
                    Task {
                        await fetchPresignedURLs()
                    }
                }
            }
        }
    }
    
    private func fetchPresignedURLs() async {
        var tempURLs: [URL] = []
        for key in entryListItem.imageURLs {
            do {
                let presignedURL = try await getPresignedURLForKey(key)
                tempURLs.append(presignedURL)
            } catch {
                print("Presign GET error for \(key): \(error)")
            }
        }
        
        presignedURLs = tempURLs
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
            "images/test/07238b12-7eb5-42ca-888f-3d69c87a6258/image0.jpg",
            "images/test/07238b12-7eb5-42ca-888f-3d69c87a6258/image1.jpg",
            "images/test/07238b12-7eb5-42ca-888f-3d69c87a6258/image2.jpg"
        ],
        timestamp: "2025-01-26T06:19:51Z",
        locations: [LocationData(latitude: 47.61945051921359, longitude: -122.33775910597386, displayName: "Seattle")],
        tags: [TagData(key: "home", value: nil)]
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
