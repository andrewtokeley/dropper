//
//  ModalDialogAction.swift
//  dropper
//
//  Created by Andrew Tokeley on 30/03/23.
//

import Foundation

class ModalDialogAction {

    enum Style: Int {
        case standard = 0
        case cancel
        case destructive
    }
    
    /**
     Handler for action's button being clicked
     */
    var handler: ((ModalDialogAction) -> Void)?
    
    /**
     The title of the action’s button.
     */
    var title: String?
    
    /**
     The style that applies to the action’s button.
     */
    var style: ModalDialogAction.Style = .standard
    
    /**
     A Boolean value indicating whether the action is currently enabled.
     */
    var isEnabled: Bool = true
    
    init(title: String?, style: ModalDialogAction.Style, handler: ((ModalDialogAction) -> Void)?) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}
