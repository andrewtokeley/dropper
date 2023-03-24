//
//  PopupPresenter.swift
//  dropper
//
//  Created by Andrew Tokeley on 21/03/23.
//
//

import Foundation
import Viperit

// MARK: - PopupPresenter Class
final class PopupPresenter: Presenter {
    
    var callback: ((String)->Void)?
    
    override func setupView(data: Any) {
        if let setupData = data as? PopupSetupData {
            view.display(setupData.heading, message: setupData.message, buttonText: setupData.buttonText, secondaryButtonText: setupData.secondaryButtonText)
            callback = setupData.callback
        }
    }
    
}

// MARK: - PopupPresenter API
extension PopupPresenter: PopupPresenterApi {

    func didSelectButton(_ buttonText: String) {
        callback?(buttonText)
        //delegate?.didSelectAction(buttonText)
    }

}

// MARK: - Popup Viper Components
private extension PopupPresenter {
    var view: PopupViewApi {
        return _view as! PopupViewApi
    }
    var interactor: PopupInteractorApi {
        return _interactor as! PopupInteractorApi
    }
    var router: PopupRouterApi {
        return _router as! PopupRouterApi
    }
}
