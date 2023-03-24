//
//  PopupModuleApi.swift
//  dropper
//
//  Created by Andrew Tokeley on 21/03/23.
//
//

import Viperit

//MARK: - PopupRouter API
protocol PopupRouterApi: RouterProtocol {
}

//MARK: - PopupView API
protocol PopupViewApi: UserInterfaceProtocol {
    func display(_ title: String, message: String, buttonText: String, secondaryButtonText: String?)
}

//MARK: - PopupPresenter API
protocol PopupPresenterApi: PresenterProtocol {
    func didSelectButton(_ buttonText: String)
    
}

//MARK: - PopupInteractor API
protocol PopupInteractorApi: InteractorProtocol {
}
