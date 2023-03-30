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
        var statesResult = [GameState?]()
        var titlesResult = [GameTitle]()
        
        let dispatch = DispatchGroup()
        gameService.getGameTitles { titles in
            titlesResult.append(contentsOf: titles)
            for title in titles {
                dispatch.enter()
                // get state for each title
                self.gameService.getGameState(for: title) { state in
                    statesResult.append(state)
                    dispatch.leave()
                }
            }
        }
        dispatch.notify(queue: DispatchQueue.main, execute: {
            self.presenter.didGetGameTitles(titles: titlesResult, states: statesResult)
        })
    }
    
}

// MARK: - Interactor Viper Components Api
private extension HomeInteractor {
    var presenter: HomePresenterApi {
        return _presenter as! HomePresenterApi
    }
}
