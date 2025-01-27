//
//  ResilientAsyncImage.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 1/27/25.
//

import SwiftUI

/// ResilientAsyncImage is simply a SwiftUI AsyncImage that attempts to load an image,
/// but if SwiftUI previously canceled the request (i.e. image goes off screen),
/// this view forces a refresh/refetch each time the view appears.
///
/// This is primarily for the HomeView, where EntryListItemView views are listed and
/// images are anticipated to frequently be on and off screen.
struct ResilientAsyncImage: View {
    let url: URL
    
    /// This uniquely identifies the AsyncImage, and when it changes,
    /// the AsyncImage is re-initialized.
    @State private var reloadID = UUID()
    
    var body: some View {
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
            case .failure(let error):
                Color.gray
                    .frame(width: 108, height: 108)
                    .overlay(Text("Error").foregroundColor(.white))
                    .onAppear {
                        print("AsyncImage error for \(url): \(error.localizedDescription)")
                    }
            @unknown default:
                EmptyView()
            }
        }
        .id(reloadID)
        .onAppear {
            reloadID = UUID()
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var presignedURL: URL?
        
        var body: some View {
            Group {
                if let url = presignedURL {
                    ResilientAsyncImage(url: url)
                } else {
                    Text("Loading presigned URL in preview...")
                }
            }
            .task {
                do {
                    presignedURL = try await getPresignedURLForKey("images/test/07238b12-7eb5-42ca-888f-3d69c87a6258/image0.jpg")
                } catch {
                    print("Preview error: \(error)")
                }
            }
        }
    }
    
    return PreviewWrapper()
}
