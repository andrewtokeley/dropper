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
    var game: Game!
    var nextShape: Shape?
    var firstShapeOfGame: Bool = true
    
    /**
     Called by some Interator methods to let the Presenter know to add a new Shape to the game.
     */
    fileprivate func addNewShape() {
        guard let level = self.game?.currentLevel else { return }
        
        // if we don't know the next shape, create it
        if nextShape == nil {
            nextShape = level.nextShape()
        }
        let shape = nextShape
        nextShape = level.nextShape()
        
        presenter.addNewShape(shape!, nextShape: nextShape!, pauseBeforeStarting: self.firstShapeOfGame)
        self.firstShapeOfGame = false
    }
}

// MARK: - GameInteractor API
extension GameInteractor: GameInteractorApi {
   
    
    func saveState(game: Game, grid: BlockGrid) {
        let state = GameState(blocks: grid.blocks, score: game.score, rows: game.goalProgressValue, level: game.currentLevel?.number ?? 1, genre: .tetrisClassic)
        ServiceFactory.sharedInstance.gameService.saveGameState(state) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func restoreFromState(_ state: GameState, completion: (()->Void)?) {
//        ServiceFactory.sharedInstance.gameService.getGameState { state in
//            if let state = state {
//                let rows: Int = state.blocks.count
//                let columns: Int = state.blocks[0].count
//                
//                self.game = Game(genre: .tetrisClassic,
//                                 levelService: ServiceFactory.sharedInstance.levelService,
//                                 rows: rows,
//                                 columns: columns)
//                
//                self.game?.setLevel(state.level)
//                
//                // get the latest settings
//                ServiceFactory.sharedInstance.gameService.getSettings { settings in
//                    if let settings = settings {
//                        
//                        self.game.fetchLevels {
//                            if let level = self.game!.currentLevel {
//                                self.presenter.didRestoreState(state, settings: settings)
//                                self.presenter.didFetchNextLevel(level)
//                                self.presenter.didUpdateTotals(points: 0, score: 0, rows: 0)
//                            }
//                        }
//                    }
//                }
//            }
//
//            completion?()
//        }
    }
    
    func createNewGame(_ genre : GameType) {
        
        ServiceFactory.sharedInstance.gameService.createGame(genre) { game in
            if let game = game {
                self.game = game
                
                ServiceFactory.sharedInstance.gameService.getSettings { settings in
                    if let settings = settings {
                        
                        self.presenter.didCreateNewGame(rows: self.game.rows, columns: self.game.columns, settings: settings)
                        
                        if let level = self.game.currentLevel {
                            self.presenter.didFetchNextLevel(level)
                        }
                        
                        self.presenter.didUpdateTotals(points: 0, score: 0, rows: 0)
                    }
                }
            }
        }
        
        
    }
    
    func didLoadLevel() {
        addNewShape()
    }
    
    func recordAchievements(_ achievements: Achievements, with hardDrop: Bool = false) {
        guard let game = self.game else { return  }
        guard let level = game.currentLevel else { return }
        
        game.levelAchievements.merge(achievements)
        let points = level.pointsFor(achievements, hardDrop: hardDrop)
        game.score += points
        
        if (points > 0) {
            presenter.didUpdateTotals(
                points: points,
                score: game.score,
                rows: level.goalProgressValue(game.levelAchievements))
        }
    }
    
    func readyForNewShape() {
        guard let game = self.game else { return }
        guard let level = game.currentLevel else { return }
        
        // see if level complete
        if level.goalAchieved(game.levelAchievements) {
            game.moveToNextLevel()
            if let level = game.currentLevel {
                game.levelAchievements = Achievements.zero
                self.presenter.didFetchNextLevel(level)
            } else {
                presenter.didEndGame()
            }
        } else {
            self.addNewShape()
        }
    }
    
}

// MARK: - Interactor Viper Components Api
private extension GameInteractor {
    var presenter: GamePresenterApi {
        return _presenter as! GamePresenterApi
    }
}
