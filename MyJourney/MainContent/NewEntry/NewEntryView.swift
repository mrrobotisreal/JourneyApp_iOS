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
    @State private var idLocations: [IdentifiableLocationData] = []
    @State private var tags: [TagData] = []
    @State private var idTags: [IdentifiableTagData] = []
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
    
    @State private var isCameraSourcePickerViewVisible: Bool = false
    @State private var isInfoMenuViewVisible: Bool = false
    @State private var isEditLocationsViewVisible: Bool = false
    @State private var isEditTagsViewVisible: Bool = false
    
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
                    
                    VStack {
                        let timestamp = getTimestampString()
                        let dateStr = getFullDateStr(fromISO: timestamp)
                        let timeStr = getTimeStr(fromISO: timestamp)
                        Text(dateStr)
                            .font(.custom("Nexa Script Heavy", size: 24))
                            .foregroundColor(.white)
                        
                        Text(timeStr)
                            .font(.custom("Nexa Script Heavy", size: 16))
                            .foregroundColor(.white)
                    }
                    .padding()
                    
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
                            print("Trying to fucking save the damn entry!!!!!")
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
                        VStack {
                            if images.count > 0 {
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(images, id: \.self) { img in
                                            ZStack(alignment: .topTrailing) {
                                                Image(uiImage: img)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 112, height: 112)
                                                    .clipped()
                                                    .cornerRadius(8)
                                                    .shadow(color: Color.black.opacity(0.8), radius: 3, x: 0, y: 2)
                                                
                                                Button(action: {
                                                    if let index = images.firstIndex(of: img) {
                                                        images.remove(at: index)
                                                    }
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.white)
                                                        .background(Color.red.opacity(0.8))
                                                        .clipShape(Circle())
                                                }
                                                .padding(5)
                                            }
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
                                let locs = locations.prefix(3).map { IdentifiableLocationData(
                                    latitude: $0.latitude,
                                    longitude: $0.longitude,
                                    displayName: $0.displayName
                                ) }
                                VStack(alignment: .leading) {
                                    if !locs.isEmpty {
                                        HStack {
                                            Image(systemName: "location")
                                                .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                                                .font(.title2)
                                            Text("Locations:")
                                                .font(.custom("Nexa Script Heavy", size: 16))
                                                .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                                        }
                                    } else {
                                        Button(action: {
                                            isEditLocationsViewVisible = true
                                        }) {
                                            HStack {
                                                Image(systemName: "location")
                                                    .foregroundColor(.white)
                                                    .font(.title2)
                                                
                                                Text("Add Locations")
                                                    .font(.custom("Nexa Script Heavy", size: 16))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .cornerRadius(12)
                                        .background(Color(red: 0.039, green: 0.549, blue: 0.749))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(
                                                    Color(red: 0.008, green: 0.157, blue: 0.251),
                                                    lineWidth: 2
                                                )
                                        )
                                    }
                                    
                                    ForEach(locs) { loc in
                                        Text("• \(loc.displayName ?? "Unknown location")")
                                            .padding(.horizontal)
                                            .font(.custom("Nexa Script Light", size: 16))
                                            .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                                    }
                                    
                                    if !locations.isEmpty && locations.count > 3 {
                                        Text("+\(locations.count - 3) more...")
                                            .padding(.horizontal)
                                            .font(.custom("Nexa Script Heavy", size: 16))
                                            .foregroundColor(.blue)
                                            .onTapGesture {
                                                print("tapped more locations...")
                                                isEditLocationsViewVisible = true
                                                // TODO: create modal for viewing ALL locations, make each location tappable to open the map; they will appear as selectable chips just like in FilterModalView
                                            }
                                    } else if !locations.isEmpty && locations.count < 3 {
                                        Button(action: {
                                            isEditLocationsViewVisible = true
                                        }) {
                                            Image(systemName: "location")
                                                .foregroundColor(.white)
                                            
                                            Text("Edit Locations")
                                                .font(.custom("Nexa Script Heavy", size: 16))
                                                .foregroundColor(.white)
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
                                }
                                
                                Spacer()
                                
                                
                                let tagsData = tags.prefix(3).map { IdentifiableTagData(
                                    key: $0.key,
                                    value: $0.value
                                ) }
                                VStack(alignment: .leading) {
                                    if !tagsData.isEmpty {
                                        HStack {
                                            Image(systemName: "tag")
                                                .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                                                .font(.title2)
                                            Text("Tags:")
                                                .font(.custom("Nexa Script Heavy", size: 16))
                                                .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                                        }
                                    } else {
                                        Button(action: {
                                            idTags = tags.map { IdentifiableTagData(
                                                key: $0.key,
                                                value: $0.value
                                            ) }
                                            isEditTagsViewVisible = true
                                        }) {
                                            Image(systemName: "tag")
                                                .foregroundColor(.white)
                                            
                                            Text("Edit Tags")
                                                .font(.custom("Nexa Script Heavy", size: 16))
                                                .foregroundColor(.white)
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
                                    
                                    ForEach(tagsData) { tag in
                                        HStack {
                                            Text("• \(tag.key)")
                                                .font(.custom("Nexa Script Light", size: 16))
                                                .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                                                
                                            if let value = tag.value {
                                                Text("(\(value))")
                                                    .font(.custom("Nexa Script Light", size: 16))
                                                    .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                    
                                    if !tags.isEmpty && tags.count > 3 {
                                        Text("+\(tags.count - 3) more...")
                                            .padding(.horizontal)
                                            .font(.custom("Nexa Script Heavy", size: 16))
                                            .foregroundColor(.blue)
                                            .onTapGesture {
                                                print("tapped more tags...")
                                                idTags = tags.map { IdentifiableTagData(
                                                    key: $0.key,
                                                    value: $0.value
                                                ) }
                                                isEditTagsViewVisible = true
                                                // TODO: create modal for viewing ALL tags, adding new tags, removing tags; they will appear as selectable chips just like in FilterModalView
                                            }
                                    } else if !tags.isEmpty && tags.count < 3 {
                                        Button(action: {
                                            idTags = tags.map { IdentifiableTagData(
                                                key: $0.key,
                                                value: $0.value
                                            ) }
                                            isEditTagsViewVisible = true
                                        }) {
                                            Image(systemName: "tag")
                                                .foregroundColor(.white)
                                            
                                            Text("Edit Tags")
                                                .font(.custom("Nexa Script Heavy", size: 16))
                                                .foregroundColor(.white)
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
                                }
                            }
                        }
                        .padding()
                        .cornerRadius(12)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.008, green: 0.282, blue: 0.451), lineWidth: 2)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal, 10)
                
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
                        isCameraSourcePickerViewVisible = true
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
                        isInfoMenuViewVisible = true
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
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: pickerSource) { uiImage in
                if images.count < 10 {
                    images.append(uiImage)
                }
            }
        }
        .sheet(isPresented: $showLocationPicker) {
            LocationPickerView { newLocation in
                addLocation(idLoc: IdentifiableLocationData(
                    latitude: newLocation.latitude,
                    longitude: newLocation.longitude,
                    displayName: newLocation.displayName
                ), loc: newLocation)
            }
        }
        .alert("Saved successfully!", isPresented: $isSavedSuccessfully) {
            Button("OK", role: .cancel) {
                isSavedSuccessfully = false
                dismiss()
                NotificationCenter.default.post(name: .newEntryCreated, object: nil)
            }
        }
        .overlay(
            Group {
                if isEditTagsViewVisible {
                    EditTagsView(
                        isEditTagsViewVisible: $isEditTagsViewVisible,
                        idTags: idTags,
                        tags: tags,
                        onTagAdded: { idTag, tag in
                            addTag(idTag: idTag, tag: tag)
                        },
                        onTagRemoved: { index in
                            removeTag(index: index)
                        }
                    )
                } else if isEditLocationsViewVisible {
                    EditLocationsView(
                        isEditLocationsViewVisible: $isEditLocationsViewVisible,
                        showLocationPicker: $showLocationPicker,
                        idLocs: idLocations,
                        locs: locations,
                        onLocRemoved: { index in
                            removeLocation(index: index)
                        }
                    )
                } else if isCameraSourcePickerViewVisible {
                    CameraSourcePickerView(isCameraSourcePickerViewVisible: $isCameraSourcePickerViewVisible, onSourcePicked: { source in
                        if source == .photoLibrary {
                            print("Photo library picked!")
                            pickerSource = .photoLibrary
                        }
                        if source == .camera {
                            print("Camera picked!")
                            pickerSource = .camera
                        }
                        showImagePicker = true
                    })
                } else if isInfoMenuViewVisible {
                    InfoMenuView(isInfoMenuViewVisible: $isInfoMenuViewVisible)
                }
            }
        )
    }
    
    private func addLocation(idLoc: IdentifiableLocationData, loc: LocationData) {
        do {
            idLocations.append(idLoc)
            locations.append(loc)
        }
    }
    
    private func removeLocation(index: Int) {
        do {
            idLocations.remove(at: index)
            locations.remove(at: index)
        }
    }
    
    private func addTag(idTag: IdentifiableTagData, tag: TagData) {
        do {
            idTags.append(idTag)
            tags.append(tag)
        }
    }
    
    private func removeTag(index: Int) {
        do {
            idTags.remove(at: index)
            tags.remove(at: index)
        }
    }
}

extension NewEntryView {
    private func submitEntry() {
        guard let username = appState.username, let userId = appState.userId, !entryText.isEmpty else { return }
        isSubmitting = true
        
        Task {
            do {
                let response = try await NetworkService.shared.createNewEntry(
                    apiKey: appState.apiKey ?? "",
                    jwt: appState.jwt ?? "",
                    userId: userId,
                    username: username,
                    text: entryText,
                    images: [],
                    locations: locations.isEmpty ? nil : locations,
                    tags: tags.isEmpty ? nil : tags
                )
                
                let isUploadedAndUpdated = try await NetworkService.shared.uploadImages(
                    apiKey: appState.apiKey ?? "",
                    jwt: appState.jwt ?? "",
                    userId: userId,
                    username: username,
                    timestamp: response.timestamp,
                    id: response.id,
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
