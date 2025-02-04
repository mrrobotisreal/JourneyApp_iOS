//
//  NewEntryView.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 1/19/25.
//

import SwiftUI
import UIKit
import CoreLocation
import MapKit

struct NewEntryView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var homeViewModel = HomeViewModel()
    @State private var isSubmitting: Bool = false
    @State private var isSavedSuccessfully: Bool = false
    @State private var showLocationSheet: Bool = false
    @State private var showLocationPicker: Bool = false
    @State private var showPeopleSheet: Bool = false
    @State private var showCameraSheet: Bool = false
    @State private var showTagsSheet: Bool = false
    @State private var showInfoSheet: Bool = false
    @State private var hasImages: Bool = false
    @State private var images: [UIImage] = []
    @State private var showImagePicker = false
    @State private var pickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var locations: [LocationData] = []
    @State private var tags: [TagData] = []
    @State private var entryText: String = ""
//    @State private var entryText: String = """
//    # My Title
//    
//    Some text with *bold* and ~underline~.
//    
//    - A bullet list item
//    - [ ] An unchecked checkbox
//    
//    ## Subheading
//    
//    Here is -strikethrough- and {color: red}red text{color} and nesting like *bold ~underlined nested~ inside*.
//    """
    @State private var editingLocationIndex: Int?
    @State private var isEnteringCustomName = false
    
    let date = getDateString()
    let timestamp = getTimestampString()
    
    enum ViewMode: String, CaseIterable {
        case write = "Write"
        case preview = "Preview"
    }
    
    @State private var selectedViewMode: ViewMode = .write
    
    var body: some View {
        ZStack {
            Color(red: 0.533, green: 0.875, blue: 0.949)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(.custom("Nexa Script Light", size: 18))
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    Spacer()
                    
                    Text(date)
                        .padding()
                        .font(.custom("Nexa Script Heavy", size: 24))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(
                                CircularProgressViewStyle(tint: Color(red: 0.533, green: 0.875, blue: 0.949))
                            )
                            .tint(Color(red: 0.533, green: 0.875, blue: 0.949))
                            .padding()
                    } else {
                        Button(action: {
                            submitEntry()
                        }) {
                            Text("Save")
                                .font(.custom("Nexa Script Light", size: 18))
                                .foregroundColor(.white)
                        }
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.008, green: 0.282, blue: 0.451))
                
                Spacer()
                
                VStack {
                    if images.count > 0 {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(images, id: \.self) { img in
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 112, height: 112)
                                        .clipped()
                                        .cornerRadius(8)
                                        .shadow(color: Color.black.opacity(0.8), radius: 3, x: 0, y: 2)
                                }
                            }
                            .padding(.vertical, 7)
                            .padding(.horizontal, 3)
                        }
                    }
                    
                    switch selectedViewMode {
                    case .write:
                        if entryText.isEmpty {
                            Text("Start writing your entry below...")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                                .padding(.horizontal)
                        }
                        TextEditor(text: $entryText)
                            .padding()
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                    case .preview:
                        ScrollView(.vertical) {
                            let attributed = parseAdvancedMarkdown(entryText)
                            Text(attributed)
                                .font(.system(size: 16))
                            
                            Spacer()
                        }
                        .padding()
                    }
                    
                    Picker("Mode", selection: $selectedViewMode) {
                        ForEach(ViewMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue)
                                .tag(mode)
                                .font(.custom("Nexa Script Light", size: 18))
                                .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    HStack {
                        if locations.count > 0 {
                            VStack {
                                HStack {
                                    Image(systemName: "location")
                                        .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                                        .font(.title2)
                                    Text("Locations:")
                                        .font(.custom("Nexa Script Light", size: 14))
                                        .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                                }
                                
                                Text(locations[0].displayName ?? "Unknown")
                            }
                        }
                        
                        Spacer()
                        
                        if tags.count > 0 {
                            VStack {
                                HStack {
                                    Image(systemName: "tag")
                                        .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                                        .font(.title2)
                                    Text("Tags:")
                                        .font(.custom("Nexa Script Light", size: 14))
                                        .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                                }
                                
                                HStack {
                                    Text(tags[0].key)
                                    
                                    if let value = tags[0].value {
                                        Text("(\(value))")
                                    }
                                }
                            }
                        }
                    }
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
                        showLocationPicker = true
                    }) {
                        Image(systemName: "location.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        showCameraSheet = true
                    }) {
                        Image(systemName: "camera.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    
                    Spacer()
                    
                    Button(action: {
                        showTagsSheet = true
                    }) {
                        Image(systemName: "tag.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    
                    Spacer()
                    
                    Button(action: {
                        showInfoSheet = true
                    }) {
                        Image(systemName: "info.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.008, green: 0.282, blue: 0.451))
            }
            
            if showCameraSheet {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showCameraSheet = false
                    }
                
                VStack(spacing: 16) {
                    Text("Photos Menu")
                        .font(.custom("Nexa Script Heavy", size: 18))
                    
                    Button(action: {
                        pickerSource = .camera
                        showImagePicker = true
                        showCameraSheet = false
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
                        pickerSource = .photoLibrary
                        showImagePicker = true
                        showCameraSheet = false
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
                .offset(y: UIScreen.main.bounds.height - 560)
            }
            
            if showInfoSheet {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showInfoSheet = false
                    }
                
                VStack(spacing: 16) {
                    Text("Info Menu & Instructions")
                        .font(.custom("Nexa Script Heavy", size: 18))
                    
                    HStack {
                        Text("Bold:")
                            .font(.custom("Nexa Script Heavy", size: 16))
                        
                        Text("Wrap with *")
                            .font(.custom("Nexa Script Light", size: 16))
                    }
                    HStack {
                        Text("Italic:")
                            .font(.custom("Nexa Script Heavy", size: 16))
                        
                        Text("Wrap with _")
                            .font(.custom("Nexa Script Light", size: 16))
                    }
                    HStack {
                        Text("Underline:")
                            .font(.custom("Nexa Script Heavy", size: 16))
                        
                        Text("Wrap with ~")
                            .font(.custom("Nexa Script Light", size: 16))
                    }
                    HStack {
                        Text("Strikethrough:")
                            .font(.custom("Nexa Script Heavy", size: 16))
                        
                        Text("Wrap with -")
                            .font(.custom("Nexa Script Light", size: 16))
                    }
                    HStack {
                        Text("Inline Code:")
                            .font(.custom("Nexa Script Heavy", size: 16))
                        
                        Text("Wrap with `")
                            .font(.custom("Nexa Script Light", size: 16))
                    }
                    HStack {
                        Text("Colored text:")
                            .font(.custom("Nexa Script Heavy", size: 16))
                        
                        Text("Wrap with {color: purple}Your text{color}")
                            .font(.custom("Nexa Script Light", size: 16))
                    }
                    HStack {
                        Text("Title:")
                            .font(.custom("Nexa Script Heavy", size: 16))
                        
                        Text("Start line with #")
                            .font(.custom("Nexa Script Light", size: 16))
                    }
                    HStack {
                        Text("Subtitle:")
                            .font(.custom("Nexa Script Heavy", size: 16))
                        
                        Text("Start line with ##")
                            .font(.custom("Nexa Script Light", size: 16))
                    }
                    HStack {
                        Text("Bulleted list item:")
                            .font(.custom("Nexa Script Heavy", size: 16))
                        
                        Text("Start line with -")
                            .font(.custom("Nexa Script Light", size: 16))
                    }
                    
                    Button(action: {
                        showInfoSheet = false
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
                .animation(.easeInOut, value: showInfoSheet)
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
                .offset(y: UIScreen.main.bounds.height - 600)
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: pickerSource) { uiImage in
                if images.count < 3 {
                    images.append(uiImage)
                }
            }
        }
        .sheet(isPresented: $showLocationPicker) {
            LocationPickerView { newLocation in
                locations.append(newLocation)
            }
        }
        .alert("Saved successfully!", isPresented: $isSavedSuccessfully) {
            Button("OK", role: .cancel) {
                isSavedSuccessfully = false
                dismiss()
                NotificationCenter.default.post(name: .newEntryCreated, object: nil)
//                await homeViewModel.fetchEntries(username: appState.username ?? "")
            }
        }
        .overlay(
            Group {
                if showTagsSheet {
                    AddTagView(isAddTagViewVisible: $showTagsSheet, onTagAdded: { newTag in
                        tags.append(newTag)
                    })
                }
            }
        )
//        .sheet(isPresented: $showTagsSheet) {
//            AddTagView { newTag in
//                tags.append(newTag)
//            }
//        }
    }
}

extension NewEntryView {
    private func submitEntry() {
        guard let username = appState.username, !entryText.isEmpty else { return }
        isSubmitting = true
        
        Task {
            do {
                let uuid = try await NetworkService.shared.createNewEntry(
                    username: username,
                    text: entryText,
                    locations: locations.isEmpty ? nil : locations,
                    tags: tags.isEmpty ? nil : tags
                )
                print("Got uuid: \(uuid) from server")
                
                let isUploadedAndUpdated = try await NetworkService.shared.uploadImages(
                    username: username,
                    uuid: uuid,
                    images: images
                )
                print("All images uploaded!")
                isSavedSuccessfully = isUploadedAndUpdated.success
            } catch {
                print("Error: \(error)")
                isSavedSuccessfully = false
            }
            isSubmitting = false
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

#Preview("Logged in") {
    let testAppState = AppState()
    testAppState.isLoggedIn = true
    testAppState.username = "test"
    return NewEntryView().environmentObject(testAppState)
}
