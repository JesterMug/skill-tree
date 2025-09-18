//
//  LoginViewController.swift
//  Skill-Tree
//
//  Created by Jagannath on 18/9/2025.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        // Listen for auth state changes
        databaseController?.addAuthStateListener { [weak self] signedIn in
            if signedIn {
                self?.navigateToMainApp()
            }
        }
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        guard let email = emailField.text, let password = passwordField.text else { return }
        databaseController?.login(email: email, password: password) { result in
            if case let .failure(error) = result {
                self.showError("Login failed: \(error)")
            }
        }
    }
    
    @IBAction func signupTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "goToRegister", sender: nil)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
}
