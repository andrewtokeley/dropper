//
//  HomeInteractor.swift
//  dropper
//
//  Created by Andrew Tokeley on 14/03/23.
//
//

import Foundation
import Viperit

// MARK: - HomeInteractor Class
final class HomeInteractor: Interactor {
    private var gameService = ServiceFactory.sharedInstance.gameService
}

// MARK: - HomeInteractor API
extension HomeInteractor: HomeInteractorApi {
    
    func getGameTitles() {
        gameService.getGameTitles { titles in
            self.presenter.didGetGameTitles(titles: titles)
        }
    }
    
}

// MARK: - Interactor Viper Components Api
private extension HomeInteractor {
    var presenter: HomePresenterApi {
        return _presenter as! HomePresenterApi
    }
}
