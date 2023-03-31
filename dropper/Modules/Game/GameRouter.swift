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
    
    func navigateHome() {
        viewController.presentingViewController?.dismiss(animated: true)
    }
    
    func showSettings(_ title: GameTitle) {
        let module = AppModules.settings.build()
        let setupData = SettingsSetupData(gameTitle: title, delegate: presenter as! GamePresenter)
        module.router.show(from: viewController, embedInNavController: true, setupData: setupData)
    }
    
    func closeSettings() {
        
    }
}

// MARK: - Game Viper Components
private extension GameRouter {
    var presenter: GamePresenterApi {
        return _presenter as! GamePresenterApi
    }
}
