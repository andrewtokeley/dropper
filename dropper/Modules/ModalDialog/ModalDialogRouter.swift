//
//  ModalDialogRouter.swift
//  dropper
//
//  Created by Andrew Tokeley on 29/03/23.
//
//

import Foundation
import Viperit

// MARK: - ModalDialogRouter class
final class ModalDialogRouter: Router {
}

// MARK: - ModalDialogRouter API
extension ModalDialogRouter: ModalDialogRouterApi {
}

// MARK: - ModalDialog Viper Components
private extension ModalDialogRouter {
    var presenter: ModalDialogPresenterApi {
        return _presenter as! ModalDialogPresenterApi
    }
}
