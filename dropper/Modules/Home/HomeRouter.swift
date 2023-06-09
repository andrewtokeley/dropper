//
//  HomeRouter.swift
//  dropper
//
//  Created by Andrew Tokeley on 14/03/23.
//
//

import Foundation
import Viperit

// MARK: - HomeRouter class
final class HomeRouter: Router {
}

// MARK: - HomeRouter API
extension HomeRouter: HomeRouterApi {
            
    func showSettings() {
        let module = AppModules.settings.build()
        let setupData = SettingsSetupData(gameTitle: nil, delegate: presenter as! HomePresenter)
        module.router.show(from: viewController, embedInNavController: true, setupData: setupData)
    }
    
    func showGame(from state: GameState) {
        let module = AppModules.game.build()
        let data = GameSetupData(title: state.title, state: state)
        module.router.present(from: self.viewController, embedInNavController: true, presentationStyle: .fullScreen, transitionStyle: .crossDissolve, setupData: data, completion: nil)
    }

    func showGame(_ gameTitle: GameTitle) {
        
        let module = AppModules.game.build()
        let data = GameSetupData(title: gameTitle)
        module.router.present(from: self.viewController, embedInNavController: true, presentationStyle: .fullScreen, transitionStyle: .crossDissolve, setupData: data, completion: nil)
    }
}

// MARK: - Home Viper Components
private extension HomeRouter {
    var presenter: HomePresenterApi {
        return _presenter as! HomePresenterApi
    }
}
