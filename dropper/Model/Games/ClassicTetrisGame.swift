//
//  ClassicTetris.swift
//  dropper
//
//  Created by Andrew Tokeley on 3/04/23.
//

import Foundation
import UIKit

// MARK: - Game

class TetrisClassicGame: Game {
    required init() {
        super.init(try! TetrisClassicTitle(), levelClass: TetrisClassicLevel.self)
    }
    
}

// MARK: - Title

class TetrisClassicTitle: GameTitle {
    
    override init() throws {
        try super.init()
        id = "TTC"
        title = "Classic Tetris"
        shortDescription = "Complete rows of blocks"
        gridRows = 21
        gridColumns = 10
        accentColorAsHex = UIColor.gameBackground.asHex()
        gridHeroLayout = [
            ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ["  ", "  ", "X4", "  ", "  ", "  ", "  "],
            ["  ", "  ", "X3", "  ", "  ", "  ", "  "],
            ["X2", "X2", "X1", "X4", "  ", "X1", "  "],
            ["X1", "X2", "X2", "X2", "X4", "X2", "X2"],
        ]
        gridHeroHighlight = try! GridRange(start: GridReference(0,0), end: GridReference(0,6)).references
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

// MARK: - Level

class TetrisClassicLevel: Level {
    
    required init(_ levelNumber: Int) {
        super.init(levelNumber)
        
        goalUnit = "ROWS"
        goalValue = 10
        
        if levelNumber == 1 {
            goalDescription = "Match 10 rows to move to the next level."
        } else {
            goalDescription = "Keep it up, things are getting faster"
        }
        effects = [RemoveRowsEffect(), DropIntoEmptyRowsEffect()]
        goalProgressValue = {(a: Achievements) -> Int in
            return a.get(.oneRow) + a.get(.twoRows)*2 + a.get(.threeRows)*3 + a.get(.fourRows)*4
        }
    }
    
    /**
     Returns the points awarded based on the current move's achievements
     
     - Parameters:
        - moveAchievements: the achievements made in the last move (shape drop)
        - levelAchievements: the combined achievements for the level so far (optional) - this isn't used by all games.
        
    The default points are;
     
     - 100*levei points for each single row
     - 300*level* poiints for each double row
     - 500*level points for each triple row
     - 800*level points for each quad row
     */
    override func pointsFor(moveAchievements: Achievements, levelAchievements: Achievements? = nil, hardDrop: Bool = false) -> Int {
        var points = 0

        let blockPoint = hardDrop ? 2 : 1
        
        points += moveAchievements.get(.oneRow) * 100 * levelNumber
        points += moveAchievements.get(.twoRows) * 300 * levelNumber
        points += moveAchievements.get(.threeRows) * 500 * levelNumber
        points += moveAchievements.get(.fourRows) * 800 * levelNumber
        points += moveAchievements.get(.explodedBlock) * blockPoint
        
        return points
    }
    
    override func nextShape() -> Shape {
        let shape = Shape.random()
        if shape.name == "O" {
            shape.canBeRotated = false
        }
        return shape
    }
}
