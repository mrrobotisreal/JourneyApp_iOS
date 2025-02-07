//
//  EditLocationsView.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 2/5/25.
//

import SwiftUI

struct EditLocationsView: View {
    @Binding var isEditLocationsViewVisible: Bool
    @Binding var showLocationPicker: Bool
    let idLocs: [IdentifiableLocationData]
    let locs: [LocationData]
    
    var onLocRemoved: (Int) -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isEditLocationsViewVisible = false
                }
            
            VStack {
                VStack(alignment: .leading, spacing: 20) {
                    ScrollView(.vertical) {
                        LazyVStack(alignment: .center, spacing: 16) {
                            ForEach(idLocs) { idLoc in
                                ZStack(alignment: .topTrailing) {
                                    VStack(alignment: .leading, spacing: 20) {
                                        HStack {
                                            Text("Display name:")
                                                .font(.custom("Nexa Script Heavy", size: 18))
                                                .foregroundColor(.white)
                                            
                                            Text(idLoc.displayName ?? "Unknown location")
                                                .font(.custom("Nexa Script Light", size: 18))
                                                .foregroundColor(.white)
                                        }
                                        
                                        HStack {
                                            Text("Latitude:")
                                                .font(.custom("Nexa Script Heavy", size: 18))
                                                .foregroundColor(.white)
                                            
                                            Text("\(idLoc.latitude)")
                                                .font(.custom("Nexa Script Light", size: 18))
                                                .foregroundColor(.white)
                                        }
                                        
                                        HStack {
                                            Text("Longitude:")
                                                .font(.custom("Nexa Script Heavy", size: 18))
                                                .foregroundColor(.white)
                                            
                                            Text("\(idLoc.longitude)")
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
                                        if let index = idLocs.firstIndex(of: idLoc) {
                                            onLocRemoved(index)
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
                    
                    HStack {
                        Button("Close") {
                            isEditLocationsViewVisible = false
                        }
                        .font(.custom("Nexa Script Light", size: 18))
                        .foregroundColor(Color(red: 0.008, green: 0.282, blue: 0.451))

                        Spacer()

                        Button(action: {
                            showLocationPicker = true
                        }) {
                            Text("Choose location")
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
            print("EditLocationsView has appeared!!!")
        }
    }
}

#Preview {
    EditLocationsViewPreviewWrapper()
}

struct EditLocationsViewPreviewWrapper: View {
    @State private var isEditLocationsViewVisible: Bool = true
    @State private var showLocationPicker: Bool = true
    @State private var idLocs: [IdentifiableLocationData] = [
        IdentifiableLocationData(latitude: 47.61945051921359, longitude: -122.33775910597386, displayName: "Seattle"),
        IdentifiableLocationData(latitude: 47.61945051921359, longitude: -122.33775910597386, displayName: "Vancouver"),
        IdentifiableLocationData(latitude: 47.61945051921359, longitude: -122.33775910597386, displayName: "Delta"),
        IdentifiableLocationData(latitude: 47.61945051921359, longitude: -122.33775910597386, displayName: "Kyiv"),
        IdentifiableLocationData(latitude: 47.61945051921359, longitude: -122.33775910597386, displayName: "Vienna")
    ]
    @State private var locs: [LocationData] = [
        LocationData(latitude: 47.61945051921359, longitude: -122.33775910597386, displayName: "Seattle"),
        LocationData(latitude: 47.61945051921359, longitude: -122.33775910597386, displayName: "Vancouver"),
        LocationData(latitude: 47.61945051921359, longitude: -122.33775910597386, displayName: "Delta"),
        LocationData(latitude: 47.61945051921359, longitude: -122.33775910597386, displayName: "Kyiv"),
        LocationData(latitude: 47.61945051921359, longitude: -122.33775910597386, displayName: "Vienna")
    ]

    var body: some View {
        EditLocationsView(
            isEditLocationsViewVisible: $isEditLocationsViewVisible,
            showLocationPicker: $showLocationPicker,
            idLocs: idLocs,
            locs: locs,
            onLocRemoved: {index in
                //
            }
        )
    }
}
