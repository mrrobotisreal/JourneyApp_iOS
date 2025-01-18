//
//  CreateAccountView.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 1/18/25.
//

import SwiftUI

struct CreateAccountView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var showSuccessMessage = false
    
    var body: some View {
        VStack {
            Text("Create Account")
                .font(.custom("Nexa Script", size: 32))
                .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                .padding(.vertical, 2)
                        
            TextField("Username", text: $username)
                .font(.custom("Nexa Script Light", size: 18))
                .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Password", text: $password)
                .font(.custom("Nexa Script Light", size: 18))
                .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("Your username and password will be your means of logging in after you’ve created your account. This will allow you to access your journal entries across devices.")
                .font(.custom("Nexa Script Light", size: 16))
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            HStack {
                Spacer()
                
                Button("Submit") {
                    // next action here...
                }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .font(.custom("Nexa Script Heavy", size: 18))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .background(Color(red: 0.039, green: 0.549, blue: 0.749))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.008, green: 0.157, blue: 0.251), lineWidth: 2)
                    )
                
//                Button(action: {
//                    // next action here...
//                }) {
//                    Image(systemName: "arrow.right.circle")
//                        .font(.title)
//                        .foregroundColor(.blue)
//                }
            }
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
        .alert(isPresented: $showSuccessMessage) {
            Alert(title: Text("Account Created"), message: Text("Welcome, \(username)!"), dismissButton: .default(Text("OK")))
        }
    }
    
    private func isUsernameValid(_ username: String) -> Bool {
        let regex = "^[A-Za-Z0-9._-]{2, 32}$"
        
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: username)
    }
    
    private func isPasswordValid(_ password: String) -> Bool {
        let regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z-0-9]).{8,16}$"
        
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
    }
    
    private func handleSubmit() async {
        guard isUsernameValid(username) else {
            errorMessage = "Username invalid. Must be 2-32 chars, only letters, numbers, or ._-"
            return
        }
        guard isPasswordValid(password) else {
            errorMessage = "Password invalid. Must contain at least 1 uppercase char, 1 lowercase char, 1 number, and 1 special char."
            return
        }
        
        errorMessage = ""
        
        do {
            let isAvailable = try await checkUsernameAvailability(username)
            
            if !isAvailable {
                errorMessage = "Username already exists. Try another username."
                return
            }
        } catch {
            errorMessage = "Error checking username: \(error.localizedDescription)"
            return
        }
        
        do {
            let success = try await createAccount(username: username, password: password)
            
            if success {
                showSuccessMessage = true
            } else {
                errorMessage = "Failed to create account. Try again later."
            }
        } catch {
            errorMessage = "Error creating account: \(error.localizedDescription)"
        }
    }
}

extension CreateAccountView {
    private func checkUsernameAvailability(_ username: String) async throws -> Bool {
        guard let url = URL(string: "https://journeyapp.me/api/validate/username") else  {
            throw URLError(.badURL)
        }
        
        let requestData = ["username": username]
        let jsonData = try JSONSerialization.data(withJSONObject: requestData)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let isAvailable = jsonObject?["usernameAvailable"] as? Bool ?? false
        
        return isAvailable
    }
    
    private func createAccount(username: String, password: String) async throws -> Bool {
        guard let url = URL(string: "https://journeyapp.me/api/users/create") else {
            throw URLError(.badURL)
        }
        
        let requestData = [
            "username": username,
            "password": password
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: requestData)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let success = jsonObject?["success"] as? Bool ?? false
        
        return success
    }
}

#Preview {
    CreateAccountView()
}
