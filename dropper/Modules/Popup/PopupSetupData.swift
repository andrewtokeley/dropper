//
//  PopupSetupData.swift
//  dropper
//
//  Created by Andrew Tokeley on 21/03/23.
//

import Foundation

struct PopupSetupData {
    var callback: ((String)->Void)?
    var heading: String = "Title"
    var message: String = "Body"
    var buttonText: String = "OK"
    var secondaryButtonText: String?
}
