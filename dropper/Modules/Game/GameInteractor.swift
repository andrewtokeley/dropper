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
    let gameService = ServiceFactory.sharedInstance.gameService
    let settingsService = ServiceFactory.sharedInstance.settingsService
    
    private func configurePresenter(_ game: Game, fromState: Bool) {
        self.game = game
        
        //self.gameService.getSettings(for: game.title) { settings in
        self.settingsService.getSettings() { settings in
            if let settings = settings {
                
                self.presenter.enableHaptics(settings.enableHaptics)
                
                // save the date this title was played
                var updateSettings = settings
                updateSettings.lastPlayed = Date.now
                self.gameService.saveSettings(for: game.title, settings: updateSettings, completion: nil)
                
                self.presenter.didCreateNewGame(game: game, settings: settings)
                
                if let level = game.currentLevel {
                    self.presenter.didFetchNextLevel(level, fromState: fromState)
                }
                
                let currentProgressValue = game.currentLevel?.goalProgressValue(game.levelAchievements) ?? 0
                self.presenter.didUpdateTotals(points: 0, score: game.score, goalProgressValue: currentProgressValue, goalUnit: self.game.currentLevel?.goalUnit)

            }
        }
    }
    
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
        
        presenter.addNewShape(shape!, nextShape: nextShape!)
        self.firstShapeOfGame = false
    }
}

// MARK: - GameInteractor API
extension GameInteractor: GameInteractorApi {
    
    func restoreFromState(_ state: GameState) {
        try? self.gameService.createGame(from: state) { game in
            if let game = game {
                self.configurePresenter(game, fromState: true)
            }
        }
    }
    
    func createNewGame(_ title : GameTitle) {
        try? self.gameService.createGame(for: title) { game in
            if let game = game {
                self.configurePresenter(game, fromState: false)
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
        
        // track the combined achievements across all levels
        game.gameAchievements.merge(achievements)
        
        let points = level.pointsFor(moveAchievements: achievements, levelAchievements: game.levelAchievements, hardDrop: hardDrop)
        
        game.score += points
        
        if (points > 0) {
            presenter.didUpdateTotals(
                points: points,
                score: game.score,
                goalProgressValue: level.goalProgressValue(game.levelAchievements),
                goalUnit: level.goalUnit)
        }
    }
    
    func readyForNewShape() {
        guard let game = self.game else { return }
        guard let level = game.currentLevel else { return }
        
        // see if level complete
        if level.goalAchieved(game.levelAchievements) {
            if game.moveToNextLevel() {
                if let level = game.currentLevel {
                    
                    // reset goal progress count
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.presenter.didUpdateTotals(points: nil, score: nil, goalProgressValue: nil, goalUnit: level.goalUnit)
                        
                        self.presenter.didFetchNextLevel(level, fromState: false)
                    }
                }
            } else {
                // no morew levels!
                presenter.didWinGame()
            }
        } else {
            self.addNewShape()
        }
    }
    
    func saveScores() async -> Bool {
        guard let game = self.game else { return false }
        let score = Score(points: game.score, gameAchievements: game.gameAchievements)
        let isHighScore = try? await self.gameService.addScore(for: game.title, score: score)
        return isHighScore ?? false
    }
    
    func saveScores(completion: ((Bool)->Void)?) {
        guard let game = self.game else { return }
        
        let score = Score(points: game.score, gameAchievements: game.gameAchievements)
        
        self.gameService.addScore(for: game.title, score: score, completion: { result in
            switch result {
            case let .success(isHighscore):
                completion?(isHighscore)
            default:
                completion?(false)
            }
        })
        
    }
    
    func saveState() {
        guard let game = self.game else { return }
        gameService.saveGameState(state: GameState(game: game)) { error in
            //
        }
    }
    
    func clearState() {
        guard let game = self.game else { return }
        gameService.clearGameState(for: game.title) { result in
            
        }
    }
}

// MARK: - Interactor Viper Components Api
private extension GameInteractor {
    var presenter: GamePresenterApi {
        return _presenter as! GamePresenterApi
    }
}
