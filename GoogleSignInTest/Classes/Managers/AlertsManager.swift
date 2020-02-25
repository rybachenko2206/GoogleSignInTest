//
//  AlertsManager.swift
//  GoogleSignInTest
//
//  Created by Roman Rybachenko on 23.02.2020.
//  Copyright © 2020 Roman Rybachenko. All rights reserved.
//

import Foundation
import UIKit


class AlertsManager {
    
    class func showServerErrorAlert(with error: Error, to viewController: UIViewController?, completion: Completion? = nil) {
        AlertsManager
            .simpleAlert(title: "Error!",
                         message: error.localizedDescription,
                         controller: viewController,
                         completion: completion)
    }
    
    class func showAlertAddNewPlace(to viewController: UIViewController?, okCompletion: @escaping ((String) -> Void)) {
        let ac = UIAlertController(title: "Save this place?", message: "Input place name..", preferredStyle: .alert)
        ac.addTextField()
        
        let canceAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(canceAction)
        
        let okAction = UIAlertAction(title: "Add", style: .default, handler: { _ in
            let text = ac.textFields?.first?.text ?? ""
            okCompletion(text)
        })
        ac.addAction(okAction)
        
        viewController?.present(ac, animated: true, completion: nil)
    }
    
    class func simpleAlert(title: String,
                           message: String,
                           controller: UIViewController?,
                           completion: Completion? = nil) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let oklAction = UIAlertAction(title: NSLocalizedString("ОК", comment: ""),
                                      style: .default,
                                      handler: { action in
                                        completion?()
        })
        
        alertController.addAction(oklAction)
        controller?.present(alertController, animated: true, completion: completion)
    }
    
}
