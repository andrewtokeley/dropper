//
//  LoadingPresenter.swift
//  dropper
//
//  Created by Andrew Tokeley on 3/04/23.
//
//

import Foundation
import Viperit

// MARK: - LoadingPresenter Class
final class LoadingPresenter: Presenter {
    
    override func viewHasLoaded() {
        view.animateImage()
    }
}

// MARK: - LoadingPresenter API
extension LoadingPresenter: LoadingPresenterApi {
    func animationComplete() {
        router.navigateToHome()
    }
}

// MARK: - Loading Viper Components
private extension LoadingPresenter {
    var view: LoadingViewApi {
        return _view as! LoadingViewApi
    }
    var interactor: LoadingInteractorApi {
        return _interactor as! LoadingInteractorApi
    }
    var router: LoadingRouterApi {
        return _router as! LoadingRouterApi
    }
}
