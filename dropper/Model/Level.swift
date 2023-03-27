//
//  Level.swift
//  dropper
//
//  Created by Andrew Tokeley on 12/03/23.
//

import Foundation

struct Level {
    
    /**
     The number of a level, where 1 is the first level going as high as possible.
     */
    var number: Int = 1 {
        didSet {
            if number <= 0 {
                number = 0
            }
        }
    }
    
    /**
     Returns the time a block takes to move on row
     */
    var moveDuration: TimeInterval {
        // slowest 0.3, fastest 0.05
        let speeds = [0.5, 0.4, 0.3, 0.2, 0.1, 0.08, 0.06]
        if self.number < 5 {
            return speeds[self.number-1]
        } else {
            // return fastest
            return speeds[speeds.count-1]
        }
    }
    
    // e.g. 100
    var goalValue: Int = 10
    
    /// Word describing the goal unit e.g. ROWS or MATCHES
    var goalUnit = ""
    
    // Sentence describing the goal
    var goalDescription: String = ""
    
    /// Instances of Levels must override this to calculate the progress made from Achievements
    var goalProgressValue: ((Achievements) -> Int) = { (a) in
        return 0
    }
    
    /// The effects that will be applied after each shape lands. Default is only removing rows.
    var effects = [RemoveRowsEffect(),
                 DropIntoEmptyRowsEffect()]
    
    // e.g. 20 / 100 Points
    func goalProgressDescription(_ achievements: Achievements) -> String {
        return "\(goalProgressValue(achievements)) \\ \(goalDescription)"
    }
    
    /// Returns whether the goal for the level has been achieved
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
        // for now just returning classic tetris shapes/colours
        let shapes = [
            Shape.L(.colour1),
            Shape.J(.colour2),
            Shape.S(.colour3),
            Shape.O(.colour4),
            Shape.Z(.colour5),
            Shape.I(.colour6)
        ]
        if let shape = shapes.randomElement() {
            return shape
        } else {
            return shapes[0]
        }
    }
}
