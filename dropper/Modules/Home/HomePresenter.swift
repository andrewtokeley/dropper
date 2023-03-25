//
//  HomePresenter.swift
//  dropper
//
//  Created by Andrew Tokeley on 14/03/23.
//
//

import Foundation
import Viperit

// MARK: - HomePresenter Class
final class HomePresenter: Presenter {
    
    override func setupView(data: Any) {
        //
    }
    override func viewHasLoaded() {
        let titles = interactor.getGameTitles()
        view.displayGameTitles(titles)
    }
    
}

// MARK: - HomePresenter API
extension HomePresenter: HomePresenterApi {
    func didGetHighScores(highScores: [GameTitle : Int]) {
        
    }
    
    func didSelectPlay(gameTitle: GameTitle) {
        router.showGame(gameTitle)
    }
    
    func didGetGameTitles(gameTitles: [GameTitle]) {
        view.displayGameTitles(gameTitles)
    }
    
}

// MARK: - Home Viper Components
private extension HomePresenter {
    var view: HomeViewApi {
        return _view as! HomeViewApi
    }
    var interactor: HomeInteractorApi {
        return _interactor as! HomeInteractorApi
    }
    var router: HomeRouterApi {
        return _router as! HomeRouterApi
    }
}
