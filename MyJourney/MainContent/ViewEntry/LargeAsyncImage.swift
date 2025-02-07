//
//  LargeAsyncImage.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 2/6/25.
//

import SwiftUI

struct LargeAsyncImage: View {
    let url: URL
    let progressColor: Color
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .progressViewStyle(
                        CircularProgressViewStyle(tint: progressColor)
                    )
                    .tint(.white)
                    .padding()
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: UIScreen.main.bounds.width - 20)
                    .clipped()
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.8), radius: 3, x: 0, y: 2)
            case .failure(let error):
                Color.gray
                    .overlay(Text("Error").foregroundColor(.white))
                    .onAppear {
                        print("AsyncImage error for \(url): \(error.localizedDescription)")
                    }
            @unknown default:
                EmptyView()
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var presignedURL: URL?
        
        var body: some View {
            Group {
                if let url = presignedURL {
                    LargeAsyncImage(url: url, progressColor: .white)
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
