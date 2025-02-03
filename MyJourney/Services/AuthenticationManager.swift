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
        
        if let token = response.token {
            try storeJWT(token)
        }
        
        if let apiKey = response.apiKey {
            try storeAPIKey(apiKey)
        }
    }
    
    func handleLoginResponse(_ response: LoginResponse) throws {
        guard response.success else {
            throw NSError(domain: "Authentication", code: 401, userInfo: [NSLocalizedDescriptionKey: "Login failed"])
        }
        
        if let token = response.token {
            try storeJWT(token)
        }
    }
    
    private func storeJWT(_ token: String) throws {
        guard let data = token.data(using: .utf8) else {
            throw KeychainError.invalidItemFormat
        }
        try KeychainManager.shared.save(data, forKey: .jwt)
    }
    
    private func storeAPIKey(_ apiKey: String) throws {
        guard let data = apiKey.data(using: .utf8) else {
            throw KeychainError.invalidItemFormat
        }
        try KeychainManager.shared.save(data, forKey: .apiKey)
    }
    
    func getStoredJWT() throws -> String? {
        let data = try KeychainManager.shared.retrieve(forKey: .jwt)
        return String(data: data, encoding: .utf8)
    }
    
    func getStoredAPIKey() throws -> String? {
        let data = try KeychainManager.shared.retrieve(forKey: .apiKey)
        return String(data: data, encoding: .utf8)
    }
    
    func logout() {
        KeychainManager.shared.clearAllAuthData()
    }
}
