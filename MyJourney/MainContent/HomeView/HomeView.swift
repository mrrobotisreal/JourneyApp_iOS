//
//  HomeView.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 1/18/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var viewEntryViewModel = ViewEntryViewModel()
    @StateObject private var viewModel = HomeViewModel()
    @Binding var path: NavigationPath
    @State private var hasEntries = false
    @State private var showActionSheet = false
    @State private var searchQuery: String = ""
    @State private var filterOptions = FilterOptions()
    
    @State private var showFilters = false
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color(red: 0.533, green: 0.875, blue: 0.949)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    HStack {
                        TextField("Search entries...", text: $searchQuery)
                            .font(.custom("Nexa Script Light", size: 16))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disableAutocorrection(true)
                        
                        Button(action: {
                            showFilters = true
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.title2)
                                .padding(6)
                        }
                        .foregroundColor(.white)
                    }
                    .padding()
                    
                    if viewModel.entries.count <= 0 {
                        VStack {
                            Spacer()
                            
                            Text("You haven't created any entries yet... Click the button below or swipe up from the bottom and open the menu to create a new entry!")
                                .font(.custom("Nexa Script Light", size: 18))
                                .padding()
                            
                            Button(action: {
                                path.append("createNewEntry")
                            }) {
                                Image(systemName: "lightbulb.max.fill")
                                    .foregroundColor(.white)
                                Text("Create A New Entry")
                                    .font(.custom("Nexa Script Heavy", size: 18))
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
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.533, green: 0.875, blue: 0.949))
                        .clipShape(RoundedRectangle(cornerRadius: 0))
                        .overlay(
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(Color(red: 0.008, green: 0.157, blue: 0.251), lineWidth: 2)
                        )
                    } else {
                        //                    NavigationStack(path: $path) {
                        List {
                            ForEach(filteredEntries, id: \.id) { entry in
                                VStack {
                                    EntryListItemView(entryListItem: entry, query: searchQuery)
                                        .onAppear {
                                            if entry == filteredEntries.last {
                                                viewModel.fetchEntries(username: appState.username ?? "")
                                            }
                                        }
                                        .onTapGesture(perform: {
                                            updateSelectedEntry(entry: entry)
                                            path.append("viewEntry")
                                        })
                                }
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets())
                                .padding()
                            }
                            
                            if viewModel.isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .background(Color(red: 0.533, green: 0.875, blue: 0.949))
                        .clipShape(RoundedRectangle(cornerRadius: 0))
                        .overlay(
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(Color(red: 0.008, green: 0.157, blue: 0.251), lineWidth: 2)
                        )
                        //                        .navigationDestination(for: EntryListItem.self) { entry in
                        //                            ViewEntryView()
                        //                        }
                        //                    }
                    }
                    
                    Button(action: {
                        showActionSheet = true
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .font(.title)
                    }
                    .foregroundColor(.white)
                    .padding()
                }
                .background(Color(red: 0.008, green: 0.282, blue: 0.451))
                
                if showActionSheet {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showActionSheet = false
                        }
                    
                    VStack(spacing: 16) {
                        Text("Main Menu")
                            .font(.custom("Nexa Script Heavy", size: 18))
                        
                        Button(action: {
                            path.append("createNewEntry")
                        }) {
                            Image(systemName: "lightbulb.max.fill")
                                .foregroundColor(.white)
                            Spacer()
                            Text("Create A New Entry")
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
                            Image(systemName: "doc.text.magnifyingglass")
                                .foregroundColor(.white)
                            Spacer()
                            Text("Search Entries (Advanced)")
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
                            Image(systemName: "gear")
                                .foregroundColor(.white)
                            Spacer()
                            Text("Settings")
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
                            // add more logic here...
                            showActionSheet = false
                        }) {
                            Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                                .foregroundColor(.white)
                            Spacer()
                            Text("Log Out")
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
                            showActionSheet = false
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
                    .animation(.easeInOut, value: showActionSheet)
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
                    .offset(y: UIScreen.main.bounds.height - 600)
                }
            }
            .onAppear {
                viewModel.fetchEntries(username: appState.username ?? "")
            }
            .onChange(of: searchQuery) {
                // TODO: server search logic will be added here...
            }
            .overlay(
                Group {
                    if showFilters {
                        FilterModalView(
                            isVisible: $showFilters, filterOptions: $filterOptions, allLocations: [], allTags: []
                        )
                    }
                }
            )
            .navigationDestination(for: EntryListItem.self) { entry in
                ViewEntryView()
            }
        }
    }
    
    var filteredEntries: [EntryListItem] {
        guard !searchQuery.isEmpty else {
            return viewModel.entries
        }
        
        return viewModel.entries.filter { entry in
            !findSubstrings(in: entry.text, query: searchQuery).isEmpty
        }
    }
}

extension HomeView {
    private func updateSelectedEntry(entry: EntryListItem) {
        appState.selectedEntry = entry
    }
}

#Preview {
    let testAppState = AppState()
    testAppState.isLoggedIn = true
    testAppState.username = "test"
    testAppState.selectedEntry = .mock
    
    return HomePreviewWrapper().environmentObject(testAppState)
}

struct HomePreviewWrapper: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        HomeView(path: $path)
    }
}
