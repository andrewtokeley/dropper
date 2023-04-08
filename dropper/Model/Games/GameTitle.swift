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
    var id: String = ""
    var title: String = ""
    var shortDescription = ""
    var highScore: Int = 0
    var gridRows: Int = 21
    var gridColumns: Int = 10
    var rootGameName: String?
    var accentColorAsHex: String?
    var gridHeroLayout = [[String]]()
    var gridHeroHighlight = [GridReference]()
    var isLastPlayed: Bool = false
    var lastPlayed: Date?
    
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


