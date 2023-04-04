//
//  ClassicTetris.swift
//  dropper
//
//  Created by Andrew Tokeley on 3/04/23.
//

import Foundation

class TetrisClassicGame: Game {
    
    private lazy var tetrisClassic: [Level] = {
        for i in 0..<10 {
            var level = Level()
            level.number = i + 1
            level.goalUnit = "ROWS"
            if i == 0 {
                level.goalDescription = "Match 10 rows to move to the next level."
            } else {
                level.goalDescription = "Keep it up, things are getting faster"
            }
            level.effects = [RemoveRowsEffect(), DropIntoEmptyRowsEffect()]
            level.goalProgressValue = {(a: Achievements) -> Int in
                return a.get(.oneRow) + a.get(.twoRows)*2 + a.get(.threeRows)*3 + a.get(.fourRows)*4
            }
            
            levels.append(level)
        }
        return levels
    }()
    
    required init() {
        super.init(try! TetrisClassicTitle())
        self.rows = 21
        self.columns = 10
        self.levels = tetrisClassic
    }
    
}

class TetrisClassicTitle: GameTitle {
    
    override init() throws {
        try super.init()
        id = "TTC"
        title = "Classic Tetris"
        gridRows = 21
        gridColumns = 10
        
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
