//
//  AuthorizationManager.swift
//  GoogleSignInTest
//
//  Created by Roman Rybachenko on 21.02.2020.
//  Copyright © 2020 Roman Rybachenko. All rights reserved.
//

import Foundation
import KeychainSwift


class AuthorizationManager {
    
    static let shared = AuthorizationManager()
    
    private let keychainManager = KeychainSwift()
    
    private init() {}
    
    
    var isAuthorized: Bool {
        get {
            return keychainManager.getBool(Constants.kIsAuthorized) ?? false
        } set {
            keychainManager.set(newValue, forKey: Constants.kIsAuthorized)
        }
    }
    
}


extension AuthorizationManager {
    struct Constants {
        static let kIsAuthorized = "isAuthorizedKey"
    }
}
