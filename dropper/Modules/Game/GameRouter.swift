//
//  GameRouter.swift
//  dropper
//
//  Created by Andrew Tokeley on 21/02/23.
//
//

import Foundation
import Viperit

// MARK: - GameRouter class
final class GameRouter: Router {
}

// MARK: - GameRouter API
extension GameRouter: GameRouterApi {
    func showSettings() {
        let module = AppModules.settings.build()
        let setupData = SettingsSetupData(delegate: presenter as! GamePresenter)
        module.router.show(from: viewController, embedInNavController: true, setupData: setupData)
    }
}

// MARK: - Game Viper Components
private extension GameRouter {
    var presenter: GamePresenterApi {
        return _presenter as! GamePresenterApi
    }
}
