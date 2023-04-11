//
//  Block.swift
//  dropper
//
//  Created by Andrew Tokeley on 19/02/23.
//

import Foundation
import UIKit


/**
 Represents a single block in the game.
 
 Blocks have a type that determines how they can interact with a game. If the type is .shape it is consider part of the active shape and will able to move, drop and rotate accordingly. Shapes of type .block can not be rotated or dropped. All shapes, regardless of type can be added, moved and removed.
 */
class Block: Codable {
    
    /// to support equality we create a unique id
    var id = UUID().uuidString
    
    /// Colour of block
    var colour: BlockColour!
    
    /// Determines whether the block appears semi-transparent
    var isGhost: Bool = false
    
    /// Type of block e.g. player, fixed, wall
    var type: BlockType!
    
    /// Determines whether a player block is the centre of rotation. This property is ignored for non-player blocks
    var isOrigin: Bool = false
    
    /// Code for the block, e.g. X2
    var code: String {
        return "\(type.rawValue)\(colour.rawValue)"
    }
    
    /// Initialise a new Block instance
    ///
    /// - Parameters:
    ///   - colour: BlockColour enum
    ///   - type: BlockType enum
    init(_ colour: BlockColour, _ type: BlockType, _ isGhost: Bool = false) {
        self.colour = colour
        self.type = type
        self.isGhost = isGhost
    }
    
}

extension Block: Equatable {
    static func == (left: Block, right: Block) -> Bool {
        return left.id == right.id
    }
}

