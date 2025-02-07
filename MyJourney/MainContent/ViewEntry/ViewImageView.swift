//
//  ViewImageView.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 2/6/25.
//

import SwiftUI

struct ViewImageView: View {
    @Binding var isViewImageViewVisible: Bool
    let imageURL: URL?
    let uiImage: UIImage?
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isViewImageViewVisible = false
                }
            
            VStack {
                VStack(alignment: .center) {
                    if imageURL != nil {
                        LargeAsyncImage(url: imageURL!, progressColor: .white)
                    } else if uiImage != nil {
                        Image(uiImage: uiImage!)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: UIScreen.main.bounds.width - 20)
                            .clipped()
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.8), radius: 3, x: 0, y: 2)
                    }
                    
                    Button(action: {
                        isViewImageViewVisible = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                        Spacer()
                        Text("Close")
                            .font(.custom("Nexa Script Heavy", size: 18))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .background(Color(red: 0.039, green: 0.549, blue: 0.749))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.008, green: 0.157, blue: 0.251), lineWidth: 2)
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .cornerRadius(12)
                .background(Color(red: 0.533, green: 0.875, blue: 0.949))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.008, green: 0.282, blue: 0.451), lineWidth: 2)
                )
            }
            .padding(10)
        }
    }
}

#Preview {
    ViewImageViewPreviewWrapper()
}

struct ViewImageViewPreviewWrapper: View {
    @State private var isViewImageViewVisible: Bool = true
    @State private var imageURL: URL? = URL(string: "https://winapps-myjourney.s3.us-west-2.amazonaws.com/images/test/07238b12-7eb5-42ca-888f-3d69c87a6258/image0.jpg")!
    @State private var uiImage: UIImage? = nil
    
    var body: some View {
        ViewImageView(
            isViewImageViewVisible: $isViewImageViewVisible,
            imageURL: imageURL,
            uiImage: uiImage
        )
    }
}
