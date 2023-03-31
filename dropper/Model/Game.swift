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
    
    var grid: BlockGrid!
    
    var title: GameTitle
    
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
    
    init(_ title: GameTitle) {
        self.title = title
        self.rows = title.gridRows
        self.columns = title.gridColumns
        self.grid = try! BlockGrid(rows: self.rows, columns: self.columns)
    }
    
    /**
     Set the level to be played, where 1 is the first level.
     */
    func setLevel(_ level: Int) {
        guard level > 0 && level <= levels.count else { return }
        self.currentLevelIndex = level - 1
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
            level.goalUnit = "ROWS"
            if i == 0 {
                level.goalDescription = "Match 10 rows to move to the next level."
            } else {
                level.goalDescription = "Keep it up, things are getting faster"
            }
            
            level.goalProgressValue = {(a: Achievements) -> Int in
                return a.get(.oneRow) + a.get(.twoRows)*2 + a.get(.threeRows)*3 + a.get(.fourRows)*4
            }
                
            levels.append(level)
        }
        return levels
    }()
    
    init() {
        super.init(TetrisClassicTitle())
        self.rows = 21
        self.columns = 10
        self.levels = tetrisClassic
        
    }
    
}

class ColourMatcherGame: Game {
    
    private func getLevels() -> [Level] {
        var result = [Level]()
        for i in 0..<10 {
            var level = Level()
            level.goalValue = 10
            level.goalUnit = "MATCHES"
            if i == 0 {
                level.goalDescription = "Colour match 10 groups of 15 or more blocks"
            } else {
                level.goalDescription = "You crushed it, keep matching those blocks!"
            }
            level.effects = [
                RemoveMatchedBlocksEffect(minimumMatchCount: 15)
                ]
            level.goalProgressValue = {(a: Achievements) -> Int in
                return a.get(.colourMatchGroup)
            }
            level.number = i + 1
            result.append(level)
        }
        return result
    }
    
    init() {
        super.init(ColourMatcherTitle())
        self.rows = 21
        self.columns = 10
        self.levels = getLevels()
    }
    
}
