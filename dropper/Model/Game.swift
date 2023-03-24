//
//  Game.swift
//  dropper
//
//  Created by Andrew Tokeley on 13/03/23.
//

import Foundation

enum GameType: Int, Codable {
    case tetrisClassic = 1
    case matcher
}

class Game {
    
    var levelService: LevelServiceContract
    
    var genre: GameType
    
    var rows: Int = 24
    var columns: Int = 10
    
    ///
    var levels = [Level]()
    
    /// Total score for the game
    var score: Int = 0
    
    /// Achievements (and points) gained for the current level
    var levelAchievements = Achievements()
    
    private var currentLevelIndex: Int
    
    var goalProgressValue: Int {
        return currentLevel?.goalProgressValue(levelAchievements) ?? 0
    }
    
    var currentLevel: Level? {
        guard currentLevelIndex >= 0 && currentLevelIndex < levels.count else { return nil }
        return levels[currentLevelIndex]
    }
    
    init(genre: GameType, levelService: LevelServiceContract, rows: Int, columns: Int) {
        self.currentLevelIndex = -1
        self.genre = genre
        self.levelService = levelService
        self.rows = rows
        self.columns = columns
    }
    
    func fetchLevels(completion: (()->Void)?) {
        levelService.getLevelDefinitions(gameType: genre, completion: { (levels) in
            self.currentLevelIndex = 0
            self.levels = levels
            completion?()
        })
    }
    
    func setLevel(_ level: Int) {
        guard level > 0 else { return }
        if level < levels.count {
            self.currentLevelIndex = level
        }
    }
    
    func moveToNextLevel() {
        self.currentLevelIndex += 1
    }
}
