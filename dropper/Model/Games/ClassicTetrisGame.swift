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
        
        if levelNumber == 0 {
            goalDescription = "Match 10 rows to move to the next level."
        } else {
            goalDescription = "Keep it up, things are getting faster"
        }
        effects = [RemoveRowsEffect(), DropIntoEmptyRowsEffect()]
        goalProgressValue = {(a: Achievements) -> Int in
            return a.get(.oneRow) + a.get(.twoRows)*2 + a.get(.threeRows)*3 + a.get(.fourRows)*4
        }
    }
    
    override func nextShape() -> Shape {
        let shape = Shape.random()
        if shape.name == "O" {
            shape.canBeRotated = false
        }
        return shape
    }
}
