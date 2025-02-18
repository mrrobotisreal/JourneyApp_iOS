//
//  CreateAccountView.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 1/18/25.
//

import SwiftUI
import Combine

struct CreateAccountView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var showSuccessMessage = false
    @State private var isLoading = false
    @StateObject private var viewModel = UsernameViewModel()
    @StateObject private var passwordViewModel = PasswordViewModel()
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            VStack {
                Text(viewModel.isLoginVisible ? "Login" : "Create Account")
                    .font(.custom("Nexa Script", size: 32))
                    .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                    .padding(.vertical, 2)
                
                TextField("Username", text: $viewModel.username)
                    .font(.custom("Nexa Script Light", size: 18))
                    .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                    .padding(.horizontal)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                if !viewModel.isLoginVisible {
                    if let isAvailable = viewModel.isUsernameAvailable {
                        Text(isAvailable ? "✅ Username is available" : "❌ Username is taken")
                            .foregroundColor(isAvailable ? .green : .red)
                            .font(.custom("Nexa Script Heavy", size: 12))
                    } else if let error = viewModel.errorMessage {
                        Text(error).foregroundColor(.red).font(.custom("Nexa Script Heavy", size: 12))
                    } else {
                        //                    Text("Type at least 1 char... debouncing in action!")
                        //                        .foregroundColor(.gray)
                        //                        .font(.custom("Nexa Script Light", size: 12))
                    }
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                
                SecureField("Password", text: $passwordViewModel.password)
                    .font(.custom("Nexa Script Light", size: 18))
                    .foregroundColor(Color(red: 0.008, green: 0.157, blue: 0.251))
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                HStack {
                    Button(viewModel.isLoginVisible ? "Need an account?" : "Already have an account?") {
                        viewModel.toggleIsLoginVisible()
                    }
                    .font(.custom("Nexa Script Light", size: 16))
                    .foregroundColor(Color(red: 0.008, green: 0.282, blue: 0.451))
                    
                    Spacer()
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(
                                CircularProgressViewStyle(tint: Color(red: 0.008, green: 0.282, blue: 0.451))
                            )
                            .tint(Color(red: 0.008, green: 0.282, blue: 0.451))
                            .padding()
                    } else {
                        if viewModel.isLoginVisible {
                            Button("Log In") {
                                Task {
                                    await handleSubmitLogin()
                                }
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
                        } else {
                            Button("Create") {
                                Task {
                                    await handleSubmitCreateAccount()
                                }
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
                        }
                    }
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
                Alert(title: Text(viewModel.isLoginVisible ? "Successful Login ✅" : "Account Created ✅"), message: Text(viewModel.isLoginVisible ? "Welcome back, \(viewModel.username)!" : "Welcome to My Journey, \(viewModel.username)!"), dismissButton: .default(Text("OK")))
            }
        }
        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 200 : 10)
    }
    
    private func handleSubmitCreateAccount() async {
        guard viewModel.isUsernameValid == true else {
            errorMessage = "Username invalid. Must be 2-32 chars, only letters, numbers, or ._-"
            return
        }
        guard passwordViewModel.isPasswordValid == true else {
            errorMessage = "Password invalid. Must contain at least 1 uppercase char, 1 lowercase char, 1 number, and 1 special char."
            return
        }
        
        errorMessage = ""
        
        do {
            isLoading = true
            let isAvailable = try await checkUsernameAvailability(viewModel.username)
            
            if !isAvailable {
                errorMessage = "Username already exists. Try another username."
                return
            }
        } catch {
            errorMessage = "Error checking username: \(error.localizedDescription)"
            return
        }
        
        do {
            let success = try await createAccount(username: viewModel.username, password: passwordViewModel.password)
            
            if success {
                showSuccessMessage = true
            } else {
                errorMessage = "Failed to create account. Try again later."
            }
            isLoading = false
        } catch {
            errorMessage = "Error creating account: \(error.localizedDescription)"
        }
    }
    
    private func handleSubmitLogin() async {
        guard viewModel.isUsernameValid == true else {
            errorMessage = "Username invalid. Must be 2-32 chars, only letters, numbers, or ._-"
            print("Username invalid. Must be 2-32 chars, only letters, numbers, or ._-")
            return
        }
        guard passwordViewModel.isPasswordValid == true else {
            errorMessage = "Password invalid. Must contain at least 1 uppercase char, 1 lowercase char, 1 number, and 1 special char."
            print("Password invalid. Must contain at least 1 uppercase char, 1 lowercase char, 1 number, and 1 special char.")
            return
        }
        
        errorMessage = ""
        
        do {
            isLoading = true
            let success = try await handleLogin(username: viewModel.username, password: passwordViewModel.password)
            
            if success {
                print("Success!!!!")
                print("Success: ", success)
                showSuccessMessage = true
            } else {
                errorMessage = "Failed to login. Check your username and password to ensure they're correctly entered."
            }
            isLoading = false
        } catch {
            errorMessage = "Error loggin in: \(error.localizedDescription)"
        }
    }
}

