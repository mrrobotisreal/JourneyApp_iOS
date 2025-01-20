//
//  NewEntryView.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 1/19/25.
//

import SwiftUI
import UIKit

struct NewEntryView: View {
    @State private var showCameraSheet: Bool = false
    @State private var hasImages: Bool = false
    @State private var images: [UIImage] = []
    @State private var showImagePicker = false
    @State private var pickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var entryText: String = ""
    
    var body: some View {
        ZStack {
            Color(red: 0.533, green: 0.875, blue: 0.949)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Button(action: {
                        // action here...
                    }) {
                        Text("Cancel")
                            .font(.custom("Nexa Script Light", size: 18))
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    Spacer()
                    
                    Text("19 January 2025")
                        .padding()
                        .font(.custom("Nexa Script Heavy", size: 24))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        // action here...
                    }) {
                        Text("Save")
                            .font(.custom("Nexa Script Light", size: 18))
                            .foregroundColor(.white)
                    }
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.008, green: 0.282, blue: 0.451))
                
                Spacer()
                
                VStack {
                    if hasImages {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(images, id: \.self) { img in
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipped()
                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                    }
                    
                    ScrollView(.vertical) {
                        TextField("Start writing your entry here...", text: $entryText)
                            .font(.custom("Nexa Script Light", size: 18))
                            .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                            .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding()
                }
                .frame(maxWidth: 360)
                .frame(maxHeight: 600)
                .padding()
                .cornerRadius(12)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.008, green: 0.282, blue: 0.451), lineWidth: 2)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        // action here...
                    }) {
                        Image(systemName: "location.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    
                    Spacer()
                    
                    Button(action: {
                        // action here...
                    }) {
                        Image(systemName: "person.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    
                    Spacer()
                    
                    Button(action: {
                        showCameraSheet = true
//                        pickerSource = .photoLibrary
//                        showImagePicker = true
                    }) {
                        Image(systemName: "camera.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    
                    Spacer()
                    
                    Button(action: {
                        // action here...
                    }) {
                        Image(systemName: "tag.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.008, green: 0.282, blue: 0.451))
                
                if showCameraSheet {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showCameraSheet = false
                        }
                    
                    VStack(spacing: 16) {
                        Text("Main Menu")
                            .font(.custom("Nexa Script Heavy", size: 18))
                        
                        Button(action: {
                            // action here...
                        }) {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.white)
                            Spacer()
                            Text("Take A Photo")
                                .font(.custom("Nexa Script Heavy", size: 18))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .frame(minWidth: 300, maxWidth: 300)
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
                            // action here...
                        }) {
                            Image(systemName: "photo.fill.on.rectangle.fill")
                                .foregroundColor(.white)
                            Spacer()
                            Text("Choose Photos")
                                .font(.custom("Nexa Script Heavy", size: 18))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .frame(minWidth: 300, maxWidth: 300)
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
                            showCameraSheet = false
                        }) {
                            Image(systemName: "text.badge.xmark")
                                .foregroundColor(.white)
                            Spacer()
                            Text("Cancel")
                                .font(.custom("Nexa Script Heavy", size: 18))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .frame(minWidth: 300, maxWidth: 300)
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
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)))
                    .animation(.easeInOut, value: showCameraSheet)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                    .background(Color(red: 0.533, green: 0.875, blue: 0.949))
                    .cornerRadius(20)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(red: 0.008, green: 0.157, blue: 0.251), lineWidth: 4)
                    )
                    .shadow(radius: 5)
                    .frame(height: 300)
                    .offset(y: UIScreen.main.bounds.height - 900)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: pickerSource) { uiImage in
                    if images.count < 3 {
                        images.append(uiImage)
                    }
                }
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.onImagePicked(uiImage)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    NewEntryView()
}
