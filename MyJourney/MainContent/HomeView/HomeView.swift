//
//  HomeView.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 1/18/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Binding var path: NavigationPath
    @State private var hasEntries = false
    @State private var showActionSheet = false
    @State private var searchQuery: String = ""
    
    var body: some View {
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
                        // action here...
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                            .padding(6)
                            .background(Color(red: 0.039, green: 0.549, blue: 0.749))
                            .cornerRadius(8)
                    }
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .background(Color(red: 0.039, green: 0.549, blue: 0.749))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.008, green: 0.157, blue: 0.251), lineWidth: 2)
                    )
                }
                .padding()
                
                Spacer()
                
                if !hasEntries {
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
                } else {
                    Text("Entries here...")
                        .font(.custom("Nexa Script Light", size: 18))
                        .padding()
                }
                
                Spacer()
                
                Button(action: {
                    showActionSheet = true
                }) {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.title2)
                        .padding(10)
                        .background(Color(red: 0.039, green: 0.549, blue: 0.749))
                        .cornerRadius(8)
                }
                .foregroundColor(.white)
                .cornerRadius(12)
                .background(Color(red: 0.039, green: 0.549, blue: 0.749))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.008, green: 0.157, blue: 0.251), lineWidth: 2)
                )
            }
            
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
//                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)))
//                    .animation(.easeInOut, value: showActionSheet)
                    .offset(y: UIScreen.main.bounds.height - 600)
            }
//            .gesture(
//                DragGesture(minimumDistance: 30, coordinateSpace: .local)
//                    .onEnded { value in
//                        if value.translation.height < 0 {
//                            showActionSheet = true
//                        }
//                    }
//            )
//            .confirmationDialog("Menu", isPresented: $showActionSheet, actions: {
//                Button("Create A New Entry") {
//                }
//                Button("Search Entries (Advanced)") {
//                    print("Search entries (advanced) tapped from menu!")
//                }
//                Button("Settings") {
//                    print("Settings tapped from menu!")
//                }
//                Button("Log Out") {
//                    print("Logging out, dude!")
//                }
//                Button("Cancel", role: .cancel) {}
//            })
        }
    }
}

#Preview {
    HomePreviewWrapper()
}

struct HomePreviewWrapper: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        HomeView(path: $path)
    }
}
