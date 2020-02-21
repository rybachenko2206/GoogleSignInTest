//
//  AuthorizationManager.swift
//  GoogleSignInTest
//
//  Created by Roman Rybachenko on 21.02.2020.
//  Copyright © 2020 Roman Rybachenko. All rights reserved.
//

import Foundation
import KeychainSwift
import Firebase


class AuthorizationManager {
    
    static let shared = AuthorizationManager()
    
    private let keychainManager = KeychainSwift()
    
    private init() {
        self.user = Auth.auth().currentUser
    }
    
    
    var user: User?
    
    var isAuthorized: Bool {
        return user != nil
    }
    
    
    func logout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            pl("Error signing out: \(signOutError)")
        }
    }
    
}

