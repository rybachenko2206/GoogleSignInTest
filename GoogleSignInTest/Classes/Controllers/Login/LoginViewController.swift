//
//  LoginViewController.swift
//  GoogleSignInTest
//
//  Created by Roman Rybachenko on 21.02.2020.
//  Copyright © 2020 Roman Rybachenko. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase


class LoginViewController: UIViewController, Storyboardable {
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    // MARK: - Properties
    static var storyboardName: Storyboard {
        return .login
    }
    
    var userDidSignIn: (() -> Void)?

    
    // MARK: - Overriden funcs
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Test App"
        
        GIDSignIn.sharedInstance().presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
    }
    
}


// MARK: - GIDSignInDelegate
extension LoginViewController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            pl("sign in error: \(error)\n")
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
            if let faError = error {
                pl("firebase auth error: \(faError)")
                return
            }
            // User is signed in
            guard let user = authResult?.user else { return }
            AuthorizationManager.shared.user = user
            self?.userDidSignIn?()
        }
    }
    
}



