//
//  EditTagsView.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 2/5/25.
//

import SwiftUI

struct EditTagsView: View {
    @Binding var isEditTagsViewVisible: Bool
    let idTags: [IdentifiableTagData]
    let tags: [TagData]
    @State private var tagKey: String = ""
    @State private var tagValue: String = ""
    
    var onTagAdded: (IdentifiableTagData, TagData) -> Void
    var onTagRemoved: (Int) -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isEditTagsViewVisible = false
                }
            
            VStack {
                VStack(alignment: .leading, spacing: 20) {
                    ScrollView(.vertical) {
                        LazyVStack(alignment: .center, spacing: 16) {
                            ForEach(idTags) { idTag in
                                ZStack(alignment: .topTrailing) {
                                    VStack(alignment: .leading, spacing: 20) {
                                        HStack {
                                            Text("Tag key:")
                                                .font(.custom("Nexa Script Heavy", size: 18))
                                                .foregroundColor(.white)

                                            Text(idTag.key)
                                                .font(.custom("Nexa Script Light", size: 18))
                                                .foregroundColor(.white)
                                        }

                                        HStack {
                                            Text("Tag value (Optional):")
                                                .font(.custom("Nexa Script Heavy", size: 18))
                                                .foregroundColor(.white)

                                            Text(idTag.value ?? "-")
                                                .font(.custom("Nexa Script Light", size: 18))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .cornerRadius(12)
                                    .background(Color(red: 0.008, green: 0.282, blue: 0.451))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(red: 0.008, green: 0.282, blue: 0.451), lineWidth: 2)
                                    )
                                    
                                    Button(action: {
                                        if let index = idTags.firstIndex(of: idTag) {
                                            onTagRemoved(index)
                                        }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white)
                                            .background(Color.red.opacity(0.8))
                                            .clipShape(Circle())
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    
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
                    
                    HStack {
                        Button("Close") {
                            isEditTagsViewVisible = false
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
                            let newIdTag = IdentifiableTagData(
                                key: trimmedKey,
                                value: trimmedValue.isEmpty ? nil : trimmedValue
                            )
                            onTagAdded(newIdTag, newTag)
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
        .onAppear {
            print("On appear called in EditTagsView!")
            for idTag in idTags {
                print("IDTag key == \(idTag.key)")
                print("IDTag value == \(idTag.value ?? "-")")
            }
            print("Is idTags empty? \(idTags.isEmpty)")
            print("idTags count is \(idTags.count)")
            for tag in tags {
                print("Tag key == \(tag.key)")
                print("Tag value == \(tag.value ?? "-")")
            }
            print("Is tags empty? \(tags.isEmpty)")
            print("tags count is \(tags.count)")
            print("Should have printed all tag keys by now...")
        }
    }
}

#Preview {
    EditTagsViewPreview()
}

struct EditTagsViewPreview: View {
    @State private var isEditTagsViewVisible: Bool = true
    @State private var idTags: [IdentifiableTagData] = [
        IdentifiableTagData(
            key: "Home", value: "Vancouver"
        ),
        IdentifiableTagData(
            key: "Home", value: "Seattle"
        ),
        IdentifiableTagData(
            key: "Vacation", value: nil
        )
    ]
    @State private var tags: [TagData] = [
        TagData(
            key: "Home", value: "Vancouver"
        ),
        TagData(
            key: "Home", value: "Seattle"
        ),
        TagData(
            key: "Vacation", value: nil
        )
    ]
    
    var body: some View {
        EditTagsView(isEditTagsViewVisible: $isEditTagsViewVisible, idTags: idTags, tags: tags, onTagAdded: { idTag, tag in
            //
        }, onTagRemoved: { index in
            //
        })
    }
}
