//
//  ProfileViewController.swift
//  GoogleSignInTest
//
//  Created by Roman Rybachenko on 21.02.2020.
//  Copyright © 2020 Roman Rybachenko. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var emailLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailLabel.text = AuthorizationManager.shared.user?.email
    }
    
    
    @IBAction func signOut(_ sender: UIButton) {
        guard let mySceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate,
            let navController = mySceneDelegate.window?.rootViewController as? UINavigationController,
            let tabbarVc = navController.viewControllers.first as? TabbarVC
            else { return }
        
        tabbarVc.userDidSignOut?()
    }
    

}
