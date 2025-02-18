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
    @State private var page: Int = 1
    @State private var limit: Int = 20
    @State private var searchTask: Task<Void, Never>? = nil
    @State private var selectedRoute: String? = nil
    @State private var newEntryActive: Bool = false
//    @State private var isRefreshing: Bool = false
    
    @State private var showFilters = false
    
    var body: some View {
//        AdaptiveNavigationView {
            ZStack {
                Color(red: 0.533, green: 0.875, blue: 0.949)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    HStack {
                        TextField("Search entries...", text: $searchQuery)
                            .font(.custom("Nexa Script Light", size: 16))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disableAutocorrection(true)
                            .onChange(of: searchQuery) {
                                Task {
                                    debounceSearch()
                                }
                            }
                        
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
                        NoEntriesView(navigateToNewEntry: {
                            path.append("createNewEntry")
                        })
//                        VStack {
//                            Spacer()
//                            
//                            Text("You haven't created any entries yet... Click the button below or swipe up from the bottom and open the menu to create a new entry!")
//                                .font(.custom("Nexa Script Light", size: 18))
//                                .padding()
//                            
//                            Button(action: {
//                                path.append("createNewEntry")
//                            }) {
//                                Image(systemName: "lightbulb.max.fill")
//                                    .foregroundColor(.white)
//                                Text("Create A New Entry")
//                                    .font(.custom("Nexa Script Heavy", size: 18))
//                                    .foregroundColor(.white)
//                            }
//                            .padding(.horizontal, 12)
//                            .padding(.vertical, 6)
//                            .foregroundColor(.white)
//                            .cornerRadius(12)
//                            .background(Color(red: 0.039, green: 0.549, blue: 0.749))
//                            .clipShape(RoundedRectangle(cornerRadius: 12))
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 12)
//                                    .stroke(Color(red: 0.008, green: 0.157, blue: 0.251), lineWidth: 2)
//                            )
//                            
//                            Spacer()
//                        }
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color(red: 0.533, green: 0.875, blue: 0.949))
//                        .clipShape(RoundedRectangle(cornerRadius: 0))
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 0)
//                                .stroke(Color(red: 0.008, green: 0.157, blue: 0.251), lineWidth: 2)
//                        )
                    } else {
//                        EntriesView()
                        
                        List {
                            ForEach(viewModel.entries) { entry in
                                EntryListItemView(entryListItem: entry, query: searchQuery)
//                                    .onAppear {
//                                        if entry == filteredEntries.last {
//                                            viewModel.fetchEntries(username: appState.username ?? "")
//                                            // TODO: implement pagination...
//                                        }
//                                    }
                                    .id("\(entry.id)-\(entry.imageSignature)")
                                    .onTapGesture {
                                        Task {
                                            updateSelectedEntry(entry: entry)
                                            selectedRoute = "viewEntry"
                                        }
                                    }
                                    .listRowBackground(Color(red: 0.533, green: 0.875, blue: 0.949))
                            }
                            
                            if viewModel.isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                            }
                        }
                        .refreshable(action: {
                            Task {
                                print("Fetching entries again")
                                await doSearch()
                            }
                        })
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .background(Color(red: 0.533, green: 0.875, blue: 0.949))
                        .clipShape(RoundedRectangle(cornerRadius: 0))
                        .overlay(
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(Color(red: 0.008, green: 0.157, blue: 0.251), lineWidth: 2)
                        )
                        .onReceive(NotificationCenter.default.publisher(for: .newEntryCreated)) {_ in
                            print("Received notification, refreshing entries")
                            Task {
                                await doSearch()
                            }
                        }
                    }
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            openSettingsView()
                        }) {
                            Image(systemName: "gear")
                                .imageScale(.large)
                                .font(.system(size: 26))
                        }
                        .foregroundColor(.white)
                        .padding()
                        
                        Spacer()
                        
                        Button(action: {
                            path.append("createNewEntry")
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .imageScale(.large)
                                .font(.system(size: 40))
                        }
                        .foregroundColor(.white)
                        .padding()
                        
                        Spacer()
                        
                        Button(action: {
                            handleLogout()
                        }) {
                            Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                                .imageScale(.large)
                                .font(.system(size: 26))
                        }
                        .foregroundColor(.white)
                        .padding()
                        
                        Spacer()
                    }
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
                    .offset(y: UIScreen.main.bounds.height - 580)
                }
            }
            .onAppear {
                Task {
                    await doSearch()
//                    viewModel.fetchEntries(apiKey: appState.apiKey ?? "", jwt: appState.jwt ?? "", userId: appState.userId ?? "", username: appState.username ?? "")
                    viewModel.fetchUniqueLocationsAndTags(apiKey: appState.apiKey ?? "", jwt: appState.jwt ?? "", user: appState.username ?? "")
                }
            }
            .overlay(
                Group {
                    if showFilters {
                        FilterModalView(
                            isVisible: $showFilters, filterOptions: $filterOptions, allLocations: viewModel.allUniqueLocations, allTags: viewModel.allUniqueTags, onApply: {
                                Task {
                                    do {
                                        await doSearch()
                                    }
                                }
                            }
                        )
                    }
                }
            )
