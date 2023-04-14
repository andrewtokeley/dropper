//
//  JewelGame.swift
//  dropper
//
//  Created by Andrew Tokeley on 8/04/23.
//

import Foundation
import UIKit

// MARK: - Game

class JewelGame: Game {
    required init() {
        super.init(try! JewelTitle(), levelClass: JewelLevel.self)
    }
    
}

// MARK: - Title

class JewelTitle: GameTitle {
    
    override init() throws {
        try super.init()
        id = "JEW"
        title = "Jewel"
        shortDescription = "Collect jewels"
        gridRows = 21
        gridColumns = 10
        accentColorAsHex = UIColor.gameBackground.asHex()
        gridHeroLayout = [
            ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ["  ", "  ", "  ", "J2", "  ", "  ", "  "],
            ["  ", "J1", "  ", "  ", "  ", "  ", "  "],
            ["  ", "  ", "  ", "  ", "  ", "J1", "  "],
            ["X1", "X2", "J2", "X4", "X2", "X2", "X2"],
        ]
        gridHeroHighlight = try! GridRange(start: GridReference(0,0), end: GridReference(0,6)).references
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

// MARK: - Level

class JewelLevel: Level {
    
    required init(_ levelNumber: Int) {
        super.init(levelNumber)
        
        let numberOfJewels = levelNumber
        
        goalUnit = "JEWELS"
        goalValue = numberOfJewels
        
        if levelNumber == 1 {
            goalDescription = "Collect all the jewels by filling their rows with blocks."
        } else {
            goalDescription = "Keep it up! More jewels are coming."
        }
        effects = [RemoveRowsEffect(), DropIntoEmptyRowsEffect()]
        goalProgressValue = {(a: Achievements) -> Int in
            return a.get(.jewel)
        }
    }
    
    /**
     In Jewel for each drop/land of a shape (move) you can get;
     
     - 500 points for first jewel, 1000 for second jewel, 1500 for third... times by the level
     - and if you get one of more jewels in a move, you get a bonus if it took less than 10 removed rows to get there. Max 1000, reduced by the average number of rows removed per jewel
     */
    override func pointsFor(moveAchievements: Achievements, levelAchievements: Achievements? = nil, hardDrop: Bool = false) -> Int {
        
        var points = 0
        
        // 500 points for first jewel, 1000 for second jewel, 1500 for third... times by the level
        let j = moveAchievements.get(.jewel)
        points += (500 * j * (j + 1) / 2) * levelNumber
        
        // BONUS?
        if points > 0 {
            
            if let levelAchievements = levelAchievements {
                // we remove the rows used to catch each jewel, not perfect because you could have removed more than one row to get it, but hey.
                let jewelsSoFar = levelAchievements.get(.jewel)
                let totalRowsRemoved = levelAchievements.totalRowsRemoved - jewelsSoFar
                let averageRowsRemovedPerJewel = (jewelsSoFar == 0 ? totalRowsRemoved : totalRowsRemoved/jewelsSoFar)
                
                var bonusReduceBy = (averageRowsRemovedPerJewel) * 100
                if bonusReduceBy > 1000 {
                    bonusReduceBy = 1000
                }
                points += 1000 - bonusReduceBy
            }
        }
        
        return points
        
    }
    
    override var shapeMoveDuration: TimeInterval {
        // for this game it gets harder because there are more jewels to collect so we don't want to make the game speed up
        return 0.4
    }
    
    /**
     Add the same number of jewels as goalValue
     */
    override var initialBlocks: ([Block], [GridReference])? {
        var blocks = [Block]()
        var references = [GridReference]()
        for _ in 0..<goalValue {
            blocks.append(Block(.random, .jewel))
            references.append(GridReference(Int.random(in: 0..<10), Int.random(in: 0..<10)))
        }
        return (blocks, references)
    }

    
    override func nextShape() -> Shape {
        let shape = Shape.random()
        if shape.name == "O" {
            shape.canBeRotated = false
        }
        return shape
    }
}
