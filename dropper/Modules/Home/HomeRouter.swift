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
    func showGame() {
        let module = AppModules.game.build()
        self.viewController.navigationController?.pushViewController(module.view.viewController, animated: true)
//        module.router.present(from: self.viewController, embedInNavController: true, presentationStyle: .fullScreen, transitionStyle: .partialCurl, setupData: nil, completion: nil)
    }
}

// MARK: - Home Viper Components
private extension HomeRouter {
    var presenter: HomePresenterApi {
        return _presenter as! HomePresenterApi
    }
}
