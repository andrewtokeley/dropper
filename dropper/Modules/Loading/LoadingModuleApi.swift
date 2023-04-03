//
//  LoadingModuleApi.swift
//  dropper
//
//  Created by Andrew Tokeley on 3/04/23.
//
//

import Viperit

//MARK: - LoadingRouter API
protocol LoadingRouterApi: RouterProtocol {
    func navigateToHome()
}

//MARK: - LoadingView API
protocol LoadingViewApi: UserInterfaceProtocol {
    func animateImage()
}

//MARK: - LoadingPresenter API
protocol LoadingPresenterApi: PresenterProtocol {
    func animationComplete()
}

//MARK: - LoadingInteractor API
protocol LoadingInteractorApi: InteractorProtocol {
}
