//
//  GameTitle.swift
//  dropper
//
//  Created by Andrew Tokeley on 25/03/23.
//

import Foundation
import UIKit

enum GameTitleError: Error {
    case InvalidGameTitleClass
}
/**
 Represents a description of a game type, it's title and highscores
 */
class GameTitle: Codable {
    /**
     Unique identifier for a game, e.g. TET - this value won't be shown to the user
     */
    var id: String = ""
    
    /**
     Name for the game
     */
    var title: String = ""
    
    /**
     Short description of how to play the game.
     */
    var shortDescription = ""
    
    /**
     Individual highscore
     */
    var highScore: Int = 0
    
    /**
     Optional string to describe the highscore - for example, you could say "And you got 16 jewels!"
     */
    var highScoreDescription: String =  ""
    
    /**
     The number of rows in the game
     */
    var gridRows: Int = 21
    
    /**
     The number of columns in the game
     */
    var gridColumns: Int = 10
    
    /**
     The root name for the game's components.
     
     This property is set by the default initialiser, ``init()`` given the GameTitle subclass have a "Title" suffix. For example, the       ``TetrisClassicGame`` subclass results in a root name of "TetrisClassic" and the following family of classes that must exist.
     
     - ClassicTertrisLevel
     - ClassicTertrisGame
     */
    var rootGameName: String?
    
    /**
     The accent colour for the game - unused.
     */
    var accentColorAsHex: String?
    
    /**
     The layout to use of the home page's game tile
     */
    var gridHeroLayout = [[String]]()
    
    /**
     The tiles to highlight in the hero tile on the home view
     */
    var gridHeroHighlight = [GridReference]()
    
    /**
     The date/time the game was last played.
     */
    var lastPlayed: Date?
    
    /**
     Default initialiser for a GameTitle.
     
     If subclasses override this initialiser they must call this initialiser using ``super.init()``
     
     - Throws
        - ``GameTitleError/InvalidGameTitleClass`` - raised if the subclasses are not called with a Title prefix.
     */
    init() throws {
        
        let requiredSuffix = "Title"
        let components = String(describing: self).split(separator: ".")
        if let className = components.last {
            if !className.hasSuffix(requiredSuffix) {
                throw GameTitleError.InvalidGameTitleClass
            } else {
                if let indexOfTitle = className.index(of: requiredSuffix) {
                    rootGameName = className.prefix(upTo: indexOfTitle).description
                }
            }
        }
    }
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


