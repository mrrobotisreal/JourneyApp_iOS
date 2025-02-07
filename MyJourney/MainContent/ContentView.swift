//
//  ContentView.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 1/16/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
//    @Environment(\.modelContext) private var modelContext
//    @Query private var items: [Item]
    @EnvironmentObject var appState: AppState
    @State private var shouldNavigate = false
    
    @State private var path = NavigationPath()

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.008, green: 0.157, blue: 0.251), // #022840
                    Color(red: 0.008, green: 0.282, blue: 0.451), // #024873
                    Color(red: 0.039, green: 0.549, blue: 0.749), // #0A8CBF
                    Color(red: 0.533, green: 0.875, blue: 0.949), // #88DFF2
                    Color(red: 0.039, green: 0.549, blue: 0.749), // #0A8CBF
                    Color(red: 0.008, green: 0.282, blue: 0.451), // #024873
                    Color(red: 0.008, green: 0.157, blue: 0.251) // #022840
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            if !appState.didFinishSplash {
                 SplashView()
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            } else if !appState.isLoggedIn {
                CreateAccountView()
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            } else {
                NavigationStack(path: $path) {
                    HomeView(path: $path)
                        .navigationDestination(for: String.self) { route in
                            switch route {
                            case "createNewEntry":
                                NewEntryView()
                            case "viewEntry":
                                ViewEntryView()
                                //                                HomeView(path: $path)
                            case "settings":
                                //                                SettingsView()
                                HomeView(path: $path)
                            default:
                                HomeView(path: $path)
                            }
                        }
                }
            }
        }
        .animation(.easeInOut, value: shouldNavigate)
        .onAppear {
//            NetworkService.shared.tempInit()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                appState.didFinishSplash = true
            }
        }
    }
}

#Preview("Logged out") {
    ContentView()
        .environmentObject(AppState())
}

#Preview("Logged in") {
    let testAppState = AppState()
    testAppState.isLoggedIn = true
    testAppState.username = "test"
    return ContentView().environmentObject(testAppState)
}
