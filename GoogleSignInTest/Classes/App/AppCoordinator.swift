//
//  AppCoordinator.swift
//  GoogleSignInTest
//
//  Created by Roman Rybachenko on 21.02.2020.
//  Copyright © 2020 Roman Rybachenko. All rights reserved.
//

import Foundation
import UIKit

class AppCoordinator {
    
    // MARK: - Properties
    private let navigationController = UINavigationController()
    
    
    var rootViewController: UIViewController {
        return navigationController
    }
    
    
    // MARK: - Public funcs
    
    func start() {
        if AuthorizationManager.shared.isAuthorized {
            showTabbar()
        } else {
            showLogin()
        }
    }
    
    // MARK: - Private funcs
    
    private func showTabbar() {
        let tabbarVc = TabbarVC.instantiate()
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.viewControllers = [tabbarVc]
    }
    
    private func showLogin() {
        let loginVc = LoginViewController.instantiate()
        
        loginVc.userDidSignIn = { [weak self] in
            self?.showTabbar()
        }
        
        navigationController.setNavigationBarHidden(false, animated: false)
        navigationController.viewControllers = [loginVc]
    }
}
