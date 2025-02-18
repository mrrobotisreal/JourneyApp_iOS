//
//  AddTagView.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 2/1/25.
//

import SwiftUI

struct AddTagView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var isAddTagViewVisible: Bool
    @State private var tagKey: String = ""
    @State private var tagValue: String = ""
    
    var onTagAdded: (TagData) -> Void
    
    var body: some View {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Tapping outside closes the modal
                        isAddTagViewVisible = false
                    }
                    
                VStack {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Tag key:")
                            .font(.custom("Nexa Script Heavy", size: 18))
                            .foregroundColor(Color(red: 0.008, green: 0.282, blue: 0.451))
                        
                        TextField("Key", text: $tagKey)
                            .autocapitalization(.none)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Text("Tag value (Optional):")
                            .font(.custom("Nexa Script Heavy", size: 18))
                            .foregroundColor(Color(red: 0.008, green: 0.282, blue: 0.451))
                        
                        TextField("Value (Optional)", text: $tagValue)
                            .autocapitalization(.none)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        //                        Spacer()
                        
                        HStack {
                            Button("Cancel") {
                                isAddTagViewVisible = false
                                //                                dismiss()
                            }
                            .font(.custom("Nexa Script Light", size: 18))
                            .foregroundColor(Color(red: 0.008, green: 0.282, blue: 0.451))
                            
                            Spacer()
                            
                            Button(action: {
                                let trimmedKey = tagKey.trimmingCharacters(in: .whitespacesAndNewlines)
                                guard !trimmedKey.isEmpty else { return }
                                let trimmedValue = tagValue.trimmingCharacters(in: .whitespacesAndNewlines)
                                let newTag = TagData(
                                    key: trimmedKey,
                                    value: trimmedValue.isEmpty ? nil : trimmedValue
                                )
                                onTagAdded(newTag)
                                //                                dismiss()
                                isAddTagViewVisible = false
                            }) {
                                Text("Add tag")
                                    .font(.custom("Nexa Script Heavy", size: 18))
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
    AddTagViewPreviewWrapper()
}

struct AddTagViewPreviewWrapper: View {
    @State private var isAddTagViewVisible: Bool = true
    
    var body: some View {
        AddTagView(isAddTagViewVisible: $isAddTagViewVisible, onTagAdded: { newTag in
        })
    }
}
