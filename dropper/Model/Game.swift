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
    
    /**
     Current score for the game
     */
    var score = 0
    
    /**
     How many rows are in the game
     */
    var rows: Int = 24
    
    /**
     How many columns are in the game
     */
    var columns: Int = 10
    
    /**
     An array containing the definitions of each level in the game.
     
     This property must be set by Game classes that inherit from this base class.
     */
    var levels = [Level]()
    
    /**
     Variable to track the current level being played.
     */
    private var currentLevelIndex = 0
    
    /**
     Combined achievements gained for the current level
     */
    var levelAchievements = Achievements.zero
    
    /**
     The progress made towards a goal.
     
     For example, if playing TetrisClassic, the goal may be 10 rows and the goalProgressValue might by 5, meaning you're half way there!
     */
    var goalProgressValue: Int {
        return currentLevel?.goalProgressValue(levelAchievements) ?? 0
    }
    
    /**
     Set the level to be played by it's zero based index.
     */
    func setLevel(_ levelIndex: Int) {
        guard levelIndex >= 0 && levelIndex < levels.count else { return }
        self.currentLevelIndex = levelIndex
    }
    
    /**
     Active level being played
     */
    var currentLevel: Level? {
        guard currentLevelIndex >= 0 && currentLevelIndex < levels.count else { return nil }
        return levels[currentLevelIndex]
    }
    
    /**
     Move the game to the next level
     */
    func moveToNextLevel() {
        guard levels.count > 0 else { return }
        guard currentLevelIndex < (levels.count - 1) else { return }
        
        self.currentLevelIndex += 1
        self.levelAchievements = Achievements.zero
    }
}

class TetrisClassic: Game {
    
    private lazy var tetrisClassic: [Level] = {
        for i in 0..<10 {
            var level = Level()
            level.number = i + 1
            levels.append(level)
        }
        return levels
    }()
    
    override init() {
        super.init()
        self.rows = 21
        self.columns = 10
        self.levels = tetrisClassic
    }
    
}
