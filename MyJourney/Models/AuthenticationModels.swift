//
//  AuthenticationModels.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 2/3/25.
//

import Foundation

struct CreateAccountResponse: Codable {
    let success: Bool
    let token: String?
    let apiKey: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case token
        case apiKey = "apiKey"
    }
}

struct LoginResponse: Codable {
    let success: Bool
    let token: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case token
    }
}
