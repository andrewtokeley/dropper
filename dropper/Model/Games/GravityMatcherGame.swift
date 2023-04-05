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
    
//    required func getLevels() -> [Level] {
//        var levels = [GravityMatcherLevel]()
//        for i in 0..<maxLevels {
//            let level = GravityMatcherLevel(i+1)
//            levels.append(level)
//        }
//        return levels
//    }
    required init() {
        super.init(try! GravityMatcherTitle(), levelClass: GravityMatcherLevel.self)
    }
    
}

class GravityMatcherTitle: GameTitle {
    override init() throws {
        try super.init()
        id = "GMT"
        title = "Gravity Matcher"
        self.gridRows = 15
        self.gridColumns = 10
        self.accentColorAsHex = UIColor.gameBlock1.asHex()
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

