//
//  Block.swift
//  dropper
//
//  Created by Andrew Tokeley on 19/02/23.
//

import Foundation
import UIKit

/// Enumerated value for each visual type of block
enum BlockType: Int, Codable {
    /// The block is part of the grid's active shape
    case shape = 0
    /// The block is a standard block in the grid
    case block
    /// This is a wall block. Not current used.
    case wall
    
    /**
     Debug description of the BlockType
     */
    var description: String {
        switch self {
        case .block: return "Block"
        case .shape: return "Player"
        case .wall: return "Wall"
        }
    }
}

/// Enumerated value for each visual type of block
enum BlockColour: Int, Codable {
    
    case colour1 = 0
    case colour2
    case colour3
    case colour4
    case colour5
    case colour6
    
    static var random: BlockColour {
        return BlockColour(rawValue: Int.random(in: 0..<5)) ?? .colour4
    }
    
    static func randomSet(_ count: Int) -> [BlockColour] {
        var result = [BlockColour]()
        for _ in 0..<count {
            result.append(BlockColour.random)
        }
        return result
    }
    
    /// Debug info
    var description: String {
        switch self {
        case .colour1: return "Colour1"
        case .colour2: return "Colour2"
        case .colour3: return "Colour3"
        case .colour4: return "Colour4"
        case .colour5: return "Colour5"
        case .colour6: return "Colour6"
        }
    }
}

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

