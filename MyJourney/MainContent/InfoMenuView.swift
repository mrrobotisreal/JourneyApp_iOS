//
//  InfoMenuView.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 2/5/25.
//

import SwiftUI

struct InfoMenuView: View {
    @Binding var isInfoMenuViewVisible: Bool
    
    var body: some View {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Tapping outside closes the modal
                        isInfoMenuViewVisible = false
                    }
                    
                VStack {
                    VStack(spacing: 20) {
                        Text("Info Menu")
                            .font(.custom("Nexa Script Heavy", size: 32))
                            .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text("• Bold:")
                                    .font(.custom("Nexa Script Heavy", size: 16))
                                
                                Text("Wrap with *")
                                    .font(.custom("Nexa Script Light", size: 16))
                            }
                            HStack {
                                Text("• Italic:")
                                    .font(.custom("Nexa Script Heavy", size: 16))
                                
                                Text("Wrap with _")
                                    .font(.custom("Nexa Script Light", size: 16))
                            }
                            HStack {
                                Text("• Underline:")
                                    .font(.custom("Nexa Script Heavy", size: 16))
                                
                                Text("Wrap with ~")
                                    .font(.custom("Nexa Script Light", size: 16))
                            }
                            HStack {
                                Text("• Strikethrough:")
                                    .font(.custom("Nexa Script Heavy", size: 16))
                                
                                Text("Wrap with -")
                                    .font(.custom("Nexa Script Light", size: 16))
                            }
                            HStack {
                                Text("• Inline Code:")
                                    .font(.custom("Nexa Script Heavy", size: 16))
                                
                                Text("Wrap with `")
                                    .font(.custom("Nexa Script Light", size: 16))
                            }
                            HStack {
                                Text("• Colored text:")
                                    .font(.custom("Nexa Script Heavy", size: 16))
                                
                                Text("Wrap with {color: purple}Your text{color}")
                                    .font(.custom("Nexa Script Light", size: 16))
                            }
                            HStack {
                                Text("• Title:")
                                    .font(.custom("Nexa Script Heavy", size: 16))
                                
                                Text("Start line with #")
                                    .font(.custom("Nexa Script Light", size: 16))
                            }
                            HStack {
                                Text("• Subtitle:")
                                    .font(.custom("Nexa Script Heavy", size: 16))
                                
                                Text("Start line with ##")
                                    .font(.custom("Nexa Script Light", size: 16))
                            }
                            HStack {
                                Text("• Bulleted list item:")
                                    .font(.custom("Nexa Script Heavy", size: 16))
                                
                                Text("Start line with -")
                                    .font(.custom("Nexa Script Light", size: 16))
                            }
                        }
                        .frame(maxWidth: .infinity)
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
                            isInfoMenuViewVisible = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                            Spacer()
                            Text("Close")
                                .font(.custom("Nexa Script Heavy", size: 18))
                                .foregroundColor(.white)
                            Spacer()
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
    }
}

#Preview {
    InfoMenuViewPreviewWrapper()
}

struct InfoMenuViewPreviewWrapper: View {
    @State private var isInfoMenuViewVisible: Bool = true
    
    var body: some View {
        InfoMenuView(isInfoMenuViewVisible: $isInfoMenuViewVisible)
    }
}
