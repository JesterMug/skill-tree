//
//  DatabaseProtocol.swift
//  Skill-Tree
//
//  Created by Jagannath on 18/9/2025.
//

import Foundation

enum AuthError: Error {
    case invalidCredentials(String)
    case unknown(String)
}

protocol DatabaseProtocol: AnyObject {
    func login(email: String, password: String, completion: @escaping (Result<Void, AuthError>) -> Void)
    func signup(email: String, password: String, completion: @escaping (Result<Void, AuthError>) -> Void)
    func logout(completion: @escaping (Result<Void, AuthError>) -> Void)
    func addAuthStateListener(_ listener: @escaping (Bool) -> Void)
}
