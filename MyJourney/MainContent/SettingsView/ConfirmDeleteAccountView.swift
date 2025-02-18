//
//  ConfirmDeleteAccountView.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 2/8/25.
//

import SwiftUI

struct ConfirmDeleteAccountView: View {
    @Binding var isConfirmDeleteAccountViewVisible: Bool
    
    var onDeleteAccount: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isConfirmDeleteAccountViewVisible = false
                }
            
            VStack {
                VStack(spacing: 20) {
                    Text("Confirm Account Deletion")
                        .font(.custom("Nexa Script Heavy", size: 24))
                        .foregroundColor(Color(red: 0.008, green: 0.282, blue: 0.451))
                    
                    Text("By tapping \"Confirm\" below, you are confirming that you understand all journal entries you've ever created, including attached images, locations, and tags, will be permanently deleted along with your account and that you understand this action cannout be undone.")
                        .font(.custom("Nexa Script Light", size: 18))
                        .foregroundColor(Color(red: 0.008, green: 0.282, blue: 0.451))
                    
                    Text("Do you wish to proceed?")
                        .font(.custom("Nexa Script Heavy", size: 18))
                        .foregroundColor(Color(red: 0.008, green: 0.282, blue: 0.451))
                    
                    Text("If yes, tap \"Confirm\", otherwise tap \"Cancel\"")
                        .font(.custom("Nexa Script Light", size: 18))
                        .foregroundColor(Color(red: 0.008, green: 0.282, blue: 0.451))

                    HStack {
                        Button("Cancel") {
                            isConfirmDeleteAccountViewVisible = false
                        }
                        .font(.custom("Nexa Script Light", size: 18))
                        .foregroundColor(Color(red: 0.008, green: 0.282, blue: 0.451))

                        Spacer()

                        Button(action: {
                            onDeleteAccount()
                        }) {
                            Text("Confirm")
                                .font(.custom("Nexa Script Heavy", size: 18))
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

//#Preview {
//    ConfirmDeleteAccountView()
//}
