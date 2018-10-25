//
//  ActivityIndicatorView.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 8/16/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import UIKit

class ActivityIndicatorView: UIView {

    var textLabel: UILabel!
    var activityView: UIActivityIndicatorView!
    weak var parentView: UIView!
    var activityCounter = 0
    
    convenience init(text: String, inView view: UIView) {
        self.init(frame: CGRect(x: 0, y: 0, width: 200, height: 75))

        parentView = view
        center = view.center
        autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleRightMargin]
        backgroundColor = .black
        alpha = 0.75
        layer.cornerRadius = 8
        
        let yPosition = frame.height/2 - 20
        activityView = UIActivityIndicatorView(style: .whiteLarge)
        activityView.frame = CGRect(x: 10, y: yPosition, width: 40, height: 40)
//        activityView.color = Settings.ActivityColor
        
        
        textLabel = UILabel(frame: CGRect(x: 50, y: yPosition, width: 100, height: 40))
        textLabel.textColor = .white
        textLabel.font = UIFont.systemFont(ofSize: 20)
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.minimumScaleFactor = 0.25
        textLabel.textAlignment = NSTextAlignment.center
        textLabel.text = text
        
        addSubview(activityView)
        addSubview(textLabel)
        
    }
    
    func startAnimating(disableUI: Bool = false) {
        activityCounter += 1
        // If indictaor is already running, just increase the counter
        guard activityCounter == 1 else { return }
        
        activityView.startAnimating()
        parentView.addSubview(self)
        
        if disableUI {
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
    }
    
    func stopAnimating() {
        activityCounter -= 1
        
        guard activityCounter < 1 else { return }
        
        activityView.stopAnimating()
        self.removeFromSuperview()
        
        if UIApplication.shared.isIgnoringInteractionEvents {
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
}
