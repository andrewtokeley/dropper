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
    func createGame(for title: GameTitle, completion: ((Game?) -> Void)?)
    
    func saveGameState(for title: GameTitle, state: GameState, completion: ((Error?)->Void)?)
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
    
    func getGameTitles(completion: (([GameTitle])->Void)?) {
        let dispatch = DispatchGroup()
        
        let gameTitles = [TetrisClassicTitle(), ColourMatcherTitle()]
        for title in gameTitles {
            dispatch.enter()
            getScoreHistory(for: title) { scores in
                title.highScore = scores.max() ?? 0
                dispatch.leave()
            }
        }
        dispatch.notify(queue: DispatchQueue.main, execute: {
            completion?(gameTitles)
        })
    }
    
    func createGame(for title: GameTitle, completion: ((Game?) -> Void)?) {
        if let _ = title as? TetrisClassicTitle {
            completion?(TetrisClassic())
        } else if let _ = title as? ColourMatcherTitle {
            completion?(ColourMatcherGame())
        }
    }
    
    // MARK: - State
    
    func saveGameState(for title: GameTitle, state: GameState, completion: ((Error?)->Void)?) {
        do {
            try userDefaults.setObject(state, forKey: keyFor(title, key: .STATE))
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


