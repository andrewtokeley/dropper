//
//  HomeModuleApi.swift
//  dropper
//
//  Created by Andrew Tokeley on 14/03/23.
//
//

import Viperit

//MARK: - HomeRouter API
protocol HomeRouterApi: RouterProtocol {
    func showGame()
}

//MARK: - HomeView API
protocol HomeViewApi: UserInterfaceProtocol {
}

//MARK: - HomePresenter API
protocol HomePresenterApi: PresenterProtocol {
    func didSelectPlay()
}

//MARK: - HomeInteractor API
protocol HomeInteractorApi: InteractorProtocol {
}
