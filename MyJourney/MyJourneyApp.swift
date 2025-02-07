//
//  MyJourneyApp.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 1/16/25.
//

import SwiftUI
import SwiftData

@main
struct MyJourneyApp: App {
    @StateObject private var appState = AppState()
    
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
//        .modelContainer(sharedModelContainer)
    }
}

class AppState: ObservableObject {
    @Published var username: String? = nil
    @Published var isLoggedIn: Bool = false
    @Published var didFinishSplash: Bool = false
    @Published var selectedEntryId: String = ""
    @Published var selectedEntry: EntryListItem = .mock
    @Published var idLocations: [IdentifiableLocationData] = []
    @Published var idTags: [IdentifiableTagData] = []
}
