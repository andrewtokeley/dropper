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
    
    required init(_ levelNumber: Int) {
        self.number = levelNumber
    }
    
    /**
     The number of a level, where 1 is the first level.
     */
    var number: Int {
        didSet {
            if number <= 0 {
                number = 1
            }
        }
    }
    
    /**
     Returns the time a block takes to move on row. This can't be changed.
     */
    var moveDuration: TimeInterval {
        let speeds = [0.5, 0.4, 0.3, 0.2, 0.15]
        if self.number <= 5 {
            return speeds[self.number-1]
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
     Sentence describing the goal. The default is ""
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
     Returns the points awarded for the given achievements
    
     - 100*levei points for each single row
     - 300*level* poiints for each double row
     - 500*level points for each triple row
     - 800*level points for each quad row
     
     - 300 points for each colour matched block * level + 100 points for each block over the block count
     */
    func pointsFor(_ achievements: Achievements, hardDrop: Bool = false) -> Int {
        var points = 0

        let blockPoint = hardDrop ? 2 : 1
        
        // these are Tetris Clasic points
        points += achievements.get(.oneRow) * 100 * number
        points += achievements.get(.twoRows) * 300 * number
        points += achievements.get(.threeRows) * 500 * number
        points += achievements.get(.fourRows) * 800 * number
        points += achievements.get(.explodedBlock) * blockPoint
        
        // Matcher points
        // e.g. if the goal was to match 15 blocks of the same colour,
        // and they match 20, then they get 300 base points + 20-15=5 * 100 extra points
        let numberOfBlocksMatched = achievements.get(.colourMatch)
        let numberOfMatches = numberOfBlocksMatched/15
        let numberOfExtraBlocks = numberOfBlocksMatched - numberOfMatches * 15
        points += (300 * numberOfMatches + numberOfExtraBlocks * 100)
        
        return points
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
}
