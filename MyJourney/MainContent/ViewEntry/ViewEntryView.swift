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
//                            Text("")
//                                .padding()
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
                            //                        let date = getFullDateStr(fromISO: entry.timestamp)
                            //                        let time = getTimeStr(fromISO: entry.timestamp)
                            let date = getFullDateStr(fromISO: appState.selectedEntry?.timestamp ?? "")
                            let time = getTimeStr(fromISO: appState.selectedEntry?.timestamp ?? "")
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
                                    //                            saveEdit()
                                }) {
                                    Text("Save")
                                        .font(.custom("Nexa Script Light", size: 18))
                                        .foregroundColor(.white)
                                }
                                .padding()
                            }
                        } else {
                            Button(action: {
                                //                            entryText = entry.text
                                entryText = appState.selectedEntry?.text ?? ""
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
                        if !(appState.selectedEntry?.imageURLs.isEmpty ?? true) {
                            //                    if !entry.imageURLs.isEmpty {
                            if presignedURLs.isEmpty {
                                Text("Loading images...")
                                    .foregroundColor(.gray)
                            } else {
                                if presignedURLs.count == 1 {
                                    HStack {
                                        Spacer()
                                        
                                        ResilientAsyncImage(url: presignedURLs[0], progressColor: Color(red: 0.008, green: 0.157, blue: 0.251))
                                        
                                        Spacer()
                                    }
                                }
                                
                                if presignedURLs.count == 2 {
                                    HStack {
                                        Spacer()
                                        
                                        ResilientAsyncImage(url: presignedURLs[0], progressColor: Color(red: 0.008, green: 0.157, blue: 0.251))
                                        
                                        Spacer()
                                        
                                        ResilientAsyncImage(url: presignedURLs[1], progressColor: Color(red: 0.008, green: 0.157, blue: 0.251))
                                        
                                        Spacer()
                                    }
                                }
                                
                                if presignedURLs.count >= 3 {
                                    ScrollView(.horizontal) {
                                        HStack {
                                            ForEach(presignedURLs, id: \.self) { url in
                                                ResilientAsyncImage(url: url, progressColor: Color(red: 0.008, green: 0.157, blue: 0.251))
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
                        } else {
                            ScrollView(.vertical) {
                                //                            let attributed = parseAdvancedMarkdown(entry.text)
                                let attributed = parseAdvancedMarkdown(appState.selectedEntry?.text ?? "")
                                Text(attributed)
                                    .font(.system(size: 16))
                                
                                Spacer()
                            }
                            .padding()
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
                    
                    //                if isEditing {
                    //                    HStack {
                    //                        Spacer()
                    //
                    //                        Button(action: {
                    //                            // action here...
                    //                        }) {
                    //                            Image(systemName: "location.circle.fill")
                    //                                .font(.title)
                    //                                .foregroundColor(.white)
                    //                        }
                    //                        .padding()
                    //
                    //
                    //                        Spacer()
                    //
                    //                        Button(action: {
                    //                            // action here...
                    //                        }) {
                    //                            Image(systemName: "person.circle.fill")
                    //                                .font(.title)
                    //                                .foregroundColor(.white)
                    //                        }
                    //                        .padding()
                    //
                    //
                    //                        Spacer()
                    //
                    //                        Button(action: {
                    //                            showCameraSheet = true
                    //                        }) {
                    //                            Image(systemName: "camera.circle.fill")
                    //                                .font(.title)
                    //                                .foregroundColor(.white)
                    //                        }
                    //                        .padding()
                    //
                    //
                    //                        Spacer()
                    //
                    //                        Button(action: {
                    //                            // action here...
                    //                        }) {
                    //                            Image(systemName: "tag.circle.fill")
                    //                                .font(.title)
                    //                                .foregroundColor(.white)
                    //                        }
                    //                        .padding()
                    //
                    //
                    //                        Spacer()
                    //
                    //                        Button(action: {
                    //                            showInfoSheet = true
                    //                        }) {
                    //                            Image(systemName: "info.circle.fill")
                    //                                .font(.title)
                    //                                .foregroundColor(.white)
                    //                        }
                    //                        .padding()
                    //
                    //
                    //                        Spacer()
                    //                    }
                    //                    .frame(maxWidth: .infinity)
                    //                    .background(Color(red: 0.008, green: 0.282, blue: 0.451))
                    //                }
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
                if (appState.selectedEntry?.imageURLs.count ?? 0) > 0 {
                    //            if entry.imageURLs.count > 0 {
                    if presignedURLs.isEmpty {
                        Task {
                            await fetchPresignedURLs()
                        }
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
                    homeViewModel.fetchEntries(username: appState.username ?? "")
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func fetchPresignedURLs() async {
        var tempURLs: [URL] = []
        for key in (appState.selectedEntry?.imageURLs ?? []) {
//        for key in entry.imageURLs {
            do {
                let presignedURL = try await getPresignedURLForKey(key)
                tempURLs.append(presignedURL)
            } catch {
                print("Presign GET error for \(key): \(error)")
            }
        }
        
        presignedURLs = tempURLs
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
