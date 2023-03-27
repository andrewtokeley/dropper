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
    
    override func viewIsAboutToAppear() {
        interactor.getGameTitles()
    }
}

// MARK: - HomePresenter API
extension HomePresenter: HomePresenterApi {
    
    func didSelectPlay(gameTitle: GameTitle) {
        router.showGame(gameTitle)
    }
    
    func didGetGameTitles(titles: [GameTitle]) {
        view.displayGameTitles(titles: titles)
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
