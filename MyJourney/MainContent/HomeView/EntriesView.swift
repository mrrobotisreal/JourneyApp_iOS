////
////  EntriesView.swift
////  MyJourney
////
////  Created by Mitch Wintrow on 2/15/25.
////
//
//import SwiftUI
//
//struct EntriesView: View {
//    @State var entries: [EntryListItem]
//    @State var searchQuery: String
//    @StateObject private var viewModel = HomeViewModel()
//    @EnvironmentObject var appState: AppState
//    
//    var doSearch: () -> Void
//    var updateSelectedEntry: (EntryListItem) -> Void
//    
//    var body: some View {
//        List {
//            if viewModel.isLoading {
//                HStack {
//                    Spacer()
//                    ProgressView()
//                    Spacer()
//                }
//            } else {
//                ForEach(entries, id: \.id) { entry in
//                    EntryListItemView(entryListItem: entry, query: searchQuery)
//                        .onAppear {
//                            if entry == entries.last {
//                                viewModel.fetchEntries(username: appState.username ?? "")
//                                // TODO: implement pagination...
//                            }
//                        }
//                        .onTapGesture {
//                            updateSelectedEntry(entry: entry)
//    //                        selectedRoute = "viewEntry"
//                        }
//                }
//            }
//        }
//        .refreshable(action: {
//            print("Fetching entries again")
//            doSearch()
//        })
//        .listStyle(.plain)
//        .scrollContentBackground(.hidden)
//        .background(Color(red: 0.533, green: 0.875, blue: 0.949))
//        .clipShape(RoundedRectangle(cornerRadius: 0))
//        .overlay(
//            RoundedRectangle(cornerRadius: 0)
//                .stroke(Color(red: 0.008, green: 0.157, blue: 0.251), lineWidth: 2)
//        )
//        .onReceive(NotificationCenter.default.publisher(for: .newEntryCreated)) {_ in
//            print("Received notification, refreshing entries")
//            Task {
//                doSearch()
//            }
//        }
//    }
//}
//
////#Preview {
////    EntriesView()
////}
