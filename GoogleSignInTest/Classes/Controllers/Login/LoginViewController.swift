//
//  LoginViewController.swift
//  GoogleSignInTest
//
//  Created by Roman Rybachenko on 21.02.2020.
//  Copyright © 2020 Roman Rybachenko. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, Storyboardable {
    
    // MARK: - Properties
    static var storyboardName: Storyboard {
        return .login
    }
    
    let viewModel = LoginViewModel()

    
    // MARK: - Overriden funcs
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = viewModel.title
    }
    

}