//        }
    }
    
    @MainActor
    private func doSearch() async {
        do {
//                await viewModel.searchEntries(apiKey: appState.apiKey ?? "",
//                                        jwt: appState.jwt ?? "",
//                                        user: appState.username ?? "",
//                                        page: page,
//                                        limit: limit,
//                                        filterOptions: filterOptions,
//                                        searchQuery: searchQuery)
            // TODO: figure out a better way to search and essentially cache all entries separately...
            let entries = try await NetworkService.shared.searchEntries(
                apiKey: appState.apiKey ?? "",
                jwt: appState.jwt ?? "",
                user: appState.username ?? "",
                page: page,
                limit: limit,
                searchQuery: searchQuery,
                filterOptions: filterOptions
            )
            viewModel.entries = entries
            appState.allEntries = entries
        } catch {
            print("Search entries error in HomeView!!! \(error)")
        }
    }
    
    private func debounceSearch() {
        searchTask?.cancel()
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if !Task.isCancelled {
                await doSearch()
            }
        }
    }
    
    var filteredEntries: [EntryListItem] {
        let initialResults: [EntryListItem] = viewModel.entries
        let locationFiltered = filterEntries(initialResults, byLocations: filterOptions.selectedLocations)
        let tagFiltered = filterEntries(locationFiltered, byTags: filterOptions.selectedTags)
        let timeFiltered = filterEntries(tagFiltered, byTimeframe: filterOptions.timeframe)
        let searchFiltered = searchQuery.isEmpty ? timeFiltered : filterEntries(timeFiltered, bySearchQuery: searchQuery)
        return sortEntries(searchFiltered, by: filterOptions.sortRule)
    }

    func filterEntries(_ entries: [EntryListItem], byLocations locations: Set<LocationData>) -> [EntryListItem] {
        guard !locations.isEmpty else { return entries }
        return entries.filter { entry in
            let entryLocSet = Set(entry.locations)
            return !entryLocSet.intersection(locations).isEmpty
        }
    }

    func filterEntries(_ entries: [EntryListItem], byTags tags: Set<TagData>) -> [EntryListItem] {
        guard !tags.isEmpty else { return entries }
        return entries.filter { entry in
            let entryTagSet = Set(entry.tags)
            return !entryTagSet.intersection(tags).isEmpty
        }
    }

    func filterEntries(_ entries: [EntryListItem], byTimeframe timeframe: Timeframe) -> [EntryListItem] {
        var results: [EntryListItem] = viewModel.entries
        
        switch filterOptions.timeframe {
        case .all:
            break
        case .past30Days:
            let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? .distantPast
            results = results.filter { entry in
                guard let entryDate = getTimestampDate(timestampStr: entry.timestamp) else {
                    return false
                }
                return entryDate >= cutoff
            }
        case .past3Months:
            let cutoff = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? .distantPast
            results = results.filter { entry in
                guard let entryDate = getTimestampDate(timestampStr: entry.timestamp) else {
                    return false
                }
                return entryDate >= cutoff
            }
        case .past6Months:
            let cutoff = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? .distantPast
            results = results.filter { entry in
                guard let entryDate = getTimestampDate(timestampStr: entry.timestamp) else {
                    return false
                }
                return entryDate >= cutoff
            }
        case .pastYear:
            let cutoff = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? .distantPast
            results = results.filter { entry in
                guard let entryDate = getTimestampDate(timestampStr: entry.timestamp) else {
                    return false
                }
                return entryDate >= cutoff
            }
        case .customRange:
            if let from = filterOptions.fromDate {
                results = results.filter { entry in
                    guard let entryDate = getTimestampDate(timestampStr: entry.timestamp) else {
                        return false
                    }
                    return entryDate >= from
                }
            }
            if let to = filterOptions.toDate {
                results = results.filter { entry in
                    guard let entryDate = getTimestampDate(timestampStr: entry.timestamp) else {
                        return false
                    }
                    return entryDate >= to
                }
            }
        }
        
        return results
    }

    func filterEntries(_ entries: [EntryListItem], bySearchQuery query: String) -> [EntryListItem] {
        return entries.filter { entry in
            !findSubstrings(in: entry.text, query: query).isEmpty
        }
    }

    func sortEntries(_ entries: [EntryListItem], by sortRule: SortRule) -> [EntryListItem] {
        switch sortRule {
        case .newest:
            return entries.sorted { $0.timestamp > $1.timestamp }
        case .oldest:
            return entries.sorted { $0.timestamp < $1.timestamp }
        }
    }
    
