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
    
    func getScoreHistory(for title: GameTitle, completion: (([Int]) -> Void)?)
    func addScore(for title: GameTitle, score: Int, completion: ((Bool?, ServiceError?) -> Void)?)
    func clearScoreState(for title: GameTitle, completion: ((Bool)->Void)?)
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
                    throw ServiceError.Failed
                }
            }
        } else {
            throw ServiceError.Failed
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
                title.highScore = scores.max() ?? 0
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
            completion?(Settings.defaultSettings)
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
    
    func getScoreHistory(for title: GameTitle, completion: (([Int]) -> Void)?) {
        if let scores = try? userDefaults.getObject(forKey: keyFor(title, key: .SCORES), castTo: [Int].self) {
            completion?(scores)
        } else {
            completion?([Int]())
        }
    }

    func clearScoreState(for title: GameTitle, completion: ((Bool)->Void)?) {
        userDefaults.removeObject(forKey: keyFor(title, key: .SCORES))
        completion?(true)
    }
    
    func addScore(for title: GameTitle, score: Int, completion: ((Bool?, ServiceError?) -> Void)?)
    {
        self.getScoreHistory(for: title) { scores in
            
            var isHighScore = false
            var maxScore = scores.max() ?? 0
            var newScores = [Int]()
            newScores.append(contentsOf: scores)
            
            if scores.count < 3 {
                // there's room to add a new score
                newScores.append(score)
                
                // the new score might be the max now
                if score > maxScore {
                    isHighScore = true
                    maxScore = score
                }
                
            } else if scores.count == 3 {
                
                // replace the highscore if score is higher
                if score > maxScore {
                    isHighScore = true
                    if let indexOfMax = scores.firstIndex(of: maxScore) {
                        newScores[indexOfMax] = score
                    }
                }
            }
            
            if let _ = try? self.userDefaults.setObject(newScores, forKey: self.keyFor(title, key: .SCORES)) {
                completion?(isHighScore, nil)
            } else {
                completion?(false, ServiceError.Failed)
            }
        }
    }
    
    
}


