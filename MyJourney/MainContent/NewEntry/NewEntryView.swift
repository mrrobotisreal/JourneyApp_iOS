//
//  NewEntryView.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 1/19/25.
//

import SwiftUI
import UIKit

struct NewEntryView: View {
    @State private var showLocationSheet: Bool = false
    @State private var showPeopleSheet: Bool = false
    @State private var showCameraSheet: Bool = false
    @State private var showTagsSheet: Bool = false
    @State private var showInfoSheet: Bool = false
    @State private var hasImages: Bool = false
    @State private var images: [UIImage] = []
    @State private var showImagePicker = false
    @State private var pickerSource: UIImagePickerController.SourceType = .photoLibrary
//    @State private var entryText: String = ""
    @State private var entryText: String = """
    # My Title
    
    Some text with *bold* and ~underline~.
    
    - A bullet list item
    - [ ] An unchecked checkbox
    
    ## Subheading
    
    Here is -strikethrough- and {color: red}red text{color} and nesting like *bold ~underlined nested~ inside*.
    """
    
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
                            
//                            Spacer()
                        }
//                        .padding()
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
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: pickerSource) { uiImage in
                if images.count < 3 {
                    images.append(uiImage)
                }
            }
        }
    }
}

extension NewEntryView {
    /// A simple markdown parser that handles:
    /// *bold*  -> bold text
    /// _italic_ -> italic text
    /// `code`  -> monospaced code snippet (violet fg, dark bg)
    ///
    /// It removes the delimiter characters (*, _, `) from the final display.
    private func parseSimpleMarkdown(_ text: String) -> AttributedString {
        let mutable = NSMutableAttributedString(string: text)
        
        let fullRange = NSRange(location: 0, length: mutable.length)
        mutable.addAttributes([.font: UIFont.systemFont(ofSize: 16)], range: fullRange)
        
        applyPattern("\\*(.+?)\\*", to: mutable, attributes: [
            .font: UIFont.boldSystemFont(ofSize: 16)
        ])
        
        applyPattern("\\_(.+?)\\_", to: mutable, attributes: [
            .font: UIFont.italicSystemFont(ofSize: 16)
        ])
        
        let codeAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Menlo", size: 16) ?? UIFont.monospacedSystemFont(ofSize: 16, weight: .regular),
            .foregroundColor: UIColor.green,
            .backgroundColor: UIColor(white: 0.1, alpha: 1.0)
        ]
        applyPattern("\\`(.+?)\\`", to: mutable, attributes: codeAttributes)
        
        return AttributedString(mutable)
    }
    
    /// Finds all occurrences of `pattern` in `mutable`, applies `attributes` to the text inside
    /// the delimiters, and then removes the delimiter characters.
    private func applyPattern(_ pattern: String, to mutable: NSMutableAttributedString, attributes: [NSAttributedString.Key : Any]) {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return
        }
        
        // Get all matches
        let results = regex.matches(in: mutable.string, range: NSRange(location: 0, length: mutable.length))
        
        for match in results.reversed() {
            let matchRange = match.range
            guard matchRange.length >= 3 else { continue }
            
            let innerRange = NSRange(location: matchRange.location + 1, length: matchRange.length - 2)
            
            mutable.addAttributes(attributes, range: innerRange)
            
            mutable.replaceCharacters(in: NSRange(location: matchRange.location + matchRange.length - 1, length: 1), with: "")
            
            mutable.replaceCharacters(in: NSRange(location: matchRange.location, length: 1), with: "")
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
