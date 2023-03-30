//
//  ModalDialogInteractor.swift
//  dropper
//
//  Created by Andrew Tokeley on 29/03/23.
//
//

import Foundation
import Viperit

// MARK: - ModalDialogInteractor Class
final class ModalDialogInteractor: Interactor {
}

// MARK: - ModalDialogInteractor API
extension ModalDialogInteractor: ModalDialogInteractorApi {
}

// MARK: - Interactor Viper Components Api
private extension ModalDialogInteractor {
    var presenter: ModalDialogPresenterApi {
        return _presenter as! ModalDialogPresenterApi
    }
}