extension CreateAccountView {
    private func checkUsernameAvailability(_ username: String) async throws -> Bool {
        guard let url = URL(string: "https://api.journeyapp.me/api/validate/username") else  {
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
//        guard let url = URL(string: "https://journeyapp.me/api/users/create") else {
//            throw URLError(.badURL)
//        }
//        
//        let requestData = [
//            "username": username,
//            "password": password
//        ]
//        let jsonData = try JSONSerialization.data(withJSONObject: requestData)
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.httpBody = jsonData
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
//            throw URLError(.badServerResponse)
//        }
//        
//        let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any]
//        let success = jsonObject?["success"] as? Bool ?? false
        
        let response = try await NetworkService.shared.createAccount(username: username, password: password, sessionOption: "always") // TODO: handle sessionOption
        let success = response.success
        
        if success {
            appState.userId = response.userId
            appState.username = username
            appState.apiKey = response.apiKey
            appState.jwt = response.token
            appState.font = response.font
            appState.isLoggedIn = true
        }
        
        return success
    }
    
    private func handleLogin(username: String, password: String) async throws -> Bool {
        print("Attempting to login")
//        guard let url = URL(string: "https://journeyapp.me/api/users/login") else {
//            throw URLError(.badURL)
//        }
//        
//        let requestData = [
//            "username": username,
//            "password": password,
//        ]
//        let jsonData = try JSONSerialization.data(withJSONObject: requestData)
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.httpBody = jsonData
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
//            throw URLError(.badServerResponse)
//        }
//        
//        let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any]
//        let success = jsonObject?["success"] as? Bool ?? false
        let response = try await NetworkService.shared.login(username: username, password: password, sessionOption: "always") // TODO: handle sessionOption
        let success = response.success
        
        if success {
            print("Successfully logged in!")
            appState.userId = response.userId
            appState.username = username
            appState.font = response.font
            appState.apiKey = response.apiKey
            appState.jwt = response.token
            appState.isLoggedIn = true
        }
        
        return success
    }
}

@MainActor
class UsernameViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var isUsernameAvailable: Bool? = nil
    @Published var errorMessage: String? = nil
    @Published var isUsernameValid: Bool? = nil
    @Published var isLoginVisible: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $username
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] newUsername in guard let self = self, !newUsername.isEmpty else { return }
                Task {
//                    NetworkService.shared.tempInit()
                    self.isUsernameValid = self.checkIsUsernameValid(newUsername)
                    if !self.isLoginVisible {
                        await self.checkUsernameAvailability(newUsername)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func toggleIsLoginVisible() {
        self.isLoginVisible = !self.isLoginVisible
    }
    
    func checkUsernameAvailability(_ username: String) async {
        do {
            let availableFromServer = try await mockServerCheck(username)
            DispatchQueue.main.async {
                self.isUsernameAvailable = availableFromServer
                self.errorMessage = availableFromServer ? nil : "Username is taken... Please choose another."
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Server error: \(error.localizedDescription)"
                self.isUsernameAvailable = nil
            }
        }
    }
    
    private func checkIsUsernameValid(_ username: String) -> Bool {
        return true
//        // The code below is causing crashes because it can't do regex, need to fix
//        let regex = "^[A-Za-Z0-9._-]{2, 32}$"
//        
//        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: username)
    }
    
    private func mockServerCheck(_ username: String) async throws -> Bool {
        guard let url = URL(string: "https://api.journeyapp.me/api/validate/username") else  {
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
}

@MainActor
class PasswordViewModel: ObservableObject {
    @Published var password: String = ""
    @Published var isPasswordValid: Bool? = nil
    @Published var errorMessage: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $password.debounce(for: .seconds(1.5), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] newPassword in guard let self = self, !newPassword.isEmpty else { return }
                Task {
                    self.isPasswordValid = self.checkIsPasswordValid(newPassword)
                }
            }
            .store(in: &cancellables)
    }
    
    private func checkIsPasswordValid(_ password: String) -> Bool {
        return true
//        // The code below is causing crashes because it can't do regex, need to fix
//        let regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z-0-9]).{8,16}$"
//        
//        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
    }
}

#Preview {
    CreateAccountView()
        .environmentObject(AppState())
}
