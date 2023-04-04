//
//  ColourMatch.swift
//  dropper
//
//  Created by Andrew Tokeley on 3/04/23.
//

import Foundation

class ColourMatcherGame: Game {
    
    private func getLevels() -> [Level] {
        var result = [Level]()
        for i in 0..<10 {
            var level = Level()
            level.goalValue = 10
            level.goalUnit = "MATCHES"
            if i == 0 {
                level.goalDescription = "Colour match 10 groups of 15 or more blocks"
            } else {
                level.goalDescription = "You crushed it, keep matching those blocks!"
            }
            level.effects = [
                RemoveMatchedBlocksEffect(minimumMatchCount: 15)
                ]
            level.goalProgressValue = {(a: Achievements) -> Int in
                return a.get(.colourMatchGroup)
            }
            level.number = i + 1
            result.append(level)
        }
        return result
    }
    
    required init() {
        super.init(try! ColourMatcherTitle())
        self.levels = getLevels()
    }
    
}

class ColourMatcherTitle: GameTitle {
    override init() throws {
        try super.init()
        id = "TCM"
        title = "Matcher"
        gridRows = 21
        gridColumns = 10
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

