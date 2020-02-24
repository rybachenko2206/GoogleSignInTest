//
//  TabbarVC.swift
//  GoogleSignInTest
//
//  Created by Roman Rybachenko on 21.02.2020.
//  Copyright © 2020 Roman Rybachenko. All rights reserved.
//

import UIKit

class TabbarVC: UITabBarController, Storyboardable {
    
    static var storyboardName: Storyboard {
        return .tabbar
    }
    
    var userDidSignOut: (() -> Void)?
    

}
