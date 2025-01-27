//
//  EntryListItemView.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 1/25/25.
//

import SwiftUI

struct EntryListItemView: View {
    let entryListItem: EntryListItem
    
    @State private var presignedURLs: [URL] = []
    
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
                            
                            AsyncImage(url: presignedURLs[0]) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .progressViewStyle(
                                            CircularProgressViewStyle(tint: .white)
                                        )
                                        .tint(.white)
                                        .padding()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 108, height: 108)
                                        .clipped()
                                        .cornerRadius(8)
                                        .shadow(color: Color.black.opacity(0.8), radius: 3, x: 0, y: 2)
                                case .failure(_):
                                    Color.gray
                                        .frame(width: 108, height: 108)
                                        .overlay(Text("Error").foregroundColor(.white))
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    
                    if presignedURLs.count == 2 {
                        HStack {
                            Spacer()
                            
                            AsyncImage(url: presignedURLs[0]) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .progressViewStyle(
                                            CircularProgressViewStyle(tint: .white)
                                        )
                                        .tint(.white)
                                        .padding()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 108, height: 108)
                                        .clipped()
                                        .cornerRadius(8)
                                        .shadow(color: Color.black.opacity(0.8), radius: 3, x: 0, y: 2)
                                case .failure(_):
                                    Color.gray
                                        .frame(width: 108, height: 108)
                                        .overlay(Text("Error").foregroundColor(.white))
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            
                            Spacer()
                            
                            AsyncImage(url: presignedURLs[1]) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .progressViewStyle(
                                            CircularProgressViewStyle(tint: .white)
                                        )
                                        .tint(.white)
                                        .padding()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 108, height: 108)
                                        .clipped()
                                        .cornerRadius(8)
                                        .shadow(color: Color.black.opacity(0.8), radius: 3, x: 0, y: 2)
                                case .failure(_):
                                    Color.gray
                                        .frame(width: 108, height: 108)
                                        .overlay(Text("Error").foregroundColor(.white))
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    
                    if presignedURLs.count >= 3 {
                        ScrollView(.horizontal) {
                            HStack {
                                    ForEach(presignedURLs, id: \.self) { url in
                                        AsyncImage(url: url) {phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                                    .progressViewStyle(
                                                        CircularProgressViewStyle(tint: .white)
                                                    )
                                                    .tint(.white)
                                                    .padding()
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 108, height: 108)
                                                    .clipped()
                                                    .cornerRadius(8)
                                                    .shadow(color: Color.black.opacity(0.8), radius: 3, x: 0, y: 2)
                                            case .failure(_):
                                                Color.gray
                                                    .frame(width: 108, height: 108)
                                                    .overlay(Text("Error").foregroundColor(.white))
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                    }
                            }
                            .padding(.vertical, 7)
                            .padding(.horizontal, 3)
                        }
                    }
                }
            }
            
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
        }
//        .frame(maxWidth: 360)
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
                print("Attempting to fetch pre-signed url")
                let presignedURL = try await getPresignedURLForKey(key)
                print("url: ", presignedURL)
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
            "images/test/8d483fed-a0f7-46b7-ba97-d705ad6bba2b/image0.jpg",
            "images/test/8d483fed-a0f7-46b7-ba97-d705ad6bba2b/image1.jpg",
            "images/test/8d483fed-a0f7-46b7-ba97-d705ad6bba2b/image2.jpg"
        ],
        timestamp: "2025-01-26T06:19:51Z"
    )
}

#Preview {
    EntryListItemView(entryListItem: .mock)
}
