//
//  UIViewController+Extension.swift
//  Labor Local Data
//
//  Created by Nidhi Chawla on 7/24/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    class func instantiateFromStoryboard(_ name: String = "Main") -> Self {
        return instantiateFromStoryboardHelper(name)
    }
    
    fileprivate class func instantiateFromStoryboardHelper<T>(_ name: String) -> T {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let identifier = String(describing: self)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier) as! T
        return controller
    }
}


// MARK: Error Handling
extension UIViewController {
    func handleError(error: Error, title: String? = nil) {
        if let reportError = error as? ReportError {
            
            let titleStr = title ?? reportError.title
            let alertController = UIAlertController(title: titleStr, message: reportError.description, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default))
            present(alertController, animated: false)
        }
    }
}



