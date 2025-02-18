//
//  AuthenticationManager.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 2/3/25.
//

import Foundation

class AuthenticationManager {
    static let shared = AuthenticationManager()
    
    private init() {}
    
    func handleCreateAccountResponse(_ response: CreateAccountResponse) throws {
        guard response.success else {
            throw NSError(domain: "Authentication", code: 401, userInfo: [NSLocalizedDescriptionKey: "Account creation failed"])
        }
        
        try storeJWT(response.token)
        
        try storeAPIKey(response.apiKey)
    }
    
    func handleLoginResponse(_ response: LoginResponse) throws {
        guard response.success else {
            throw NSError(domain: "Authentication", code: 401, userInfo: [NSLocalizedDescriptionKey: "Login failed"])
        }
        
        print("response.token: \(response.token)")
        print("response.apiKey: \(response.apiKey)")
        
        try storeJWT(response.token)
        try storeAPIKey(response.apiKey)
    }
    
    private func storeJWT(_ token: String) throws {
        guard let data = token.data(using: .utf8) else {
            throw KeychainError.invalidItemFormat
        }
        print("storeJWT data: \(data)")
        do {
            try KeychainManager.shared.delete(forKey: .jwt)
        } catch {
            print("storeJWT DELETE ERROR: \(error)")
        }
        do {
            try KeychainManager.shared.save(data, forKey: .jwt)
        } catch {
            print("storeJWT SAVE ERROR: \(error)")
        }
    }
    
    private func storeAPIKey(_ apiKey: String) throws {
        guard let data = apiKey.data(using: .utf8) else {
            print("storeAPIKey invalid format error")
            throw KeychainError.invalidItemFormat
        }
        print("storeAPIKey data: \(data)")
        do {
            try KeychainManager.shared.delete(forKey: .apiKey)
        } catch {
            print("storeAPIKey DELETE ERROR: \(error)")
        }
        do {
            try KeychainManager.shared.save(data, forKey: .apiKey)
        } catch {
            print("storeAPIKey SAVE ERROR: \(error)")
        }
    }
    
    func getStoredJWT() throws -> String? {
        let data = try KeychainManager.shared.retrieve(forKey: .jwt)
        let str = String(data: data, encoding: .utf8)
        print("getStoredJWT str: \(str ?? "nil")")
        return String(data: data, encoding: .utf8)
    }
    
    func getStoredAPIKey() throws -> String? {
        let data = try KeychainManager.shared.retrieve(forKey: .apiKey)
        let str = String(data: data, encoding: .utf8)
        print("Stored API Key: \(str ?? "nil")")
        
        return String(data: data, encoding: .utf8)
    }
    
    func logout() {
        KeychainManager.shared.clearAllAuthData()
    }
}
