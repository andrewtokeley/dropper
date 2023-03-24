//
//  PopupRouter.swift
//  dropper
//
//  Created by Andrew Tokeley on 21/03/23.
//
//

import Foundation
import Viperit

// MARK: - PopupRouter class
final class PopupRouter: Router {
}

// MARK: - PopupRouter API
extension PopupRouter: PopupRouterApi {
}

// MARK: - Popup Viper Components
private extension PopupRouter {
    var presenter: PopupPresenterApi {
        return _presenter as! PopupPresenterApi
    }
}
