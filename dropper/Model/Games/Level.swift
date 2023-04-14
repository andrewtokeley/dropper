//
//  Level.swift
//  dropper
//
//  Created by Andrew Tokeley on 12/03/23.
//

import Foundation

/**
 The Level class defines the rules of a level in a Game.

 While ``Game`` implementations are responsible for creating instances of this type, they should not do so directly, but rather create instances of Level subclasses specific to their game. By convention these classes are named [GameName]Level, for example, ``TetrisClassicLevel``.
 */
class Level {
    
    /**
     Initialise a new level. 1 is the first level.
     */
    required init(_ levelNumber: Int) {
        self.levelNumber = levelNumber
    }
    
    /**
     The number of a level, where 1 is the first level.
     */
    var levelNumber: Int {
        didSet {
            if levelNumber <= 0 {
                levelNumber = 1
            }
        }
    }
    
    /**
     Returns the time it takes for the active shape to move down one row. By default the speed increases after each level, up to a maximum speed.
     */
    var shapeMoveDuration: TimeInterval {
        let speeds = [0.5, 0.4, 0.3, 0.2, 0.15]
        if self.levelNumber <= 5 {
            return speeds[self.levelNumber-1]
        } else {
            // keep returning fastest
            return speeds[speeds.count-1]
        }
    }
    
    /**
     The goal value you need to achieve to complete the level. For example, this might be the number of rows to compete. The default is 10.
     */
    var goalValue: Int = 10
    
    /**
     The word describing the goal unit e.g. ROWS or MATCHES. The default is ""
     */
    var goalUnit = ""
    
    /**
     Sentence describing the goal.
     
     The goalDescription is displayed to the user at the beginning of each level. Game level subclasses should override this to provide meaningful descriptions.
     */
    var goalDescription: String = ""
    
    /**
     Instances of Levels must override this to calculate the progress based on the Achievements have been made so far.
     */
    var goalProgressValue: ((Achievements) -> Int) = { (a) in
        return 0
    }
    
    /**
     The effects that will be applied after each shape lands. Default is only removing rows
     */
    var effects: [GridEffect] = [RemoveRowsEffect()]
    
    /**
     A description of the progess made, e.g. 2 /10 ROWS.
     */
    func goalProgressDescription(_ achievements: Achievements) -> String {
        return "\(goalProgressValue(achievements)) \\ \(goalDescription)"
    }
    
    /**
     Returns whether the goal for the level has been achieved
     */
    func goalAchieved(_ achievements: Achievements) -> Bool {
        return goalProgressValue(achievements) >= goalValue
    }
    
    /**
     Returns the number of points collected for given achievements. This method should be overriden by each game subclass.
     */
    func pointsFor(moveAchievements: Achievements, levelAchievements: Achievements? = nil, hardDrop: Bool = false) -> Int {
        return 0
    }
    
    /**
     Returns a random shape
     */
    func nextShape() -> Shape {
        let shape = Shape.random()
        if shape.name == "O" {
            shape.canBeRotated = false
        }
        return shape
    }
    
    /**
     Some games have levels that start with some blocks on the grid, override this method to return the blocks and their initial positions.
     */
    var initialBlocks: ([Block], [GridReference])? {
        return nil
    }
    
}
