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
    @State private var showLocationSheet: Bool = false
    @State private var showPeopleSheet: Bool = false
    @State private var showCameraSheet: Bool = false
    @State private var showTagsSheet: Bool = false
    @State private var showInfoSheet: Bool = false
    @State private var hasImages: Bool = false
//    let entry: EntryListItem
    @State private var presignedURLs: [URL] = []
    @State private var images: [UIImage] = []
    @State private var showImagePicker = false
    @State private var pickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var locations: [LocationData] = []
    @State private var tags: [TagData] = []
    @State private var entryText: String = ""
    @State private var isLoading: Bool = false
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
    
//    let date = getDateString()
    let timestamp = getTimestampString()
    
    enum ViewMode: String, CaseIterable {
        case write = "Write"
        case preview = "Preview"
    }
    
    @State private var selectedViewMode: ViewMode = .write
    
    var body: some View {
        NavigationView {
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
                                    // saveEdit()
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
                        if !appState.selectedEntry.imageURLs.isEmpty {
                            if presignedURLs.isEmpty {
                                Text("Loading images...")
                                    .foregroundColor(.gray)
                            } else {
                                if presignedURLs.count == 1 {
                                    ScrollView(.horizontal) {
                                        HStack {
                                            ResilientAsyncImage(url: presignedURLs[0], progressColor: Color(red: 0.008, green: 0.157, blue: 0.251))
                                            
                                            if !images.isEmpty {
                                                ForEach(images, id: \.self) { img in
                                                    Image(uiImage: img)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 108, height: 108)
                                                        .clipped()
                                                        .cornerRadius(8)
                                                        .shadow(color: Color.black.opacity(0.8), radius: 3, x: 0, y: 2)
                                                }
                                            }
                                            
                                            if isEditing {
                                                Button(action: {
                                                    showCameraSheet = true
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
                                
                                if presignedURLs.count == 2 {
                                    ScrollView(.horizontal) {
                                        HStack {
                                            ResilientAsyncImage(url: presignedURLs[0], progressColor: Color(red: 0.008, green: 0.157, blue: 0.251))

                                            ResilientAsyncImage(url: presignedURLs[1], progressColor: Color(red: 0.008, green: 0.157, blue: 0.251))
                                            
                                            if !images.isEmpty {
                                                ForEach(images, id: \.self) { img in
                                                    Image(uiImage: img)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 108, height: 108)
                                                        .clipped()
                                                        .cornerRadius(8)
                                                        .shadow(color: Color.black.opacity(0.8), radius: 3, x: 0, y: 2)
                                                }
                                            }

                                            if isEditing {
                                                Button(action: {
                                                    showCameraSheet = true
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
                                
                                if presignedURLs.count >= 3 {
                                    ScrollView(.horizontal) {
                                        HStack {
                                            ForEach(presignedURLs, id: \.self) { url in
                                                ResilientAsyncImage(url: url, progressColor: Color(red: 0.008, green: 0.157, blue: 0.251))
                                            }
                                            
                                            if !images.isEmpty {
                                                ForEach(images, id: \.self) { img in
                                                    Image(uiImage: img)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 108, height: 108)
                                                        .clipped()
                                                        .cornerRadius(8)
                                                        .shadow(color: Color.black.opacity(0.8), radius: 3, x: 0, y: 2)
                                                }
                                            }
                                            
                                            if isEditing {
                                                Button(action: {
                                                    showCameraSheet = true
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
                                        // Add button here for adding locations
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
                                                // TODO: create modal for viewing ALL locations, make each location tappable to open the map; they will appear as selectable chips just like in FilterModalView
                                            }
                                    }
                                }
                                
                                Spacer()
                                
                                
                                let tags = appState.selectedEntry.tags.prefix(3).map { IdentifiableTagData(
                                    key: $0.key,
                                    value: $0.value
                                ) }
                                VStack(alignment: .leading) {
                                    if !tags.isEmpty {
                                        HStack {
                                            Image(systemName: "tag")
                                                .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                                                .font(.title2)
                                            Text("Tags:")
                                                .font(.custom("Nexa Script Heavy", size: 16))
                                                .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                                        }
                                    } else {
                                        // Add button here for adding tags
                                    }
                                    
                                    ForEach(tags) { tag in
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
                                                // TODO: create modal for viewing ALL tags, adding new tags, removing tags; they will appear as selectable chips just like in FilterModalView
                                            }
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
                                        // Add button here for adding locations
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
                                                // TODO: create modal for viewing ALL locations, make each location tappable to open the map; they will appear as selectable chips just like in FilterModalView
                                            }
                                    }
                                }
                                
                                Spacer()
                                
                                
                                let tags = appState.selectedEntry.tags.prefix(3).map { IdentifiableTagData(
                                    key: $0.key,
                                    value: $0.value
                                ) }
                                VStack(alignment: .leading) {
                                    if !tags.isEmpty {
                                        HStack {
                                            Image(systemName: "tag")
                                                .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                                                .font(.title2)
                                            Text("Tags:")
                                                .font(.custom("Nexa Script Heavy", size: 16))
                                                .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                                        }
                                    } else {
                                        // Add button here for adding tags
                                    }
                                    
                                    ForEach(tags) { tag in
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
                                                // TODO: create modal for viewing ALL tags, adding new tags, removing tags; they will appear as selectable chips just like in FilterModalView
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
                    .offset(y: UIScreen.main.bounds.height - 560)
                }
            }
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
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: pickerSource) { uiImage in
                    if images.count < 3 {
                        images.append(uiImage)
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
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func fetchPresignedURLs() async {
        var tempURLs: [URL] = []
        
        for (_, key) in (appState.selectedEntry.imageURLs.enumerated()) {
            do {
                let presignedURL = try await NetworkService.shared.getPresignedURLForKey(key)
                tempURLs.append(presignedURL)
            } catch {
                print("Error getting presigned URL for \(key): \(error)")
            }
        }
        
        await MainActor.run {
            self.presignedURLs = tempURLs
        }
    }
    
    private func saveEdit() {
        guard let username = appState.username, !entryText.isEmpty else { return }
        isSavingEdit = true
        
        Task {
            do {
                var updatedImages: [String] = appState.selectedEntry.imageURLs.map { $0 }
                if !images.isEmpty {
                    let uploadResult = try await NetworkService.shared.uploadImages(
                        username: username,
                        uuid: appState.selectedEntry.id,
                        images: images
                    )
                    if uploadResult.success {
                        for imgKey in uploadResult.imageURLs {
                            updatedImages.append(imgKey)
                        }
                    }
                }
                
                var updatedLocations: [LocationData] = appState.selectedEntry.locations.map { $0 }
                if !locations.isEmpty {
                    for loc in locations {
                        updatedLocations.append(loc)
                    }
                }
                
                var updatedTags: [TagData] = appState.selectedEntry.tags.map { $0 }
                if !tags.isEmpty {
                    for tag in tags {
                        updatedTags.append(tag)
                    }
                }
                
                let updateSuccess = try await NetworkService.shared.updateEntry(
                    entryId: appState.selectedEntry.id,
                    username: username,
                    text: entryText,
                    images: updatedImages,
                    locations: updatedLocations,
                    tags: updatedTags
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

#Preview {
    let testAppState = AppState()
    testAppState.isLoggedIn = true
    testAppState.username = "test"
    testAppState.selectedEntry = .mock
    
    return ViewEntryPreviewWrapper().environmentObject(testAppState)
}

struct ViewEntryPreviewWrapper: View {
    var body: some View {
        ViewEntryView()
    }
}
