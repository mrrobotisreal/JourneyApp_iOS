//
//  SplashView.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 1/18/25.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to...")
                .font(.custom("Nexa Script Light", size: 18))
                .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
            
            Text("My Journey!")
                .font(.custom("Nexa Script", size: 32))
                .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                .padding(.vertical, 2)
            
            Text("Your personal journal for letting your creativity flow, tracking your daily progress toward goals, or even just writing about the highlights of your day...")
                .font(.custom("Nexa Script Light", size: 12))
                .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
            
//                    TextField("Enter your name here", text: $userName)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .font(.custom("LobsterTwo", size: 18))
//                        .padding(.horizontal, 40)
//
//                    Button("Continue") {
//                        UserDefaults.standard.set(userName, forKey: "UserName")
//                        isNameEntered = true
//                    }
//                    .padding()
//                    .font(.custom("LobsterTwo", size: 24))
//                    .disabled(userName.isEmpty)
            
        }
        .frame(maxWidth: 340)
        .padding()
        .cornerRadius(12)
        .background(Color(red: 0.533, green: 0.875, blue: 0.949))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.008, green: 0.282, blue: 0.451), lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
//        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                shouldNavigate = false
//            }
//        }
    }
}

#Preview {
    SplashView()
}
