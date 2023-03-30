//
//  HomeModuleApi.swift
//  dropper
//
//  Created by Andrew Tokeley on 14/03/23.
//
//

import Viperit

//MARK: - HomeRouter API
protocol HomeRouterApi: RouterProtocol {
    func showModalDialog(_ setup: ModalDialogSetupData)
    func showGame(_ gameType: GameTitle)
    func showGame(from state: GameState)
}

//MARK: - HomeView API
protocol HomeViewApi: UserInterfaceProtocol {
    func displayGameTitles(titles: [GameTitle], states: [GameState?])
}

//MARK: - HomePresenter API
protocol HomePresenterApi: PresenterProtocol {
    func didSelectPlay(gameTitle: GameTitle)
    func didSelectContinueGame(state: GameState)
    func didGetGameTitles(titles: [GameTitle], states: [GameState?])
}

//MARK: - HomeInteractor API
protocol HomeInteractorApi: InteractorProtocol {
    /**
     Retrieves the available games to play.
     */
    func getGameTitles()

}
