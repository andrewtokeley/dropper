//
//  TestGame.swift
//  dropper
//
//  Created by Andrew Tokeley on 3/04/23.
//

import Foundation
import UIKit

/**
 GravityMatcher
 */
class GravityMatcherGame: Game {
    required init() {
        super.init(try! GravityMatcherTitle(), levelClass: GravityMatcherLevel.self)
    }
}

class GravityMatcherTitle: GameTitle {
    override init() throws {
        try super.init()
        id = "GMT"
        title = "Gravity Matcher"
        shortDescription = "Same as Matcher but with gravity!"
        self.gridRows = 15
        self.gridColumns = 10
        accentColorAsHex = UIColor.gameBackground.asHex()
        gridHeroLayout = [
            ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ["  ", "X3", "X3", "X2", "X3", "  ", "  "],
            ["  ", "  ", "  ", "X1", "  ", "  ", "  "],
            ["  ", "  ", "X3", "X1", "  ", "X3", "  "],
            ["  ", "  ", "X3", "X3", "X3", "X3", "  "]
        ]
        gridHeroHighlight = [
            GridReference(0, 1),
            GridReference(0, 2),
            GridReference(0, 3),
            GridReference(0, 4),
            GridReference(0, 5),
            GridReference(1, 2),
            GridReference(1, 4),
            GridReference(1, 5),
            GridReference(2, 2),
        ]
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

/**
 Gravity Matcher game has the same level definitions as ColourMatcher but applies gravity and spawns new shapes with up to 2 colours.
 */
class GravityMatcherLevel: ColourMatcherLevel {
    
    required init(_ levelNumber: Int) {
        super.init(levelNumber)
        
        if levelNumber == 1 {
            goalDescription = "Match groups of 10 colours."
        } else {
            goalDescription = "Keep it up! Things are getting faster."
        }
        
        effects = [
            RemoveMatchedBlocksEffect(minimumMatchCount: 10),
            GravityEffect()
            ]
    }
    
    override func nextShape() -> Shape {
        let shape = Shape.random(2)
        if shape.name == "O" {
            shape.canBeRotated = true
        }
        return shape
    }
}

