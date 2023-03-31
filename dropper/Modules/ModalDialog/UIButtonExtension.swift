//
//  UIButtonExtension.swift
//  dropper
//
//  Created by Andrew Tokeley on 31/03/23.
//

import Foundation
import UIKit

extension UIButton {
    
    /// Creates a duplicate of the terget UIButton
    /// The caller specified the UIControlEvent types to copy across to the duplicate
    ///
    /// - Parameter controlEvents: UIControlEvent types to copy
    /// - Returns: A UIButton duplicate of the original button
    func duplicate(forControlEvents controlEvents: [UIControl.Event]) -> UIButton? {
        
        // Attempt to duplicate button by archiving and unarchiving the original UIButton
        
        if let archivedButton = try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false) {
        
            if let buttonDuplicate = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIButton.self, from: archivedButton) {
                // Copy targets and associated actions
                self.allTargets.forEach { target in
                    controlEvents.forEach { controlEvent in
                        
                        self.actions(forTarget: target, forControlEvent: controlEvent)?.forEach { action in
                            buttonDuplicate.addTarget(target, action: Selector(action), for: controlEvent)
                        }
                    }
                }
                return buttonDuplicate
            }
        }
        return nil
    }
}
