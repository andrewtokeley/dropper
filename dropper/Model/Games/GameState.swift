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
    var rows: Int {
        return blocks.count
    }
    var columns: Int {
        return blocks[0].count
    }
    var level: Int = 1
    var gameAchievements = Achievements.zero
    var levelAchievements = Achievements.zero
    var title: GameTitle!
    
    init(game: Game) {
        self.blocks = game.grid.blocksExcludingShape
        self.score = game.score
        self.level = game.currentLevel?.levelNumber ?? 1
        self.title = game.title
        self.levelAchievements = game.levelAchievements
        self.gameAchievements = game.gameAchievements
    }
}
