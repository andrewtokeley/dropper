//
//  GameService.swift
//  dropper
//
//  Created by Andrew Tokeley on 21/03/23.
//

import Foundation

protocol GameServiceContract {
    
    /**
     Creats a new game instance for the given game type
     */
    func createGame(_ genre: GameType, completion: ((Game?) -> Void)?)
    
    func saveGameState(_ state: GameState, completion: ((Error?)->Void)?)
    func getGameState(completion: ((GameState?)->Void)?)
    func clearGameState(completion: ((Bool)->Void)?)
    
    func getSettings(completion: ((Settings?) -> Void)?)
    func saveSettings(_ settings: Settings, completion: (()->Void)?)
    func clearSettingsState(completion: ((Bool)->Void)?)
    
    func getScoreHistory(completion: (([Int]) -> Void)?)
    func addScore(_ score: Int, completion: ((Bool?, ServiceError?) -> Void)?)
    func clearScoreState(completion: ((Bool)->Void)?)
}

class GameService: ServiceBase {
    var SETTINGS_KEY: String {
        return KEY_PREFIX + "dropper_settings"
    }
    var SCORES_KEY: String {
        return KEY_PREFIX + "dropper_scores"
    }
    var STATE_KEY: String {
        return KEY_PREFIX + "dropper_state"
    }
    let userDefaults = UserDefaults.standard
}

extension GameService: GameServiceContract {
    
    // MARK: - Game
    func createGame(_ genre: GameType, completion: ((Game?) -> Void)?) {
        guard genre == .tetrisClassic else {
            completion?(nil)
            return
        }
        
        var game = Game(genre: genre,
                        levelService: ServiceFactory.sharedInstance.levelService,
                        rows: 22,
                        columns: 10)
        game.fetchLevels {
            completion?(game)
        }
    }
    
    // MARK: - State
    
    func saveGameState(_ state: GameState, completion: ((Error?)->Void)?) {
        do {
            try userDefaults.setObject(state, forKey: STATE_KEY)
            completion?(nil)
        } catch let error {
            completion?(error)
        }
    }
    
    func getGameState(completion: ((GameState?)->Void)?) {
        let state = try? userDefaults.getObject(forKey: STATE_KEY, castTo: GameState.self)
        completion?(state)
    }
    
    func clearGameState(completion: ((Bool)->Void)?) {
        userDefaults.removeObject(forKey: STATE_KEY)
        completion?(true)
    }
    
    // MARK: - Settings
    
    func getSettings(completion: ((Settings?) -> Void)?) {
        let settings = try? userDefaults.getObject(forKey: SETTINGS_KEY, castTo: Settings.self)
        completion?(settings)
    }
    
    func saveSettings(_ settings: Settings, completion: (()->Void)?) {
        if let _ = try? userDefaults.setObject(settings, forKey: SETTINGS_KEY) {
            completion?()
        }
    }
    
    func clearSettingsState(completion: ((Bool)->Void)?) {
        userDefaults.removeObject(forKey: SETTINGS_KEY)
        completion?(true)
    }
    
    //MARK: - Scores
    
    func getScoreHistory(completion: (([Int]) -> Void)?) {
        if let scores = try? userDefaults.getObject(forKey: SCORES_KEY, castTo: Array<Int>.self) {
            completion?(scores)
        } else {
            completion?([])
        }
    }

    func clearScoreState(completion: ((Bool)->Void)?) {
        userDefaults.removeObject(forKey: SCORES_KEY)
        completion?(true)
    }
    
    func addScore(_ score: Int, completion: ((Bool?, ServiceError?) -> Void)?) {
        self.getScoreHistory { scores in
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
            
            if let _ = try? self.userDefaults.setObject(newScores, forKey: self.SCORES_KEY) {
                completion?(isHighScore, nil)
            } else {
                completion?(false, ServiceError.Failed)
            }
        }
    }
    
    
}


