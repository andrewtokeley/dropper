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
            ["  ", "  ", "X3", "X3", "X2", "X3", "  "],
            ["  ", "  ", "  ", "  ", "X1", "  ", "  "],
            ["  ", "  ", "  ", "X3", "X1", "  ", "X3"],
            ["  ", "  ", "  ", "X3", "X3", "X3", "X3"],
        ]
        gridHeroHighlight = [
            GridReference(0, 2),
            GridReference(0, 3),
            GridReference(0, 4),
            GridReference(0, 5),
            GridReference(0, 6),
            GridReference(1, 3),
            GridReference(1, 5),
            GridReference(1, 6),
            GridReference(2, 3),
        ]
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

class GravityMatcherLevel: Level {
    
    required init(_ levelNumber: Int) {
        super.init(levelNumber)
        
        goalValue = 10
        goalUnit = "MATCHES"
        goalDescription = "Match 10 colour groups to complete each level"
        effects = [GravityEffect(), RemoveMatchedBlocksEffect(minimumMatchCount: 10)]
        goalProgressValue = { (a) in
            a.get(.colourMatchGroup)
        }
    }
    
    override func nextShape() -> Shape {
        let shape = Shape.random(2)
        if shape.name == "O" {
            shape.canBeRotated = true
        }
        return shape
    }
}

