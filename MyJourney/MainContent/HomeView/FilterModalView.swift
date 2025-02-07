//
//  FilterModalView.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 1/28/25.
//

import SwiftUI

struct FilterModalView: View {
    @Binding var isVisible: Bool
    @Binding var filterOptions: FilterOptions
    
    let allLocations: [LocationData]
    let allTags: [TagData]
    var onApply: () -> Void
    
    var body: some View {
        ZStack {
            // Gray semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    // Tapping outside closes the modal
                    isVisible = false
                }
            
            VStack {
                VStack(spacing: 16) {
                    Text("Filter & Sort")
                        .padding(.top, 12)
                        .font(.custom("Nexa Script Heavy", size: 24))
                        .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                    
                    // Multi-select for Locations
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Locations (multi-select):")
                            .font(.custom("Nexa Script Heavy", size: 16))
                            .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(allLocations, id: \.self) { loc in
                                    // a toggle-like button
                                    SelectableChip(
                                        title: loc.displayName ?? "Unknown",
                                        isSelected: filterOptions.selectedLocations.contains(loc)
                                    ) {
                                        // toggle
                                        if filterOptions.selectedLocations.contains(loc) {
                                            filterOptions.selectedLocations.remove(loc)
                                        } else {
                                            filterOptions.selectedLocations.insert(loc)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Multi-select for Tags
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags (multi-select):")
                            .font(.custom("Nexa Script Heavy", size: 16))
                            .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(allTags, id: \.self) { tag in
                                    SelectableChip(
                                        title: tag.key,
                                        isSelected: filterOptions.selectedTags.contains(tag)
                                    ) {
                                        if filterOptions.selectedTags.contains(tag) {
                                            filterOptions.selectedTags.remove(tag)
                                        } else {
                                            filterOptions.selectedTags.insert(tag)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Single-select Timeframe
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Timeframe:")
                            .font(.custom("Nexa Script Heavy", size: 16))
                            .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                        
                        Menu {
                            Picker("Timeframe", selection: $filterOptions.timeframe) {
                                ForEach(Timeframe.allCases) { frame in
                                    Text(frame.rawValue).tag(frame).font(.custom("Nexa Script Heavy", size: 16))
                                }
                            }
                            .frame(maxWidth: .infinity)
                        } label: {
                            Button(action: {}) {
                                Text($filterOptions.timeframe.id)
                                    .font(.custom("Nexa Script Light", size: 16))
                                    .frame(maxWidth: .infinity)
                                
                                Image(systemName: "arrow.down")
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
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                    
                    // If user selected .customRange, show the date pickers
                    if filterOptions.timeframe == .customRange {
                        VStack {
                            DatePicker("From:", selection: Binding($filterOptions.fromDate, defaultValue: Date()), displayedComponents: .date)
                            DatePicker("To:", selection: Binding($filterOptions.toDate, defaultValue: Date()), displayedComponents: .date)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Single-select SortRule
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sort Rule:")
                            .font(.custom("Nexa Script Heavy", size: 16))
                            .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                        
                        Menu {
                            Picker("Sort Rule", selection: $filterOptions.sortRule) {
                                ForEach(SortRule.allCases) { rule in
                                    Text(rule.rawValue).tag(rule).font(.custom("Nexa Script Heavy", size: 16))
                                }
                            }
                            .frame(maxWidth: .infinity)
                        } label: {
                            Button(action: {}) {
                                Text($filterOptions.sortRule.id)
                                    .font(.custom("Nexa Script Light", size: 16))
                                    .frame(maxWidth: .infinity)
                                
                                Image(systemName: "arrow.down")
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
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                    
                    // Buttons
                    HStack {
                        Button("Cancel") {
                            isVisible = false
                        }
                        .font(.custom("Nexa Script Heavy", size: 16))
                        .foregroundColor(Color(red: 0.008, green: 0.282, blue: 0.451))
                        
                        Spacer()
                        
                        Button("Apply") {
                            // Close and the user’s selections are already in filterOptions
                            onApply()
                            isVisible = false
                        }
                        .font(.custom("Nexa Script Heavy", size: 16))
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
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                //            .frame(maxWidth: 350)
                .background(Color(red: 0.533, green: 0.875, blue: 0.949))
                .cornerRadius(12)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.008, green: 0.157, blue: 0.251), lineWidth: 2)
                )
                .shadow(radius: 8)
            }
            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 200 : 10)
        }
    }
}

struct SelectableChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Text(title)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .font(.custom(isSelected ? "Nexa Script Heavy" : "Nexa Script Light", size: 16))
            .background(isSelected ? Color(red: 0.039, green: 0.549, blue: 0.749) : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
            .onTapGesture {
                action()
            }
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(red: 0.008, green: 0.157, blue: 0.251), lineWidth: 1)
            )
    }
}

extension Binding where Value == Date {
    // If the underlying optional is nil, use a default
    init(_ source: Binding<Date?>, defaultValue: Date) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { newVal in source.wrappedValue = newVal }
        )
    }
}

#Preview {
    let testAppState = AppState()
    testAppState.isLoggedIn = true
    testAppState.username = "test"
    
    return PreviewWrapper().environmentObject(testAppState)
}

struct PreviewWrapper: View {
    @State private var isVisible = true
    @State private var filterOptions = FilterOptions()
    let locations = [LocationData(latitude: 47.61945051921359, longitude: -122.33775910597386, displayName: "Seattle")]
    let tags = [TagData(key: "seattle", value: nil)]
    
    var body: some View {
        FilterModalView(
            isVisible: $isVisible, filterOptions: $filterOptions, allLocations: locations, allTags: tags, onApply: {}
        )
    }
}
