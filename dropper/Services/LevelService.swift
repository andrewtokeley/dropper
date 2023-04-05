//
//  LevelService.swift
//  dropper
//
//  Created by Andrew Tokeley on 12/03/23.
//

import Foundation

protocol LevelServiceContract {
    func getLevelDefinitions(gameType: GameType, completion: (([Level]) -> Void)?)
}


class LevelService: ServiceBase {
    
    fileprivate var levels = [Level]()
    
    fileprivate lazy var tetrisClassic: [Level] = {
        for i in 0..<10 {
            var level = Level(i+1)
            levels.append(level)
        }
        return levels
    }()
}

extension LevelService: LevelServiceContract {
    
    func getLevelDefinitions(gameType: GameType, completion: (([Level]) -> Void)?) {
        
        if gameType == .tetrisClassic {
            completion?(tetrisClassic)
        } else {
            completion?([Level]())
        }
    }
}
