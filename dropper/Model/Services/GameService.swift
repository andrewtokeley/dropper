//
//  GameService.swift
//  dropper
//
//  Created by Andrew Tokeley on 21/03/23.
//

import Foundation

protocol GameServiceContract {
    
    func getSettings(completion: ((Settings) -> Void)?)
    func saveSettings(_ settings: Settings, completion: (()->Void)?)
    
    func getScoreHistory(completion: (([Int]) -> Void)?)
    func addScore(_ score: Int, completion: ((Bool) -> Void)?)
}

class GameService {

}

extension GameService: GameServiceContract {
    func getSettings(completion: ((Settings) -> Void)?) {
        completion?(Settings())
    }
    
    func saveSettings(_ settings: Settings, completion: (()->Void)?) {
        completion?()
    }
    
    func getScoreHistory(completion: (([Int]) -> Void)?) {
        completion?([1240,3132,2233])
    }
    
    func addScore(_ score: Int, completion: ((Bool) -> Void)?) {
        let isHighScore = true
        completion?(isHighScore)
    }
    
    
}


