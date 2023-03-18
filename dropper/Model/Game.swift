//
//  Game.swift
//  dropper
//
//  Created by Andrew Tokeley on 13/03/23.
//

import Foundation

enum GameType: Int {
    case tetrisClassic = 1
    case matcher
}

class Game {
    
    var service: LevelService
    
    /// Total score for the game
    var score: Int = 0
    
    /// Achievements (and points) gained for the current level
    var levelAchievements = Achievements()
    
    private var currentLevelIndex: Int
    private var levels: [Level]
    
    var currentLevel: Level {
        return levels[currentLevelIndex]
    }
    
    init(genre: GameType) {
        self.service = LevelService(genre)
        self.currentLevelIndex = 0
        self.levels = self.service.levels
    }
    
    func moveToNextLevel() {
        if currentLevelIndex < levels.count {
            currentLevelIndex += 1
        }
    }
}
