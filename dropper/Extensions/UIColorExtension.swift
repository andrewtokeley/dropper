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

    convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
    
    // MARK: - App colours

    static var gameBackground: UIColor {
        return UIColor(hex: "#0B5394FF")!
    }
    
    static var gameLightGray: UIColor {
        return UIColor(hex: "#F3F3F3FF")!
    }
    
    static var gameHighlight: UIColor {
        return UIColor.gameBlock2
    }
    
    static var gameBlock1: UIColor {
        //return UIColor(82, 140, 81, 100)
        //return UIColor(hex: "#0339A6FF")!
        return UIColor(hex: "#17DEEEFF")!
        
    }
    
    static var gameBlock2: UIColor {
        //return UIColor(175, 190, 115, 100)
        //return UIColor(hex: "#04ADBFFF")!
        return UIColor(hex: "#FF7F50FF")!
    }
    
    static var gameBlock3: UIColor {
        //return UIColor(245, 222, 131, 100)
        //return UIColor(hex: "#F2B705FF")!
        return UIColor(hex: "#FF4162FF")!
    }
    
    static var gameBlock4: UIColor {
        //return UIColor(242, 184, 75, 100)
        //return UIColor(hex: "#F28705FF")!
        return UIColor(hex: "#F2E50BFF")!
    }
    
    static var gameBlock5: UIColor {
        //return UIColor(217, 94, 51, 100)
        //return UIColor(hex: "#F2380FFF")!
        return UIColor(hex: "#21B20CFF")!
    }
    
    static var gameBlock6: UIColor {
        //return UIColor(217, 94, 51, 100)
        //return UIColor(hex: "#F2380FFF")!
        return UIColor.lightGray
    }
    
    
}

