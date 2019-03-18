//
//  UITapGestrure+Extension.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 2/28/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import Foundation
import UIKit

extension UITapGestureRecognizer {
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        
        let locationOfTouchInLabel = self.location(in: label)
        let index = indexOfAttributedTextCharacterAtPoint(label: label, point: locationOfTouchInLabel)
        
        return NSLocationInRange(index, targetRange)
    }
    
    
    func indexOfAttributedTextCharacterAtPoint(label: UILabel, point: CGPoint) -> Int {
        guard let attributedString = label.attributedText else { return -1 }
        
        let mutableAttribString = NSMutableAttributedString(attributedString: attributedString)
        // Add font so the correct range is returned for multi-line labels
        mutableAttribString.addAttributes([NSAttributedString.Key.font: label.font], range: NSRange(location: 0, length: attributedString.length))
        
        let textStorage = NSTextStorage(attributedString: mutableAttribString)
        
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(size: label.frame.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.lineBreakMode = label.lineBreakMode
        layoutManager.addTextContainer(textContainer)
        
        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return index
    }
}
