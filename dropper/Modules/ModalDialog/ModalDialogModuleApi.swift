//
//  ModalDialogModuleApi.swift
//  dropper
//
//  Created by Andrew Tokeley on 29/03/23.
//
//

import Viperit

//MARK: - ModalDialogRouter API
protocol ModalDialogRouterApi: RouterProtocol {
}

//MARK: - ModalDialogView API
protocol ModalDialogViewApi: UserInterfaceProtocol {
    func display(_ heading: String, message: String, primaryButtonText: String, secondaryButtonText: String?)
}

//MARK: - ModalDialogPresenter API
protocol ModalDialogPresenterApi: PresenterProtocol {
    func didSelectButton(_ type: ModalDialogButtonType)
}

//MARK: - ModalDialogInteractor API
protocol ModalDialogInteractorApi: InteractorProtocol {
}
