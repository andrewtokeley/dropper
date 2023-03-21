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
    var game: Game?
    var nextShape: Shape?
    var firstShapeOfGame: Bool = true
    
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
   
    func createNewGame() {
        let rows: Int = 22
        let columns: Int = 10
        
        self.game = Game(genre: .tetrisClassic,
                        levelService: ServiceFactory.sharedInstance.levelService,
                        rows: rows,
                        columns: columns)
        
        self.game!.fetchLevels {
            if let level = self.game!.currentLevel {
                self.presenter.didCreateNewGame(rows, columns)
                self.presenter.didFetchNextLevel(level)
                self.presenter.didUpdateTotals(points: 0, score: 0, rows: 0)
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
        
        presenter.didUpdateTotals(
            points: points,
            score: game.score,
            rows: level.goalProgressValue(game.levelAchievements))
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
