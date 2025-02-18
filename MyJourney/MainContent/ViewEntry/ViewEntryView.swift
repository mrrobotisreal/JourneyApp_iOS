//
//  ViewEntryView.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 1/28/25.
//

import SwiftUI
import UIKit

struct ViewEntryView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var homeViewModel = HomeViewModel()
    @State private var isEditing: Bool = false
    @State private var isSavingEdit: Bool = false
    @State private var isSavedSuccessfully: Bool = false
    @State private var isDeletingEntry: Bool = false
    @State private var isDeletedSuccessfully: Bool = false
    @State private var showLocationSheet: Bool = false
    @State private var showPeopleSheet: Bool = false
    @State private var showCameraSheet: Bool = false
    @State private var showTagsSheet: Bool = false
    @State private var showInfoSheet: Bool = false
    @State private var hasImages: Bool = false
    @State private var presignedURLs: [URL] = []
    @State private var images: [UIImage] = []
    @State private var imageURLs: [String] = []
    @State private var isImageDeletedSuccessfully: Bool = false
    @State private var showImagePicker = false
    @State private var pickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var locations: [LocationData] = []
    @State private var idLocations: [IdentifiableLocationData] = []
    @State private var isLocationDeletedSuccessfully: Bool = false
    @State private var tags: [TagData] = []
    @State private var idTags: [IdentifiableTagData] = []
    @State private var isTagDeletedSuccessfully: Bool = false
    @State private var entryText: String = ""
    @State private var isLoading: Bool = false
    @State private var isCameraSourcePickerViewVisible: Bool = false
    @State private var isInfoMenuViewVisible: Bool = false
    @State private var showLocationPicker: Bool = false
    @State private var isEditLocationsViewVisible: Bool = false
    @State private var isEditTagsViewVisible: Bool = false
    @State private var isViewImageViewVisible: Bool = false
    @State private var selectedImage: URL? = nil
    @State private var selectedUIImage: UIImage? = nil
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
                        if isEditing {
                            Button(action: {
                                isEditing = false
                            }) {
                                Text("Cancel")
                                    .font(.custom("Nexa Script Light", size: 18))
                                    .foregroundColor(.white)
                            }
                            .padding()
                        } else {
                            Button(action: {
                                dismiss()
                            }) {
                                Image(systemName: "arrowshape.turn.up.backward.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            .padding()
                        }
                        
                        Spacer()
                        
                        VStack {
                            let date = getFullDateStr(fromISO: appState.selectedEntry.timestamp)
                            let time = getTimeStr(fromISO: appState.selectedEntry.timestamp)
                            Text(date)
                                .font(.custom("Nexa Script Heavy", size: 24))
                                .foregroundColor(.white)
                            
                            Text(time)
                                .font(.custom("Nexa Script Heavy", size: 16))
                                .foregroundColor(.white)
                        }
                        .padding()
                        
                        Spacer()
                        
                        if isEditing {
                            if isSavingEdit {
                                ProgressView()
                                    .progressViewStyle(
                                        CircularProgressViewStyle(tint: Color(red: 0.533, green: 0.875, blue: 0.949))
                                    )
                                    .tint(Color(red: 0.533, green: 0.875, blue: 0.949))
                                    .padding()
                            } else {
                                Button(action: {
                                    saveEdit()
                                }) {
                                    Text("Save")
                                        .font(.custom("Nexa Script Light", size: 18))
                                        .foregroundColor(.white)
                                }
                                .padding()
                            }
                        } else {
                            Button(action: {
                                entryText = appState.selectedEntry.text
                                isEditing = true
                            }) {
                                Image(systemName: "square.and.pencil")
                                    .font(.title2)
                                    .padding(6)
                            }
                            .foregroundColor(.white)
                            .padding()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0.008, green: 0.282, blue: 0.451))
                    
                    Spacer()
                    
                    VStack {
                    VStack {
                        if appState.selectedEntry.imageURLs.isEmpty && images.isEmpty && isEditing {
                            Button(action: {
                                isCameraSourcePickerViewVisible = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.title)
                                    .padding()
                            }
                            .padding()
                            .frame(width: 108, height: 108)
                            .cornerRadius(12)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 0.008, green: 0.282, blue: 0.451), lineWidth: 2)
                            )
                        }
                        
                        if !appState.selectedEntry.imageURLs.isEmpty {
                            if presignedURLs.isEmpty {
                                HStack {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                        .tint(.gray)
                                    
                                    Text("Loading images...")
                                        .foregroundColor(.gray)
                                }
                            } else {
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(presignedURLs, id: \.self) { url in
                                            ZStack(alignment: .topTrailing) {
                                                ResilientAsyncImage(url: url, progressColor: Color(red: 0.008, green: 0.157, blue: 0.251))
                                                
                                                if isEditing {
                                                    Button(action: {
                                                        if let index = presignedURLs.firstIndex(of: url) {
                                                            DispatchQueue.main.async {
                                                                Task {
                                                                    do {
                                                                        presignedURLs.remove(at: index)
                                                                        let imageToDelete = imageURLs[index]
                                                                        var tempImageURLs = imageURLs
                                                                        tempImageURLs.remove(at: index)
                                                                        try await deleteImage(images: tempImageURLs, imageToDelete: imageToDelete)
                                                                        imageURLs.remove(at: index)
                                                                    } catch {
                                                                        print("Error attempting to delete the image from this entry! \(error)")
                                                                    }
                                                                }
//                                                                presignedURLs.remove(at: index)
//                                                                imageURLs.remove(at: index)
//                                                                let imageToDelete = imageURLs[index]
//                                                                var tempImageURLs = imageURLs.map { $0 }
//                                                                tempImageURLs.remove(at: index)
//                                                                do {
//                                                                    try await deleteImage(images: tempImageURLs, imageToDelete: imageToDelete)
//                                                                } catch {
//                                                                    print("Error attempting to delete the selected image: \(error)")
//                                                                }
                                                            }
                                                        }
                                                    }) {
                                                        Image(systemName: "xmark.circle.fill")
                                                            .foregroundColor(.white)
                                                            .background(Color.red.opacity(0.8))
                                                            .clipShape(Circle())
                                                    }
                                                    .contentShape(Rectangle())
                                                    .padding(5)
                                                }
                                                if !isEditing {
                                                    Button(action: {
                                                        if let index = presignedURLs.firstIndex(of: url) {
                                                            DispatchQueue.main.async {
                                                                print("Index \(index) tapped!")
                                                                selectedImage = presignedURLs[index]
                                                                selectedUIImage = nil
                                                                if selectedImage != nil && selectedUIImage == nil {
                                                                    isViewImageViewVisible = true
                                                                }
                                                            }
                                                        }
                                                    }) {
                                                        Image(systemName: "arrow.up.left.and.arrow.down.right.square.fill")
                                                            .foregroundColor(.white)
                                                            .background(Color.yellow.opacity(0.8))
                                                    }
                                                    .contentShape(Rectangle())
                                                    .padding(5)
                                                }
                                            }
                                        }
                                        
                                        if !images.isEmpty {
                                            ForEach(images, id: \.self) { img in
                                                ZStack(alignment: .topTrailing) {
                                                    Image(uiImage: img)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 108, height: 108)
                                                        .clipped()
                                                        .cornerRadius(8)
                                                        .shadow(color: Color.black.opacity(0.8), radius: 3, x: 0, y: 2)
                                                    
                                                    if isEditing {
                                                        Button(action: {
                                                            if let index = images.firstIndex(of: img) {
                                                                DispatchQueue.main.async {
                                                                    images.remove(at: index)
                                                                }
                                                            }
                                                        }) {
                                                            Image(systemName: "xmark.circle.fill")
                                                                .foregroundColor(.white)
                                                                .background(Color.red.opacity(0.8))
                                                                .clipShape(Circle())
                                                        }
                                                        .contentShape(Rectangle())
                                                        .padding(5)
                                                    }
                                                    if !isEditing {
                                                        Button(action: {
                                                            if let index = images.firstIndex(of: img) {
                                                                DispatchQueue.main.async {
                                                                    selectedUIImage = images[index]
                                                                    selectedImage = nil
                                                                    if selectedUIImage != nil && selectedImage == nil {
                                                                        isViewImageViewVisible = true
                                                                    }
                                                                }
                                                            }
                                                        }) {
                                                            Image(systemName: "arrow.up.left.and.arrow.down.right.square.fill")
                                                                .foregroundColor(.white)
                                                                .background(Color.yellow.opacity(0.8))
                                                        }
                                                        .contentShape(Rectangle())
                                                        .padding(5)
                                                    }
                                                }
                                            }
                                        }
                                        
                                        if isEditing {
                                            Button(action: {
                                                isCameraSourcePickerViewVisible = true
                                            }) {
                                                Image(systemName: "plus")
                                                    .font(.title)
                                                    .padding()
                                            }
                                            .padding()
                                            .frame(width: 108, height: 108)
                                            .cornerRadius(12)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color(red: 0.008, green: 0.282, blue: 0.451), lineWidth: 2)
                                            )
                                        }
                                    }
                                    .padding(.vertical, 7)
                                    .padding(.horizontal, 3)
                                }
                            }
                        } else {
                            if !images.isEmpty {
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(images, id: \.self) { img in
                                            ZStack(alignment: .topTrailing) {
                                                Image(uiImage: img)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 108, height: 108)
                                                    .clipped()
                                                    .cornerRadius(8)
                                                    .shadow(color: Color.black.opacity(0.8), radius: 3, x: 0, y: 2)
                                                
                                                if isEditing {
                                                    Button(action: {
                                                        if let index = images.firstIndex(of: img) {
                                                            DispatchQueue.main.async {
                                                                images.remove(at: index)
                                                            }
                                                        }
                                                    }) {
                                                        Image(systemName: "xmark.circle.fill")
                                                            .foregroundColor(.white)
                                                            .background(Color.red.opacity(0.8))
                                                            .clipShape(Circle())
                                                    }
                                                    .contentShape(Rectangle())
                                                    .padding(5)
                                                }
                                                if !isEditing {
                                                    Button(action: {
                                                        if let index = images.firstIndex(of: img) {
                                                            DispatchQueue.main.async {
                                                                selectedUIImage = images[index]
                                                                selectedImage = nil
                                                                if selectedUIImage != nil && selectedImage == nil {
                                                                    isViewImageViewVisible = true
                                                                }
                                                            }
                                                        }
                                                    }) {
                                                        Image(systemName: "arrow.up.left.and.arrow.down.right.square.fill")
                                                            .foregroundColor(.white)
                                                            .background(Color.yellow.opacity(0.8))
                                                    }
                                                    .contentShape(Rectangle())
                                                    .padding(5)
                                                }
                                            }
                                        }
                                        
                                        if isEditing {
                                            Button(action: {
                                                isCameraSourcePickerViewVisible = true
                                            }) {
                                                Image(systemName: "plus")
                                                    .font(.title)
                                                    .padding()
                                            }
                                            .padding()
                                            .frame(width: 108, height: 108)
                                            .cornerRadius(12)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color(red: 0.008, green: 0.282, blue: 0.451), lineWidth: 2)
                                            )
                                        }
                                    }
                                    .padding(.vertical, 7)
                                    .padding(.horizontal, 3)
                                }
                            }
                        }
                        
                        if isEditing {
                            switch selectedViewMode {
                            case .write:
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
                                let locs = appState.selectedEntry.locations.prefix(3).map { IdentifiableLocationData(
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
                                    
                                    if !appState.selectedEntry.locations.isEmpty && appState.selectedEntry.locations.count > 3 {
                                        Text("+\(appState.selectedEntry.locations.count - 3) more...")
                                            .padding(.horizontal)
                                            .font(.custom("Nexa Script Heavy", size: 16))
                                            .foregroundColor(.blue)
                                            .onTapGesture {
                                                print("tapped more locations...")
                                                isEditLocationsViewVisible = true
                                            }
                                    } else if !appState.selectedEntry.locations.isEmpty && appState.selectedEntry.locations.count < 3 {
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
                                
                                
                                let tagsData = appState.selectedEntry.tags.prefix(3).map { IdentifiableTagData(
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
                                            idTags = appState.selectedEntry.tags.map { IdentifiableTagData(
                                                key: $0.key,
                                                value: $0.value
                                            ) }
                                            tags = appState.selectedEntry.tags.map { $0 }
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
                                    
                                    if !appState.selectedEntry.tags.isEmpty && appState.selectedEntry.tags.count > 3 {
                                        Text("+\(appState.selectedEntry.tags.count - 3) more...")
                                            .padding(.horizontal)
                                            .font(.custom("Nexa Script Heavy", size: 16))
                                            .foregroundColor(.blue)
                                            .onTapGesture {
                                                print("tapped more tags...")
                                                idTags = appState.selectedEntry.tags.map { IdentifiableTagData(
                                                    key: $0.key,
                                                    value: $0.value
                                                ) }
                                                tags = appState.selectedEntry.tags.map { $0 }
                                                isEditTagsViewVisible = true
                                                // TODO: create modal for viewing ALL tags, adding new tags, removing tags; they will appear as selectable chips just like in FilterModalView
                                            }
                                    } else if !appState.selectedEntry.tags.isEmpty && appState.selectedEntry.tags.count < 3 {
                                        Button(action: {
                                            idTags = appState.selectedEntry.tags.map { IdentifiableTagData(
                                                key: $0.key,
                                                value: $0.value
                                            ) }
                                            tags = appState.selectedEntry.tags.map { $0 }
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
                        } else {
                            ScrollView(.vertical) {
                                let attributed = parseAdvancedMarkdown(appState.selectedEntry.text)
                                Text(attributed)
                                    .font(.system(size: 16))
                                
                                Spacer()
                            }
                            .padding()
                            
                            HStack {
                                let locs = appState.selectedEntry.locations.prefix(3).map { IdentifiableLocationData(
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
//                                        Button(action: {
//                                            isEditLocationsViewVisible = true
//                                        }) {
//                                            Image(systemName: "location")
//                                                .foregroundColor(.white)
//                                            
//                                            Text("Edit Locations")
//                                                .font(.custom("Nexa Script Heavy", size: 16))
//                                                .foregroundColor(.white)
//                                        }
//                                        .padding(.horizontal, 12)
//                                        .padding(.vertical, 6)
//                                        .foregroundColor(.white)
//                                        .cornerRadius(12)
//                                        .background(Color(red: 0.039, green: 0.549, blue: 0.749))
//                                        .clipShape(RoundedRectangle(cornerRadius: 12))
//                                        .overlay(
//                                            RoundedRectangle(cornerRadius: 12)
//                                                .stroke(Color(red: 0.008, green: 0.157, blue: 0.251), lineWidth: 2)
//                                        )
                                    }
                                    
                                    ForEach(locs) { loc in
                                        Text("• \(loc.displayName ?? "Unknown location")")
                                            .padding(.horizontal)
                                            .font(.custom("Nexa Script Light", size: 16))
                                            .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                                    }
                                    
                                    if !appState.selectedEntry.locations.isEmpty && appState.selectedEntry.locations.count > 3 {
                                        Text("+\(appState.selectedEntry.locations.count - 3) more...")
                                            .padding(.horizontal)
                                            .font(.custom("Nexa Script Heavy", size: 16))
                                            .foregroundColor(.gray)
//                                            .onTapGesture {
//                                                print("tapped more locations...")
//                                                isEditLocationsViewVisible = true
//                                            }
                                    } else if !appState.selectedEntry.locations.isEmpty && appState.selectedEntry.locations.count < 3 {
//                                        Button(action: {
//                                            isEditLocationsViewVisible = true
//                                        }) {
//                                            Image(systemName: "location")
//                                                .foregroundColor(.white)
//                                            
//                                            Text("Edit Locations")
//                                                .font(.custom("Nexa Script Heavy", size: 16))
//                                                .foregroundColor(.white)
//                                        }
//                                        .padding(.horizontal, 12)
//                                        .padding(.vertical, 6)
//                                        .foregroundColor(.white)
//                                        .cornerRadius(12)
//                                        .background(Color(red: 0.039, green: 0.549, blue: 0.749))
//                                        .clipShape(RoundedRectangle(cornerRadius: 12))
//                                        .overlay(
//                                            RoundedRectangle(cornerRadius: 12)
//                                                .stroke(Color(red: 0.008, green: 0.157, blue: 0.251), lineWidth: 2)
//                                        )
                                    }
                                }
                                
                                Spacer()
                                
                                
                                let tagsData = appState.selectedEntry.tags.prefix(3).map { IdentifiableTagData(
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
//                                        Button(action: {
//                                            idTags = appState.selectedEntry.tags.map { IdentifiableTagData(
//                                                key: $0.key,
//                                                value: $0.value
//                                            ) }
//                                            tags = appState.selectedEntry.tags.map { $0 }
//                                            isEditTagsViewVisible = true
//                                        }) {
//                                            Image(systemName: "tag")
//                                                .foregroundColor(.white)
//                                            
//                                            Text("Edit Tags")
//                                                .font(.custom("Nexa Script Heavy", size: 16))
//                                                .foregroundColor(.white)
//                                        }
//                                        .padding(.horizontal, 12)
//                                        .padding(.vertical, 6)
//                                        .foregroundColor(.white)
//                                        .cornerRadius(12)
//                                        .background(Color(red: 0.039, green: 0.549, blue: 0.749))
//                                        .clipShape(RoundedRectangle(cornerRadius: 12))
//                                        .overlay(
//                                            RoundedRectangle(cornerRadius: 12)
//                                                .stroke(Color(red: 0.008, green: 0.157, blue: 0.251), lineWidth: 2)
//                                        )
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
                                    
                                    if !appState.selectedEntry.tags.isEmpty && appState.selectedEntry.tags.count > 3 {
                                        Text("+\(appState.selectedEntry.tags.count - 3) more...")
                                            .padding(.horizontal)
                                            .font(.custom("Nexa Script Heavy", size: 16))
                                            .foregroundColor(.gray)
//                                            .onTapGesture {
//                                                print("tapped more tags...")
//                                                idTags = appState.selectedEntry.tags.map { IdentifiableTagData(
//                                                    key: $0.key,
//                                                    value: $0.value
//                                                ) }
//                                                tags = appState.selectedEntry.tags.map { $0 }
//                                                isEditTagsViewVisible = true
//                                            }
                                    } else if !appState.selectedEntry.tags.isEmpty && appState.selectedEntry.tags.count < 3 {
//                                        Button(action: {
//                                            idTags = appState.selectedEntry.tags.map { IdentifiableTagData(
//                                                key: $0.key,
//                                                value: $0.value
//                                            ) }
//                                            tags = appState.selectedEntry.tags.map { $0 }
//                                            isEditTagsViewVisible = true
//                                        }) {
//                                            Image(systemName: "tag")
//                                                .foregroundColor(.white)
//                                            
//                                            Text("Edit Tags")
//                                                .font(.custom("Nexa Script Heavy", size: 16))
//                                                .foregroundColor(.white)
//                                        }
//                                        .padding(.horizontal, 12)
//                                        .padding(.vertical, 6)
//                                        .foregroundColor(.white)
//                                        .cornerRadius(12)
//                                        .background(Color(red: 0.039, green: 0.549, blue: 0.749))
//                                        .clipShape(RoundedRectangle(cornerRadius: 12))
//                                        .overlay(
//                                            RoundedRectangle(cornerRadius: 12)
//                                                .stroke(Color(red: 0.008, green: 0.157, blue: 0.251), lineWidth: 2)
//                                        )
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
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
                    
                    if isEditing {
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                deleteEntry()
                            }) {
                                Image(systemName: "trash.circle.fill")
                                    .font(.title)
                                    .foregroundColor(Color.red.opacity(0.8))
                                    .background(.white)
                                    .clipShape(Circle())
                                
                                Text("Delete Entry")
                                    .font(.custom("Nexa Script Heavy", size: 18))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                saveEdit()
                            }) {
                                Image(systemName: "checkmark.icloud.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .background(Color.green.opacity(0.8))
                                    .clipShape(Circle())
                                
                                Text("Save Edits")
                                    .font(.custom("Nexa Script Heavy", size: 18))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 0.008, green: 0.282, blue: 0.451))
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                if !appState.selectedEntry.imageURLs.isEmpty {
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
                
                self.idTags = self.tags.map { IdentifiableTagData(
                    key: $0.key, value: $0.value
                ) }
                
                for idTag in self.idTags {
                    print("Tag key: \(idTag.key)")
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: pickerSource) { uiImage in
                    if images.count < 10 {
                        images.append(uiImage)
                    }
                }
            }
            .sheet(isPresented: $showLocationPicker) {
                LocationPickerView { newLocation in
                    Task {
                        do {
                            await addLocation(
                                idLoc: IdentifiableLocationData(
                                    latitude: newLocation.latitude,
                                    longitude: newLocation.longitude,
                                    displayName: newLocation.displayName
                                ),
                                loc: newLocation
                            )
                        }
                    }
                }
            }
            .alert("Edited successfully!", isPresented: $isSavedSuccessfully) {
                Button("OK", role: .cancel) {
                    isSavedSuccessfully = false
                    dismiss()
                    NotificationCenter.default.post(name: .newEntryCreated, object: nil)
                }
            }
            .alert("Deleted successfully!", isPresented: $isDeletedSuccessfully) {
                Button("OK", role: .cancel) {
                    isSavedSuccessfully = false
                    isDeletedSuccessfully = false
                    dismiss()
                    NotificationCenter.default.post(name: .newEntryCreated, object: nil)
                }
            }
            .alert("Image deleted successfully!", isPresented: $isImageDeletedSuccessfully) {
                Button("OK", role: .cancel) {
                    isImageDeletedSuccessfully = false
                }
            }
            .alert("Location deleted successfully!", isPresented: $isLocationDeletedSuccessfully) {
                Button("OK", role: .cancel) {
                    isLocationDeletedSuccessfully = false
                }
            }
            .alert("Tag deleted successfully!", isPresented: $isTagDeletedSuccessfully) {
                Button("OK", role: .cancel) {
                    isTagDeletedSuccessfully = false
                }
            }
            .overlay(
                Group {
                    if isEditTagsViewVisible {
                        EditTagsView(
                            isEditTagsViewVisible: $isEditTagsViewVisible,
                            idTags: appState.idTags,
                            tags: appState.selectedEntry.tags,
                            onTagAdded: { idTag, tag in
                                Task {
                                    do {
                                        await addTag(idTag: idTag, tag: tag)
                                    }
                                }
                            },
                            onTagRemoved: { index in
                                Task {
                                    do {
                                        await removeTag(index: index)
                                    }
                                }
                            }
                        )
                    } else if isEditLocationsViewVisible {
                        EditLocationsView(
                            isEditLocationsViewVisible: $isEditLocationsViewVisible,
                            showLocationPicker: $showLocationPicker,
                            idLocs: appState.idLocations,
                            locs: appState.selectedEntry.locations,
                            onLocRemoved: { index in
                                Task {
                                    do {
                                        await removeLocation(index: index)
                                    }
                                }
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
                    } else if isViewImageViewVisible {
                        ViewImageView(
                            isViewImageViewVisible: $isViewImageViewVisible,
                            imageURL: selectedImage,
                            uiImage: selectedUIImage
                        )
                    }
                }
            )
    }
    
    private func fetchPresignedURLs() async {
        var tempURLs: [URL] = []
        var tempKeys: [String] = []
        
        for (_, key) in (appState.selectedEntry.imageURLs.enumerated()) {
            do {
                let presignedURL = try await NetworkService.shared.getPresignedURLForKey(key, apiKey: appState.apiKey ?? "", jwt: appState.jwt ?? "")
                tempURLs.append(presignedURL)
                tempKeys.append(key)
            } catch {
                print("Error getting presigned URL for \(key): \(error)")
            }
        }
        
        await MainActor.run {
            self.presignedURLs = tempURLs
            self.imageURLs = tempKeys
        }
    }
    
    private func addLocation(idLoc:  IdentifiableLocationData, loc: LocationData) async {
        var tempIdLocs: [IdentifiableLocationData] = []
        var tempLocs: [LocationData] = []
        
        do {
            tempIdLocs = appState.idLocations.map { $0 }
            tempLocs = appState.selectedEntry.locations.map { $0 }
            
            tempIdLocs.append(idLoc)
            tempLocs.append(loc)
            
            locations = tempLocs
            appState.idLocations = tempIdLocs
            appState.selectedEntry = EntryListItem(
                id: appState.selectedEntry.id,
                text: appState.selectedEntry.text,
                imageURLs: appState.selectedEntry.imageURLs,
                timestamp: appState.selectedEntry.timestamp,
                locations: tempLocs,
                tags: appState.selectedEntry.tags
            )
            
            do {
                try await updateLocations(locations: tempLocs)
            } catch {
                print("Error attempting to add the new location: \(error)")
            }
        }
    }
    
    private func updateLocations(locations: [LocationData]) async throws {
        do {
            let result = try await NetworkService.shared.addLocation(
                apiKey: appState.apiKey ?? "",
                jwt: appState.jwt ?? "",
                username: appState.username ?? "",
                userId: appState.userId ?? "",
                timestamp: appState.selectedEntry.timestamp,
                entryId: appState.selectedEntry.id,
                locations: locations
            )
            if !result.success {
                print("Uh oh! The location was not added successfully.")
            } else {
                print("The location was added successfully!")
                appState.selectedEntry = EntryListItem(
                    id: appState.selectedEntry.id,
                    text: appState.selectedEntry.text,
                    imageURLs: appState.selectedEntry.imageURLs,
                    timestamp: appState.selectedEntry.timestamp,
                    locations: locations,
                    tags: appState.selectedEntry.tags
                )
            }
        } catch {
            print("Error adding location in ViewEntryView: \(error)")
        }
    }
    
    private func removeLocation(index: Int) async {
        var tempIdLocs: [IdentifiableLocationData] = []
        var tempLocs: [LocationData] = []
        
        do {
            tempIdLocs = appState.idLocations.map { $0 }
            tempLocs = appState.selectedEntry.locations.map { $0 }
            
            tempIdLocs.remove(at: index)
            tempLocs.remove(at: index)
            
            locations = tempLocs
            appState.idLocations = tempIdLocs
            appState.selectedEntry = EntryListItem(
                id: appState.selectedEntry.id,
                text: appState.selectedEntry.text,
                imageURLs: appState.selectedEntry.imageURLs,
                timestamp: appState.selectedEntry.timestamp,
                locations: tempLocs,
                tags: appState.selectedEntry.tags
            )
            
            do {
                try await deleteLocation(locations: tempLocs)
            } catch {
                print("Error attempting to delete the selected location: \(error)")
            }
        }
    }
    
    private func deleteLocation(locations: [LocationData]) async throws {
        do {
            let result = try await NetworkService.shared.deleteLocation(
                apiKey: appState.apiKey ?? "",
                jwt: appState.jwt ?? "",
                username: appState.username ?? "",
                userId: appState.userId ?? "",
                timestamp: appState.selectedEntry.timestamp,
                entryId: appState.selectedEntry.id,
                locations: locations
            )
            if !result.success {
                print("Uh oh! The location was not deleted successfully.")
            } else {
                print("The location was deleted successfully!")
                appState.selectedEntry = EntryListItem(
                    id: appState.selectedEntry.id,
                    text: appState.selectedEntry.text,
                    imageURLs: appState.selectedEntry.imageURLs,
                    timestamp: appState.selectedEntry.timestamp,
                    locations: locations,
                    tags: appState.selectedEntry.tags
                )
                isLocationDeletedSuccessfully = true
            }
        } catch {
            print("Error deleting location in ViewEntryView: \(error)")
        }
    }
    
    private func addTag(idTag: IdentifiableTagData, tag: TagData) async {
        var tempIdTags: [IdentifiableTagData] = []
        var tempTags: [TagData] = []
        
        do {
            tempIdTags = appState.idTags.map { $0 }
            tempTags = appState.selectedEntry.tags.map { $0 }
            
            tempIdTags.append(idTag)
            tempTags.append(tag)
            
            tags = tempTags
            appState.idTags = tempIdTags
            appState.selectedEntry = EntryListItem(
                id: appState.selectedEntry.id,
                text: appState.selectedEntry.text,
                imageURLs: appState.selectedEntry.imageURLs,
                timestamp: appState.selectedEntry.timestamp,
                locations: appState.selectedEntry.locations,
                tags: tempTags
            )
            
            do {
                try await updateTags(tags: tempTags)
            } catch {
                print("Error attempting to add the new tag: \(error)")
            }
        }
    }
    
    private func updateTags(tags: [TagData]) async throws {
        do {
            let result = try await NetworkService.shared.addTag(
                apiKey: appState.apiKey ?? "",
                jwt: appState.jwt ?? "",
                username: appState.username ?? "",
                userId: appState.userId ?? "",
                timestamp: appState.selectedEntry.timestamp,
                entryId: appState.selectedEntry.id,
                tags: tags
            )
            if !result.success {
                print("Uh oh! The tag was not added successfully.")
            } else {
                print("The tag was added successfully!")
                appState.selectedEntry = EntryListItem(
                    id: appState.selectedEntry.id,
                    text: appState.selectedEntry.text,
                    imageURLs: appState.selectedEntry.imageURLs,
                    timestamp: appState.selectedEntry.timestamp,
                    locations: appState.selectedEntry.locations,
                    tags: tags
                )
            }
        } catch {
            print("Error adding tag in ViewEntryView: \(error)")
        }
    }
    
    private func removeTag(index: Int) async {
        var tempIdTags: [IdentifiableTagData] = []
        var tempTags: [TagData] = []
        
        do {
            tempIdTags = appState.idTags.map { $0 }
            tempTags = appState.selectedEntry.tags.map { $0 }
            
            tempIdTags.remove(at: index)
            tempTags.remove(at: index)
            
            tags = tempTags
            appState.idTags = tempIdTags
            appState.selectedEntry = EntryListItem(
                id: appState.selectedEntry.id,
                text: appState.selectedEntry.text,
                imageURLs: appState.selectedEntry.imageURLs,
                timestamp: appState.selectedEntry.timestamp,
                locations: appState.selectedEntry.locations,
                tags: tempTags
            )
            
            do {
                try await deleteTag(tags: tempTags)
            } catch {
                print("Error attempting to delete the selected tag: \(error)")
            }
        }
    }
    
    private func deleteTag(tags: [TagData]) async throws {
        do {
            let result = try await NetworkService.shared.deleteTag(
                apiKey: appState.apiKey ?? "",
                jwt: appState.jwt ?? "",
                username: appState.username ?? "",
                userId: appState.userId ?? "",
                timestamp: appState.selectedEntry.timestamp,
                entryId: appState.selectedEntry.id,
                tags: tags
            )
            if !result.success {
                print("Uh oh! The tag was not deleted successfully.")
            } else {
                print("The tag was deleted successfully!")
                appState.selectedEntry = EntryListItem(
                    id: appState.selectedEntry.id,
                    text: appState.selectedEntry.text,
                    imageURLs: appState.selectedEntry.imageURLs,
                    timestamp: appState.selectedEntry.timestamp,
                    locations: appState.selectedEntry.locations,
                    tags: tags
                )
                isTagDeletedSuccessfully = true
            }
        } catch {
            print("Error deleting tag in ViewEntryView: \(error)")
        }
    }
    
    private func addImage(images: [String]) async throws {
        do {
            let result = try await NetworkService.shared.addImage(
                apiKey: appState.apiKey ?? "",
                jwt: appState.jwt ?? "",
                username: appState.username ?? "",
                userId: appState.userId ?? "",
                timestamp: appState.selectedEntry.timestamp,
                entryId: appState.selectedEntry.id,
                images: images
            )
            if !result.success {
                print("Uh oh! The image was not added successfully.")
            } else {
                print("The image was added successfully!")
            }
        } catch {
            print("Error adding image in ViewEntryView: \(error)")
        }
    }
    
    private func deleteImage(images: [String], imageToDelete: String) async throws {
        do {
            print("About to delete image: \(imageToDelete)")
            print("Images looks like: \(images)")
            let result = try await NetworkService.shared.deleteImage(
                apiKey: appState.apiKey ?? "",
                jwt: appState.jwt ?? "",
                username: appState.username ?? "",
                userId: appState.userId ?? "",
                timestamp: appState.selectedEntry.timestamp,
                entryId: appState.selectedEntry.id,
                images: images,
                imageToDelete: imageToDelete
            )
            if !result.success {
                print("Uh oh! The image was not deleted successfully.")
            } else {
                print("The image was deleted successfully!")
                appState.selectedEntry = EntryListItem(
                    id: appState.selectedEntry.id,
                    text: appState.selectedEntry.text,
                    imageURLs: images,
                    timestamp: appState.selectedEntry.timestamp,
                    locations: appState.selectedEntry.locations,
                    tags: appState.selectedEntry.tags
                )
                isImageDeletedSuccessfully = true
            }
        } catch {
            print("Error deleting image in ViewEntryView: \(error)")
        }
    }
    
    private func deleteEntry() {
        guard let username = appState.username else { return }
        let id = appState.selectedEntry.id
        guard id != "" else { return }
        isDeletingEntry = true
        
        Task {
            do {
                for imageURL in appState.selectedEntry.imageURLs {
                    try await deleteImage(images: appState.selectedEntry.imageURLs, imageToDelete: imageURL)
                }
                
                let result = try await NetworkService.shared.deleteEntry(
                    apiKey: appState.apiKey ?? "",
                    jwt: appState.jwt ?? "",
                    userId: appState.userId ?? "",
                    username: username,
                    timestamp: appState.selectedEntry.timestamp,
                    id: id
                )
                
                isDeletedSuccessfully = result.success
            } catch {
                print("Error deleting the entry: \(error)")
                isDeletedSuccessfully = false
            }
            isDeletingEntry = false
        }
    }
    
    private func saveEdit() {
        guard let username = appState.username, let userId = appState.userId, !entryText.isEmpty else { return }
        isSavingEdit = true
        
        Task {
            do {
                if !imageURLs.isEmpty {
                    if imageURLs.count < appState.selectedEntry.imageURLs.count {
                        try await NetworkService.shared.updateEntry(
                            apiKey: appState.apiKey ?? "",
                            jwt: appState.jwt ?? "",
                            entryId: appState.selectedEntry.id,
                            userId: userId,
                            username: username,
                            timestamp: appState.selectedEntry.timestamp,
                            text: nil,
                            images: imageURLs,
                            locations: nil,
                            tags: nil
                        )
                    }
                }
                if !images.isEmpty {
                    let uploadResult = try await NetworkService.shared.uploadImages(
                        apiKey: appState.apiKey ?? "",
                        jwt: appState.jwt ?? "",
                        userId: userId,
                        username: username,
                        timestamp: appState.selectedEntry.timestamp,
                        id: appState.selectedEntry.id,
                        images: images
                    )
                    if uploadResult.success {
                        for imgKey in uploadResult.imageURLs {
                            imageURLs.append(imgKey)
                        }
                        try await NetworkService.shared.updateEntry(
                            apiKey: appState.apiKey ?? "",
                            jwt: appState.jwt ?? "",
                            entryId: appState.selectedEntry.id,
                            userId: userId,
                            username: username,
                            timestamp: appState.selectedEntry.timestamp,
                            text: nil,
                            images: imageURLs,
                            locations: nil,
                            tags: nil
                        )
                    }
                }
                
                let updateSuccess = try await NetworkService.shared.updateEntry(
                    apiKey: appState.apiKey ?? "",
                    jwt: appState.jwt ?? "",
                    entryId: appState.selectedEntry.id,
                    userId: userId,
                    username: username,
                    timestamp: appState.selectedEntry.timestamp,
                    text: entryText,
                    images: nil,
                    locations: locations,
                    tags: tags
                )
                
                isSavedSuccessfully = updateSuccess
            } catch {
                print("Error: \(error)")
                isSavedSuccessfully = false
            }
            isSavingEdit = false
        }
    }
}

//#Preview {
//    let testAppState = AppState()
//    testAppState.isLoggedIn = true
//    testAppState.username = "test"
//    testAppState.selectedEntry = .mock
//    
//    return ViewEntryPreviewWrapper().environmentObject(testAppState)
//}
//
//struct ViewEntryPreviewWrapper: View {
//    var body: some View {
//        ViewEntryView()
//    }
//}
