//
//  LoadingRouter.swift
//  dropper
//
//  Created by Andrew Tokeley on 3/04/23.
//
//

import Foundation
import Viperit

// MARK: - LoadingRouter class
final class LoadingRouter: Router {
}

// MARK: - LoadingRouter API
extension LoadingRouter: LoadingRouterApi {
    func navigateToHome() {
        let module = AppModules.home.build()
        module.router.present(from: self.viewController, embedInNavController: false, presentationStyle: .fullScreen, transitionStyle: .crossDissolve, setupData: nil, completion: nil)
    }
}

// MARK: - Loading Viper Components
private extension LoadingRouter {
    var presenter: LoadingPresenterApi {
        return _presenter as! LoadingPresenterApi
    }
}
