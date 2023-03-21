//
//  SettingsRouter.swift
//  dropper
//
//  Created by Andrew Tokeley on 20/03/23.
//
//

import Foundation
import Viperit

// MARK: - SettingsRouter class
final class SettingsRouter: Router {
}

// MARK: - SettingsRouter API
extension SettingsRouter: SettingsRouterApi {
}

// MARK: - Settings Viper Components
private extension SettingsRouter {
    var presenter: SettingsPresenterApi {
        return _presenter as! SettingsPresenterApi
    }
}
