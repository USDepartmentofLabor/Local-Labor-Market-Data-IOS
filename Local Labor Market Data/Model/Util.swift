//
//  Util.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 8/30/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation
import UIKit

struct Util {
    static var isVoiceOverRunning: Bool {
        get {
            return UIAccessibilityIsVoiceOverRunning()
        }
    }
}
