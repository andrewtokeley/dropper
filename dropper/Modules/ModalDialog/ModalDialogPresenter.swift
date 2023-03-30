//
//  ModalDialogPresenter.swift
//  dropper
//
//  Created by Andrew Tokeley on 29/03/23.
//
//

import Foundation
import Viperit

// MARK: - ModalDialogPresenter Class
final class ModalDialogPresenter: Presenter {
    var callback: ((ModalDialogButtonType)->Void)?
    var data: ModalDialogSetupData?
    
    override func setupView(data: Any) {
        if let data = data as? ModalDialogSetupData {
            self.data = data
        }
    }
    
    override func viewHasAppeared() {
        
        if let data = self.data {
            view.display(data.heading, message: data.message, primaryButtonText: data.primaryButtonText, secondaryButtonText: data.secondaryButtonText)
            callback = data.callback
        }
    }
}

// MARK: - ModalDialogPresenter API
extension ModalDialogPresenter: ModalDialogPresenterApi {
    
    func didSelectButton(_ type: ModalDialogButtonType) {
        callback?(type)
        router.dismiss(animated: false, completion: nil)
    }
}

// MARK: - ModalDialog Viper Components
private extension ModalDialogPresenter {
    var view: ModalDialogViewApi {
        return _view as! ModalDialogViewApi
    }
    var interactor: ModalDialogInteractorApi {
        return _interactor as! ModalDialogInteractorApi
    }
    var router: ModalDialogRouterApi {
        return _router as! ModalDialogRouterApi
    }
}
