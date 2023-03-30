//
//  ModalDialogSetupData.swift
//  dropper
//
//  Created by Andrew Tokeley on 29/03/23.
//

import Foundation

struct ModalDialogSetupData {
    var heading: String = ""
    var message: String = ""
    var primaryButtonText: String = "OK"
    var secondaryButtonText: String = "Cancel"
    //var tag: Any?
    var callback: ((ModalDialogButtonType)->Void)?
}
