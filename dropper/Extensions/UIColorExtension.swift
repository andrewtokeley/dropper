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

    // MARK: - Hex Conversion
    
    func asHex() -> String {
        let components = self.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0

        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        return hexString
     }

    static func fromHex(hexString: String) -> UIColor {
        var colorString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        colorString = colorString.replacingOccurrences(of: "#", with: "").uppercased()

        let alpha: CGFloat = 1.0
        let red: CGFloat = self.colorComponentFrom(colorString: colorString, start: 0, length: 2)
        let green: CGFloat = self.colorComponentFrom(colorString: colorString, start: 2, length: 2)
        let blue: CGFloat = self.colorComponentFrom(colorString: colorString, start: 4, length: 2)

        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }

    static func colorComponentFrom(colorString: String, start: Int, length: Int) -> CGFloat {

        let startIndex = colorString.index(colorString.startIndex, offsetBy: start)
        let endIndex = colorString.index(startIndex, offsetBy: length)
        let subString = colorString[startIndex..<endIndex]
        let fullHexString = length == 2 ? subString : "\(subString)\(subString)"
        var hexComponent: UInt64 = 0
        
        guard Scanner(string: String(fullHexString)).scanHexInt64(&hexComponent) else {
            return 0
        }
        let hexFloat: CGFloat = CGFloat(hexComponent)
        let floatValue: CGFloat = CGFloat(hexFloat / 255.0)
        return floatValue
    }
    
    // MARK: - App colours

    static func from(_ blockColour: BlockColour) -> UIColor {
        switch blockColour {
            case .colour1: return .gameBlock1
            case .colour2: return .gameBlock2
            case .colour3: return .gameBlock3
            case .colour4: return .gameBlock4
            case .colour5: return .gameBlock5
            case .colour6: return .gameBlock6
        }
    }
    
    static var gameBackground: UIColor {
        return UIColor.fromHex(hexString: "#0B5394FF")
    }
    
    static var gameLightGray: UIColor {
        return UIColor.fromHex(hexString: "#F3F3F3FF")
    }
    
    static var gameHighlight: UIColor {
        return UIColor.gameBlock2
    }
    
    static var gameBlock1: UIColor {
        return UIColor.fromHex(hexString: "#17DEEEFF")
        
    }
    
    static var gameBlock2: UIColor {
        return UIColor.fromHex(hexString: "#FF7F50FF")
    }
    
    static var gameBlock3: UIColor {
        return UIColor.fromHex(hexString: "#FF4162FF")
    }
    
    static var gameBlock4: UIColor {
        return UIColor.fromHex(hexString: "#F2E50BFF")
    }
    
    static var gameBlock5: UIColor {
        return UIColor.fromHex(hexString: "#21B20CFF")
    }
    
    static var gameBlock6: UIColor {
        return UIColor.lightGray
    }
    
    
}

