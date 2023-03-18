//
//  LevelService.swift
//  dropper
//
//  Created by Andrew Tokeley on 12/03/23.
//

import Foundation

class LevelService {
    
    var levels = [Level]()
    
    lazy var tetrisClassic: [Level] = {
        for i in 0..<10 {
            var level = Level()
            level.number = i + 1
            levels.append(level)
        }
        return levels
    }()
    
    init(_ genre: GameType ) {
        if genre == .tetrisClassic {
            levels = self.tetrisClassic
        } else {
            levels = self.tetrisClassic
        }
    }
    
    func getLevel(_ level: Int) -> Level {
        guard level > 0 && level < levels.count else { return levels[0] }
        return levels[level-1]
    }
    
    func temp() {
        var levelNumber = 0
                
        levelNumber += 1
        var level = Level()
        level.number = levelNumber
        level.effects = [RemoveRowsEffect(), DropIntoEmptyRowsEffect()]
        level.goalDescription = "5 ROWS"
        level.goalValue = 5
        level.goalProgressValue = { a in
            return a.get(.oneRow) + a.get(.twoRows)*2 + a.get(.threeRows)*3
        }
        levels.append(level)
        
        levelNumber += 1
        level = Level()
        level.number = levelNumber
        level.effects = [RemoveMatchedBlocksEffect(minimumMatchCount: 10)]
        level.goalDescription = "100 COLOUR MATCHES"
        level.goalValue = 100
        level.goalProgressValue = { a in
            return a.get(.explodedBlock)
        }
        levels.append(level)
        
        levelNumber += 1
        level = Level()
        level.number = levelNumber
        level.effects = [RemoveRowsEffect(), DropIntoEmptyRowsEffect()]
        level.goalDescription = "4 DOUBLE ROWS"
        level.goalValue = 4
        level.goalProgressValue = { a in
            return a.sum([.twoRows, .threeRows])
        }
        levels.append(level)
        
        levelNumber += 1
        level = Level()
        level.number = levelNumber
        level.effects = [RemoveRowsEffect(), DropIntoEmptyRowsEffect()]
        level.goalDescription = "4 TRIPLE ROWS"
        level.goalValue = 4
        level.goalProgressValue = { a in
                return a.get(.threeRows)
        }
        levels.append(level)
        
        levelNumber += 1
        level = Level()
        level.effects = [RemoveMatchedBlocksEffect(minimumMatchCount: 10)]
        level.number = levelNumber
        level.goalDescription = "5 x 10-BLOCK MATCHES"
        level.goalValue = 5
        level.goalProgressValue = { a in
                return a.get(.match10)
        }
        levels.append(level)
        
        levelNumber += 1
        level = Level()
        level.effects = [RemoveMatchedBlocksEffect(minimumMatchCount: 20)]
        level.number = levelNumber
        level.goalDescription = "5 x 20-BLOCK MATCHES"
        level.goalValue = 5
        level.goalProgressValue = { a in
                return a.get(.match20)
        }
        levels.append(level)
    }
}
