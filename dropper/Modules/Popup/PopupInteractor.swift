//
//  PopupInteractor.swift
//  dropper
//
//  Created by Andrew Tokeley on 21/03/23.
//
//

import Foundation
import Viperit

// MARK: - PopupInteractor Class
final class PopupInteractor: Interactor {
}

// MARK: - PopupInteractor API
extension PopupInteractor: PopupInteractorApi {
}

// MARK: - Interactor Viper Components Api
private extension PopupInteractor {
    var presenter: PopupPresenterApi {
        return _presenter as! PopupPresenterApi
    }
}
