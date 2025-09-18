//
//  RegisterViewController.swift
//  Skill-Tree
//
//  Created by Jagannath on 18/9/2025.
//

import UIKit
import Foundation
import FirebaseAuth
import FirebaseFirestore

struct UserProfile: Codable {
    let uid: String
    let displayName: String
    let email: String
    var profileImageURL: String = ""
    var creationDate: Timestamp = Timestamp(date: Date())
    
    // Gamification
    var level: Int = 1
    var currentXP: Int = 0
    var xpToNextLevel: Int = 100
    var healthScore: Int = 0
    var masteryPaths: [String: Int] = [
        "bodybuilding": 0,
        "powerlifting": 0,
        "calisthenics": 0,
        "cardio": 0
    ]
    var achievements: [String] = []
    
    // Social
    var following: [String] = []
    var followers: [String] = []
    
    // Settings
    var isPrivateProfile: Bool = false
    var displayMode: String = "system"
    var notifications: Bool = true
}

class RegisterViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBAction func registerTapped(_ sender: UIButton) {
        guard let firstName = firstNameTextField.text, !firstName.isEmpty,
              let lastName = lastNameTextField.text, !lastName.isEmpty,
              let displayName = displayNameTextField.text, !displayName.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("Please fill in all fields")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
                return
            }

            guard let user = authResult?.user else { return }
            
            let newUserProfile = UserProfile(
                uid: user.uid,
                displayName: displayName,
                email: email
            )
            
            let db = Firestore.firestore()
        
            do {
                try db.collection("users").document(user.uid).setData(from: newUserProfile) { error in
                    if let error = error {
                        print("Error saving user profile to Firestore: \(error.localizedDescription)")
                    } else {
                        print("User registered and comprehensive profile created! 🎉")
                        self.navigateToMainApp()
                    }
                }
            } catch let error {
                print("Error encoding user profile: \(error)")
            }
            
            self.navigateToMainApp()
        }
    }
    
    private func navigateToMainApp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBar = storyboard.instantiateViewController(identifier: "MainTabBar")

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = tabBar
            window.makeKeyAndVisible()
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
