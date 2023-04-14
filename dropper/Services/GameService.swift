//
//  GameService.swift
//  dropper
//
//  Created by Andrew Tokeley on 21/03/23.
//

import Foundation

protocol GameServiceContract {
    
    func getGameTitles(completion: (([GameTitle])->Void)?)
    
    /**
     Creats a new game instance for the given game type
     */
    func createGame(for title: GameTitle, completion: ((Game?) -> Void)?) throws
    func createGame(from state: GameState, completion: ((Game?) -> Void)?) throws
    
    func saveGameState(state: GameState, completion: ((Error?)->Void)?)
    func getGameState(for title: GameTitle, completion: ((GameState?)->Void)?)
    func clearGameState(for title: GameTitle, completion: ((Bool)->Void)?)
    
    func getSettings(for title: GameTitle, completion: ((Settings?) -> Void)?)
    func saveSettings(for title: GameTitle, settings: Settings, completion: (()->Void)?)
    func clearSettingsState(for title: GameTitle, completion: ((Bool)->Void)?)
    
    func getScoreHistory(for title: GameTitle, completion: (([Score]) -> Void)?)
    func addScore(for title: GameTitle, score: Score, completion: ((Result<Bool, ServiceError>) -> Void)?)
    func clearScoreState(for title: GameTitle?, completion: ((Bool)->Void)?)
    
    // async versions
    func addScore(for title: GameTitle, score: Score) async throws -> Bool
    func getScoreHistory(for title: GameTitle) async -> [Score]
    func clearScoreState(for title: GameTitle?) async -> Bool
}

class GameService: ServiceBase {
    enum KeyType: String {
        case SETTINGS = "dropper_settings"
        case SCORES = "dropper_scores"
        case STATE = "dropper_state"
    }
    
    let userDefaults = UserDefaults.standard
    
    func keyFor(_ title: GameTitle, key: KeyType) -> String {
        return title.id + KEY_PREFIX + key.rawValue
    }
}

extension GameService: GameServiceContract {
    
    // MARK: - Game
    
    func createGame(from state: GameState, completion: ((Game?) -> Void)?) throws {
        try self.createGame(for: state.title) { game in
            if let game = game {
                game.columns = state.columns
                game.rows = state.rows
                game.setLevel(state.level)
                game.score = state.score
                game.levelAchievements = state.levelAchievements
                game.gameAchievements = state.gameAchievements
                game.grid = try! BlockGrid(state.blocks)
                completion?(game)
            }
        }
    }
    
