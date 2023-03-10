//
//  UIColorExtension.swift
//  dropper
//
//  Created by Andrew Tokeley on 24/02/23.
//

import Foundation
import UIKit

extension UIColor {
    

    convenience init(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) {
        self.init(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }

    // MARK: - App colours

    static var gameSkyBlue: UIColor {
        return UIColor(2, 204, 254, 100)
    }
    
    static var gameLightSkyBlue: UIColor {
        return UIColor(78, 219, 254, 100)
    }
}
