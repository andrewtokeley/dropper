//
//  UIViewExtension.swift
//  dropper
//
//  Created by Andrew Tokeley on 28/03/23.
//

import Foundation
import UIKit

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    
    func rotate(_ durationOneRotation: CFTimeInterval ) {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = durationOneRotation
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    enum Side {
        case left, right, top, bottom
    }

    func addBorder(toSides sides: [Side], withColor color: UIColor, andThickness thickness: CGFloat) {
        for side in sides {
            addBorder(toSide: side, withColor: color, andThickness: thickness)
        }
    }
    
    func addBorder(toSide side: Side, withColor color: UIColor, andThickness thickness: CGFloat) {

        let border = CALayer()
        border.backgroundColor = color.cgColor
        
        border.zPosition = 100
        switch side {
        case .left: border.frame = CGRect(x: bounds.minX, y: bounds.minY, width: thickness, height: bounds.height + thickness); break
        case .right: border.frame = CGRect(x: bounds.maxX, y: bounds.minY, width: thickness, height: bounds.height + thickness); break
        case .top: border.frame = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width + thickness, height: thickness); break
        case .bottom: border.frame = CGRect(x: bounds.minX, y: bounds.maxY, width: bounds.width + thickness, height: thickness); break
        }
        layer.addSublayer(border)
    }
}