//    var filteredEntries: [EntryListItem] {
//        var results: [EntryListItem] = viewModel.entries
//        
//        if !filterOptions.selectedLocations.isEmpty {
//            results = results.filter { entry in
//                let entryLocSet = Set(entry.locations)
//                let overlap = entryLocSet.intersection(filterOptions.selectedLocations)
//                return !overlap.isEmpty
//            }
//        }
//        
//        if !filterOptions.selectedTags.isEmpty {
//            results = results.filter { entry in
//                let entryTagSet = Set(entry.tags)
//                let overlap = entryTagSet.intersection(filterOptions.selectedTags)
//                return !overlap.isEmpty
//            }
//        }
//        
//        switch filterOptions.timeframe {
//        case .all:
//            break
//        case .past30Days:
//            let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? .distantPast
//            results = results.filter { entry in
//                guard let entryDate = getTimestampDate(timestampStr: entry.timestamp) else {
//                    return false
//                }
//                return entryDate >= cutoff
//            }
//        case .past3Months:
//            let cutoff = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? .distantPast
//            results = results.filter { entry in
//                guard let entryDate = getTimestampDate(timestampStr: entry.timestamp) else {
//                    return false
//                }
//                return entryDate >= cutoff
//            }
//        case .past6Months:
//            let cutoff = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? .distantPast
//            results = results.filter { entry in
//                guard let entryDate = getTimestampDate(timestampStr: entry.timestamp) else {
//                    return false
//                }
//                return entryDate >= cutoff
//            }
//        case .pastYear:
//            let cutoff = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? .distantPast
//            results = results.filter { entry in
//                guard let entryDate = getTimestampDate(timestampStr: entry.timestamp) else {
//                    return false
//                }
//                return entryDate >= cutoff
//            }
//        case .customRange:
//            if let from = filterOptions.fromDate {
//                results = results.filter { entry in
//                    guard let entryDate = getTimestampDate(timestampStr: entry.timestamp) else {
//                        return false
//                    }
//                    return entryDate >= from
//                }
//            }
//            if let to = filterOptions.toDate {
//                results = results.filter { entry in
//                    guard let entryDate = getTimestampDate(timestampStr: entry.timestamp) else {
//                        return false
//                    }
//                    return entryDate >= to
//                }
//            }
//        }
//        
//        if !searchQuery.isEmpty {
//            results = results.filter { entry in
//                !findSubstrings(in: entry.text, query: searchQuery).isEmpty
//            }
//        }
//        
//        switch filterOptions.sortRule {
//        case .newest:
//            results.sort { $0.timestamp > $1.timestamp }
//        case .oldest:
//            results.sort { $0.timestamp < $1.timestamp }
//        }
//        
//        return results
//    }
}

extension HomeView {
    private func updateSelectedEntry(entry: EntryListItem) {
        do {
            appState.selectedEntry = entry
            appState.idLocations = entry.locations.map { IdentifiableLocationData(
                id: UUID(),
                latitude: $0.latitude,
                longitude: $0.longitude,
                displayName: $0.displayName
            ) }
            appState.idTags = entry.tags.map { IdentifiableTagData(
                id: UUID(),
                key: $0.key,
                value: $0.value
            ) }
            print("Entry updated...")
            path.append("viewEntry")
        }
    }
    
    private func openSettingsView() {
        do {
            path.append("settings")
        }
    }
    
    private func handleLogout() {
        do {
            AuthenticationManager.shared.logout()
            appState.isLoggedIn = false
            appState.username = ""
        }
    }
}

//#Preview {
//    let testAppState = AppState()
//    testAppState.isLoggedIn = true
//    testAppState.username = "test"
//    testAppState.selectedEntry = .mock
//    
//    return HomePreviewWrapper().environmentObject(testAppState)
//}
//
//struct HomePreviewWrapper: View {
//    @State private var path = NavigationPath()
//    
//    var body: some View {
//        HomeView(path: $path)
//    }
//}
