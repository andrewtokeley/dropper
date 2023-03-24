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
    var genre: GameType = .tetrisClassic
}
