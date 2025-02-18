//
//  SettingsView.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 2/8/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var isConfirmDeleteAccountViewVisible: Bool = false
    @State private var isDeletedSuccessfully: Bool = false
    @State private var isDeleting: Bool = false
    
    var body: some View {
        ZStack {
            Color(red: 0.533, green: 0.875, blue: 0.949)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrowshape.turn.up.backward.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    Spacer()
                    
                    Text("Settings")
                        .font(.custom("Nexa Script Heavy", size: 24))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("")
                }
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.008, green: 0.282, blue: 0.451))
                
                VStack {
                    VStack {
                        Button(action: {
                            isConfirmDeleteAccountViewVisible = true
                        }) {
                            Image(systemName: "trash.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .background(Color.red.opacity(0.8))
                                .clipShape(Circle())
                            
                            Text("Delete Account")
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
                    }
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                    .padding()
                    .cornerRadius(12)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.008, green: 0.282, blue: 0.451), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                }
                .padding(.horizontal, 10)
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("Deleted account and all journal entries successfully!", isPresented: $isDeletedSuccessfully) {
            Button("OK", role: .cancel) {
                isDeletedSuccessfully = false
                dismiss()
                AuthenticationManager.shared.logout()
                appState.isLoggedIn = false
                appState.username = ""
            }
        }
        .overlay(
            Group {
                if isConfirmDeleteAccountViewVisible {
                    ConfirmDeleteAccountView(
                        isConfirmDeleteAccountViewVisible: $isConfirmDeleteAccountViewVisible,
                        onDeleteAccount: {
                            handleDeleteAccount()
                        }
                    )
                }
            }
        )
    }
    
    private func handleDeleteAccount() {
        guard let username = appState.username else { return }
        isDeleting = true
        
        Task {
            do {
                let result = try await NetworkService.shared.deleteAccount(apiKey: appState.apiKey ?? "", jwt: appState.jwt ?? "", username: username)
                
                isDeletedSuccessfully = result.success
            } catch {
                print("Error deleting account: \(error)")
                isDeletedSuccessfully = false
            }
            isDeleting = false
        }
    }
}

#Preview {
    SettingsView()
}