    func createGame(for title: GameTitle, completion: ((Game?) -> Void)?) throws {
        
        if let rootGameName = title.rootGameName {
            let gameClassName = "\(rootGameName)Game"
            if let bundleName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
                let classInBundle = (bundleName + "." + gameClassName).replacingOccurrences(of: "[ -]", with: "_", options: .regularExpression)
                
                if let gameClass = NSClassFromString(classInBundle) as? Game.Type {
                    completion?(gameClass.init())
                } else {
                    throw ServiceError.Failed()
                }
            }
        } else {
            throw ServiceError.Failed()
        }
    }
    
    // MARK: - Game Titles
    
    func getGameTitles(completion: (([GameTitle])->Void)?) {
        let dispatch = DispatchGroup()
        
        let gameTitles = [try! TetrisClassicTitle(),
                          try! ColourMatcherTitle(),
                          try! GravityMatcherTitle(),
                          try! JewelTitle()]
        
        var allSettings = [Settings?]()
        
        for title in gameTitles {
            dispatch.enter()
            //title.isLastPlayed = false
            getScoreHistory(for: title) { scores in
                
                if let highScore = scores.max(by: { a, b in
                    a.points < b.points
                }) {
                    
                    title.highScore = highScore.points
                    
                    // jewels game only
                    if let _ = title as? JewelTitle {
                        let jewels = highScore.gameAchievements.get(.jewel)
                        if jewels > 0 {
                            title.highScoreDescription = "+ \(jewels) jewels!"
                        }
                    }
                }
                dispatch.leave()
            }
            getSettings(for: title) { settings in
                title.lastPlayed = settings?.lastPlayed
                allSettings.append(settings)
            }
        }
        
        // sort the gameTitles by lastplayed
        var sorted = gameTitles
        sorted.sort { a, b in
            a.lastPlayed ?? Date.now > b.lastPlayed ?? Date.now
        }
        
        dispatch.notify(queue: DispatchQueue.main, execute: {
            completion?(sorted)
        })
    }
    
    // MARK: - State
    
    func saveGameState(state: GameState, completion: ((Error?)->Void)?) {
        do {
            try userDefaults.setObject(state, forKey: keyFor(state.title, key: .STATE))
            completion?(nil)
        } catch let error {
            completion?(error)
        }
    }
    
    func getGameState(for title: GameTitle, completion: ((GameState?)->Void)?) {
        let state = try? userDefaults.getObject(forKey: keyFor(title, key: .STATE), castTo: GameState.self)
        completion?(state)
    }
    
    func clearGameState(for title: GameTitle, completion: ((Bool)->Void)?) {
        userDefaults.removeObject(forKey: keyFor(title, key: .STATE))
        completion?(true)
    }
    
    // MARK: - Settings
    
    func getSettings(for title: GameTitle, completion: ((Settings?) -> Void)?) {
        let settings = try? userDefaults.getObject(forKey: keyFor(title, key: .SETTINGS), castTo: Settings.self)
        if let settings = settings {
            completion?(settings)
        } else {
            completion?(Settings.defaultGameSettings)
        }
    }
    
    func saveSettings(for title: GameTitle, settings: Settings, completion: (()->Void)?) {
        if let _ = try? userDefaults.setObject(settings, forKey: keyFor(title, key: .SETTINGS)) {
            completion?()
        }
    }
    
    func clearSettingsState(for title: GameTitle, completion: ((Bool)->Void)?) {
        userDefaults.removeObject(forKey: keyFor(title, key: .SETTINGS))
        completion?(true)
    }
    
    //MARK: - Scores
    
    func getScoreHistory(for title: GameTitle) async -> [Score] {
        let result = try? userDefaults.getObject(forKey: keyFor(title, key: .SCORES), castTo: [Score].self)
        return  result ?? [Score]()
    }
    
    func getScoreHistory(for title: GameTitle, completion: (([Score]) -> Void)?) {
        if let scores = try? userDefaults.getObject(forKey: keyFor(title, key: .SCORES), castTo: [Score].self) {
            completion?(scores)
        } else {
            completion?([Score]())
        }
    }

    func clearScoreState(for title: GameTitle?) async -> Bool {
        if let title = title {
            userDefaults.removeObject(forKey: keyFor(title, key: .SCORES))
        } else {
            // clear all the scores for all titles
            getGameTitles { titles in
                for title in titles {
                    self.userDefaults.removeObject(forKey: self.keyFor(title, key: .SCORES))
                }
            }
        }
        return true
    }
    
    func clearScoreState(for title: GameTitle?, completion: ((Bool)->Void)?) {
        if let title = title {
            userDefaults.removeObject(forKey: keyFor(title, key: .SCORES))
            completion?(true)
        } else {
            // clear all the scores for all titles
            getGameTitles { titles in
                for title in titles {
                    self.userDefaults.removeObject(forKey: self.keyFor(title, key: .SCORES))
                }
                completion?(true)
            }
        }
    }
    
    func addScore(for title: GameTitle, score: Score) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            self.addScore(for: title, score: score) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    func addScore(for title: GameTitle, score: Score, completion: ((Result<Bool, ServiceError>) -> Void)?) {
        self.getScoreHistory(for: title) { scores in
            
            var isHighScore = false
            
            var maxScore = scores.map({$0.points}).max() ?? 0
            var newScores = [Score]()
            newScores.append(contentsOf: scores)
            
            if scores.count < 3 {
                // there's room to add a new score
                newScores.append(score)
                
                // the new score might be the max now
                if score.points > maxScore {
                    isHighScore = true
                    maxScore = score.points
                }
                
            } else if scores.count == 3 {
                
                // replace the highscore if score is higher
                if score.points > maxScore {
                    isHighScore = true
                    if let indexOfMax = scores.map({$0.points}).firstIndex(of: maxScore) {
                        newScores[indexOfMax] = score
                    }
                }
            }
            
            if let _ = try? self.userDefaults.setObject(newScores, forKey: self.keyFor(title, key: .SCORES)) {
                completion?(.success(isHighScore))
            } else {
                completion?(.failure(ServiceError.Failed("Failed to save scores.")))
            }
        }
    }

}


