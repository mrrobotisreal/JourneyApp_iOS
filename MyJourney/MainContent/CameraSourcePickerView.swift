//
//  CameraSourcePickerView.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 2/5/25.
//

import SwiftUI
import UIKit

struct CameraSourcePickerView: View {
    @Binding var isCameraSourcePickerViewVisible: Bool
    @State private var source: UIImagePickerController.SourceType = .photoLibrary
    
    var onSourcePicked: (UIImagePickerController.SourceType) -> Void
    
    var body: some View {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Tapping outside closes the modal
                        isCameraSourcePickerViewVisible = false
                        print("clicked")
                    }
                    
                VStack {
                    VStack(alignment: .leading, spacing: 20) {
                        Button(action: {
                            source = .camera
                            isCameraSourcePickerViewVisible = false
                            onSourcePicked(source)
                        }) {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.white)
                            Spacer()
                            Text("Take A Photo")
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
                        
                        Button(action: {
                            source = .photoLibrary
                            isCameraSourcePickerViewVisible = false
                            onSourcePicked(source)
                        }) {
                            Image(systemName: "photo.fill.on.rectangle.fill")
                                .foregroundColor(.white)
                            Spacer()
                            Text("Choose Photos")
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
                        
                        Button(action: {
                            isCameraSourcePickerViewVisible = false
                        }) {
                            Image(systemName: "text.badge.xmark")
                                .foregroundColor(.white)
                            Spacer()
                            Text("Cancel")
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
                    .frame(maxWidth: .infinity)
                    .padding()
                    .cornerRadius(12)
                    .background(Color(red: 0.533, green: 0.875, blue: 0.949))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.008, green: 0.282, blue: 0.451), lineWidth: 2)
                    )
                }
                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 200 : 10)
            }
    }
}

#Preview {
    CameraSourcePickerViewPreviewWrapper()
}

struct CameraSourcePickerViewPreviewWrapper: View {
    @State private var isCameraSourcePickerViewVisible: Bool = true
    
    var body: some View {
        CameraSourcePickerView(isCameraSourcePickerViewVisible: $isCameraSourcePickerViewVisible, onSourcePicked: { source in
        })
    }
}

