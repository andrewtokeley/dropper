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
    
    func getGameTitles() -> [GameTitle] {
        return [TetrisClassicTitle(), ColourMatcherTitle()]
    }

    func getHighScores() {
        var highScores = [GameTitle: Int]()
        let dispatch = DispatchGroup()
        let titles = getGameTitles()
        for title in titles {
            dispatch.enter()
            self.gameService.getScoreHistory(for: title) { scores in
                var high = 0
                if scores.count > 0 {
                    high = scores.max() ?? 0
                }
                highScores[title] = high
                dispatch.leave()
            }
        }
        dispatch.notify(queue: DispatchQueue.main, execute: {
            self.presenter.didGetHighScores(highScores: highScores)
        })
    }
    
}

// MARK: - Interactor Viper Components Api
private extension HomeInteractor {
    var presenter: HomePresenterApi {
        return _presenter as! HomePresenterApi
    }
}
