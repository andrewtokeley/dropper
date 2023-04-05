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

/**
 This class should not be used directly and must be overriden with the specific rules and levels of a game.
 */
class Game {

    /**
     The grid on which the game is played
     */
    var grid: BlockGrid!

    /**
     The GameTitle that describes the game
     */
    var title: GameTitle
    
    /**
     Current score of a game
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
     Returns how many levels there are in the game
     */
    var maxLevels: Int = 10
    
    private var levelClass: Level.Type?
    
    /**
     An array containing the definitions of each level in the game.
     
     - Important: Game implementors must override ``getLevels()`` and the result will be returned by this lazy method.
     */
    lazy var levels = {
       return getLevels()
    }()
    
    /**
     Returns the levels for the game, must be overridden by Game subclasses.
     */
    func getLevels() -> [Level] {
        guard let levelClass = levelClass else { return [Level]() }
        
        var result = [Level]()
        for i in 0..<maxLevels {
            result.append(levelClass.init(i+1))
        }
        return result
    }
    
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
    
    required init() {
        fatalError("not implemented")
    }
    
    init(_ title: GameTitle, levelClass: Level.Type) {
        self.levelClass = levelClass
        self.title = title
        self.rows = title.gridRows
        self.columns = title.gridColumns
        self.grid = try! BlockGrid(rows: self.rows, columns: self.columns)
    }
    
    /**
     Set the level to be played, where 1 is the first level.
     
     This is typically used when restoring from saved state.
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
    func moveToNextLevel() -> Bool {
        guard levels.count > 0 else { return false }
        guard currentLevelIndex < (levels.count - 1) else { return false }
        
        self.currentLevelIndex += 1
        self.levelAchievements = Achievements.zero
        return true
    }
}
