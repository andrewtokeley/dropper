//
//  LoadingInteractor.swift
//  dropper
//
//  Created by Andrew Tokeley on 3/04/23.
//
//

import Foundation
import Viperit

// MARK: - LoadingInteractor Class
final class LoadingInteractor: Interactor {
}

// MARK: - LoadingInteractor API
extension LoadingInteractor: LoadingInteractorApi {
}

// MARK: - Interactor Viper Components Api
private extension LoadingInteractor {
    var presenter: LoadingPresenterApi {
        return _presenter as! LoadingPresenterApi
    }
}
