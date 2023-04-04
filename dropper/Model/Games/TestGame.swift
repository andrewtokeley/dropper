//
//  TestGame.swift
//  dropper
//
//  Created by Andrew Tokeley on 3/04/23.
//

import Foundation

/**
 Test game where there are only two levels and you only need one row per level
 */
class TestGame: Game {
    
    private func getLevels() -> [Level] {
        var levels = [TestLevel]()
        for i in 0..<2 {
            let level = TestLevel()
            level.number = i + 1
            level.goalValue = 1
            level.goalUnit = "ROWS"
            level.effects = [GravityEffect(), RemoveMatchedBlocksEffect(minimumMatchCount: 10)]
            level.goalProgressValue = { (a) in
                a.get(.oneRow)
            }
            
            levels.append(level)
            
        }
        return levels
    }
    
    required init() {
        super.init(try! TestTitle())
        self.levels = getLevels()
    }
    
}

class TestTitle: GameTitle {
    override init() throws {
        try super.init()
        id = "TEST"
        title = "Test Game"
        self.gridRows = 20
        self.gridColumns = 10
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

class TestLevel: Level {
    override func nextShape() -> Shape {
        let shape = Shape.random(2)
        if shape.name == "O" {
            shape.canBeRotated = true
        }
        return shape
    }
}

