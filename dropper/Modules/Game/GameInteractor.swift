//
//  GameInteractor.swift
//  dropper
//
//  Created by Andrew Tokeley on 21/02/23.
//
//

import Foundation
import Viperit

// MARK: - GameInteractor Class
final class GameInteractor: Interactor {
}

// MARK: - GameInteractor API
extension GameInteractor: GameInteractorApi {
    func createNewGame() {
        let grid = try! BlockGrid(rows: 22, columns: 10)
        let game = Game(genre: .tetrisClassic)
        
        presenter.didCreateNewGame(game: game, grid: grid)
    }
    
}

// MARK: - Interactor Viper Components Api
private extension GameInteractor {
    var presenter: GamePresenterApi {
        return _presenter as! GamePresenterApi
    }
}
