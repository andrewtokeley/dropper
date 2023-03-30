//
//  GameState.swift
//  dropper
//
//  Created by Andrew Tokeley on 22/03/23.
//

import Foundation

struct GameState: Codable {
    var blocks = [[Block?]]()
    var score: Int = 0
    var rows: Int = 0
    var columns: Int = 0
    var level: Int = 1
    var levelAchievements = Achievements()
    var title: GameTitle = TetrisClassicTitle()
    
    init(game: Game) {
        self.blocks = game.grid.blocksExcludingShape
        self.rows = game.rows
        self.score = game.score
        self.columns = game.columns
        self.level = game.currentLevel?.number ?? 1
        self.title = game.title
        self.levelAchievements = game.levelAchievements
    }
}
