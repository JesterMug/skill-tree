//
//  FirebaseController.swift
//  Skill-Tree
//
//  Created by Jagannath on 18/9/2025.
//

import UIKit
import Foundation
import FirebaseAuth
import FirebaseCore

class FirebaseController: NSObject, DatabaseProtocol {
    private var authController: Auth
    private var authStateListeners: [(Bool) -> Void] = []
    
    override init() {
        FirebaseApp.configure()
        self.authController = Auth.auth()
        super.init()
        
        authController.addStateDidChangeListener { [weak self] _, user in
            let isSignedIn = (user != nil)
            self?.authStateListeners.forEach { $0(isSignedIn) }
        }
    }
    
    // MARK: - Protocol methods
    
    func login(email: String, password: String, completion: @escaping (Result<Void, AuthError>) -> Void) {
        authController.signIn(withEmail: email, password: password) { _, error in
            if let err = error {
                completion(.failure(.invalidCredentials(err.localizedDescription)))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func signup(email: String, password: String, completion: @escaping (Result<Void, AuthError>) -> Void) {
        authController.createUser(withEmail: email, password: password) { _, error in
            if let err = error {
                completion(.failure(.invalidCredentials(err.localizedDescription)))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func logout(completion: @escaping (Result<Void, AuthError>) -> Void) {
        do {
            try authController.signOut()
            completion(.success(()))
        } catch {
            completion(.failure(.unknown(error.localizedDescription)))
        }
    }
    
    func addAuthStateListener(_ listener: @escaping (Bool) -> Void) {
        authStateListeners.append(listener)
        listener(authController.currentUser != nil)
    }

}
