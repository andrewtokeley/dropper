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
    
    func didSelectContinueGame(state: GameState) {
        router.showGame(from: state)
    }
    
    func didGetGameTitles(titles: [GameTitle], states: [GameState?]) {
        self.states = states
        view.displayGameTitles(titles: titles, states: states)
    }
    
    func didSelectPlay(gameTitle: GameTitle) {
        if let _ = self.states.first(where: {$0?.title.id == gameTitle.id }) {
            var data = ModalDialogSetupData(heading: "Are you sure?", message: "Starting a new game will remove your saved game.", primaryButtonText: "Start New Game", secondaryButtonText: "Cancel", callback: { (type) in
                if type == .primary {
                    self.router.showGame(gameTitle)
                }
            } )
            router.showModalDialog(data)
        } else {
            router.showGame(gameTitle)
        }
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
