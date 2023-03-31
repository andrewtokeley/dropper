//
//  UIViewControllerExtension.swift
//  dropper
//
//  Created by Andrew Tokeley on 31/03/23.
//

import Foundation
import UIKit

extension UIViewController {

    static func fromStoryboard(_ name: String, identifier: String, bundle: Bundle?) -> Self {
        let storyboard = UIStoryboard(name: name, bundle: bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier) as! Self
        return vc
    }
}
