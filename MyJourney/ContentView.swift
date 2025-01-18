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
    @State private var userName: String = ""
    @State private var isNameEntered = false
    @State private var shouldNavigate = false

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
            
            if !shouldNavigate {
                 SplashView()
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            } else {
                CreateAccountView()
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
//                JournalView(userName: userName)
//                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
        .animation(.easeInOut, value: shouldNavigate)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                shouldNavigate = true
            }
        }
//        NavigationSplitView {
//            List {
//                ForEach(items) { item in
//                    NavigationLink {
//                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
//                    } label: {
//                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
//                    }
//                }
//                .onDelete(perform: deleteItems)
//            }
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
//                ToolbarItem {
//                    Button(action: addItem) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
//            }
//        } detail: {
//            Text("Select an item")
//        }
    }

//    private func addItem() {
//        withAnimation {
//            let newItem = Item(timestamp: Date())
//            modelContext.insert(newItem)
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            for index in offsets {
//                modelContext.delete(items[index])
//            }
//        }
//    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
