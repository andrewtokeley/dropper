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
    func showGame(_ gameType: GameTitle)
}

//MARK: - HomeView API
protocol HomeViewApi: UserInterfaceProtocol {
    
    func displayGameTitles(_ titles: [GameTitle])
    
}

//MARK: - HomePresenter API
protocol HomePresenterApi: PresenterProtocol {
    func didSelectPlay(gameTitle: GameTitle)
    
    func didGetGameTitles(gameTitles: [GameTitle])
    
    func didGetHighScores(highScores: [GameTitle: Int])
}

//MARK: - HomeInteractor API
protocol HomeInteractorApi: InteractorProtocol {
    /**
     Retrieves the available games to play.
     */
    func getGameTitles() -> [GameTitle]
    
    /**
     Retrieves the highscores of each type of game.
     
     Once retrieved, will call the Presenter's ``didGetHighScores`` method
     */
    func getHighScores()
}
