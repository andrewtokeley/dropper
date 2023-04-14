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
    var states = [GameState?]()
    
    override func setupView(data: Any) {
        //
    }
    
    override func viewIsAboutToAppear() {
        interactor.getGameTitles()
    }
}

// MARK: - HomePresenter API
extension HomePresenter: HomePresenterApi {
    
    func didSelectSettings() {
        router.showSettings()
    }
    
    func didSelectContinueGame(state: GameState) {
        router.showGame(from: state)
    }
    
    func didGetGameTitles(titles: [GameTitle], states: [GameState?]) {
        self.states = states
        view.displayGameTitles(titles: titles, states: states)
    }
    
    func didSelectPlay(gameTitle: GameTitle) {
        if let _ = self.states.first(where: {$0?.title.id == gameTitle.id }) {
            
            view.displayConfirmation(title: "Are you sure?", confirmationButtonText: "Yes", confirmationText: "If you continue you'll lose your saved game.") { result in
                if (result) {
                    self.router.showGame(gameTitle)
                } else {
                    // do nothing
                }
            }
        } else {
            self.router.showGame(gameTitle)
        }
    }    
}

extension HomePresenter: SettingsDelegate {
    func didUpdateSettings(_ settings: Settings) {
        // refresh the totles in case the scores have been cleared
        interactor.getGameTitles()
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
