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
    
    // For demo, let's pass some arrays of all possible locations & tags
    let allLocations: [Location]
    let allTags: [Tag]
    
    var body: some View {
        ZStack {
            // Gray semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    // Tapping outside closes the modal
                    isVisible = false
                }
            
            // The pop-up box in the center
            VStack(spacing: 16) {
                Text("Filter & Sort")
                    .font(.headline)
                
                // Multi-select for Locations
                VStack(alignment: .leading, spacing: 8) {
                    Text("Locations (multi-select):")
                        .font(.subheadline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(allLocations, id: \.self) { loc in
                                // a toggle-like button
                                SelectableChip(
                                    title: loc,
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
                        .font(.subheadline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(allTags, id: \.self) { tag in
                                SelectableChip(
                                    title: tag,
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

                // Single-select SortRule
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sort Rule:")
                        .font(.subheadline)
                    
                    Picker("Sort Rule", selection: $filterOptions.sortRule) {
                        ForEach(SortRule.allCases) { rule in
                            Text(rule.rawValue).tag(rule)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .padding(.horizontal)

                // If user selected .customRange, show the date pickers
                if filterOptions.sortRule == .customRange {
                    VStack {
                        DatePicker("From:", selection: Binding($filterOptions.fromDate, defaultValue: Date()), displayedComponents: .date)
                        DatePicker("To:", selection: Binding($filterOptions.toDate, defaultValue: Date()), displayedComponents: .date)
                    }
                    .padding(.horizontal)
                }
                
                // Buttons
                HStack {
                    Button("Cancel") {
                        isVisible = false
                    }
                    Spacer()
                    Button("Apply") {
                        // Close and the user’s selections are already in filterOptions
                        isVisible = false
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .frame(maxWidth: 350)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 8)
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
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
            .onTapGesture {
                action()
            }
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
    let locations = ["Seattle", "Vancouver", "Delta", "Paris", "Nazaré"]
    let tags = ["work", "personal", "vacation"]
    
    var body: some View {
        FilterModalView(
            isVisible: $isVisible, filterOptions: $filterOptions, allLocations: locations, allTags: tags
        )
    }
}
