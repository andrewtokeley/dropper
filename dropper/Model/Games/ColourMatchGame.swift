//
//  ColourMatch.swift
//  dropper
//
//  Created by Andrew Tokeley on 3/04/23.
//

import Foundation
import UIKit

// MARK: - Game

class ColourMatcherGame: Game {
    required init() {
        super.init(try! ColourMatcherTitle(), levelClass: ColourMatcherLevel.self)
    }
}

// MARK: - Title

class ColourMatcherTitle: GameTitle {
    override init() throws {
        try super.init()
        id = "TCM"
        title = "Matcher"
        shortDescription = "Match connected blocks of the same colour"
        gridRows = 21
        gridColumns = 10
        accentColorAsHex = UIColor.gameBackground.asHex()
        gridHeroLayout = [
            ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ["  ", "X4", "X2", "X3", "X1", "X1", "X1"],
            ["  ", "  ", "  ", "X1", "X1", "X2", "X1"],
            ["  ", "  ", "  ", "X1", "X1", "X2", "X1"],
            ["  ", "  ", "X5", "X4", "X4", "  ", "X1"],
        ]
        gridHeroHighlight = [
            GridReference(0, 6),
            GridReference(1, 3),
            GridReference(1, 4),
            GridReference(1, 6),
            GridReference(2, 3),
            GridReference(2, 4),
            GridReference(2, 6),
            GridReference(3, 4),
            GridReference(3, 5),
            GridReference(3, 6)
        ]
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

// MARK: - Level

class ColourMatcherLevel: Level {
    
    required init(_ levelNumber: Int) {
        super.init(levelNumber)
        
        goalValue = 10
        goalUnit = "MATCHES"
        if levelNumber == 0 {
            goalDescription = "Colour match 10 groups of 15 or more blocks"
        } else {
            goalDescription = "You crushed it, keep matching those blocks!"
        }
        effects = [
            RemoveMatchedBlocksEffect(minimumMatchCount: 15)
            ]
        goalProgressValue = {(a: Achievements) -> Int in
            return a.get(.colourMatchGroup)
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
