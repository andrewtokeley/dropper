//
//  GameTitle.swift
//  dropper
//
//  Created by Andrew Tokeley on 25/03/23.
//

import Foundation

/**
 Represents a description of a game type, it's title and highscores
 */
class GameTitle: Codable {
    var id: String = ""
    var title: String = ""
    var highScore: Int = 0
}

extension GameTitle: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension GameTitle: Equatable {
    static func == (lhs: GameTitle, rhs: GameTitle) -> Bool {
        return lhs.id == rhs.id
    }
}

class TetrisClassicTitle: GameTitle {
    override init() {
        super.init()
        id = "TTC"
        title = "Classic"
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

class ColourMatcherTitle: GameTitle {
    override init() {
        super.init()
        id = "TCM"
        title = "Matcher"
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

