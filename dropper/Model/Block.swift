//
//  Block.swift
//  dropper
//
//  Created by Andrew Tokeley on 19/02/23.
//

import Foundation
import UIKit

/// Enumerated value for each visual type of block
enum BlockType: Int {
    /// The block is part of the player's shape
    case player = 0
    /// The block is a standard block in the grid and will be affected by gravity
    case block
    /// This is a wall block that can float in the grid and won't ever drop
    case wall
    
    var description: String {
        switch self {
        case .block: return "Block"
        case .player: return "Player"
        case .wall: return "Wall"
        }
    }
}

/// Enumerated value for each visual type of block
enum BlockColour: Int {
    
    case yellow = 0
    case red
    case blue
    case orange
    case ground
    
    static var random: BlockColour {
        return BlockColour(rawValue: Int.random(in: 0..<4)) ?? .blue
    }
    
    var description: String {
        switch self {
        case .orange: return "Orange"
        case .yellow: return "Yellow"
        case .red: return "Red"
        case .blue: return "Blue"
        case .ground: return "Ground"
        }
    }
}

/**
 Represents a single block in the game. Blocks can be marked as fixed or dynamic, if dynamic they will move within a BlockGrid if a
 move command is issued
 */
class Block {
    let id = UUID().uuidString
    
    /// Colour of block
    var colour: BlockColour!
    
    /// Type of block e.g. player, fixed, wall
    var type: BlockType!
    
    /// Determines whether a player block is the centre of rotation. This property is ignored for non-player blocks
    var isOrigin: Bool = false
    
    /// Initialise a new Block instance
    ///
    /// - Parameters:
    ///   - colour: BlockColour enum
    ///   - type: BlockType enum
    init(_ colour: BlockColour, _ type: BlockType) {
        self.colour = colour
        self.type = type
    }
}

extension Block: Equatable {
    static func == (left: Block, right: Block) -> Bool {
        return left.id == right.id
    }
}

