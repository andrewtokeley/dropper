//
//  BlockType.swift
//  dropper
//
//  Created by Andrew Tokeley on 9/04/23.
//

import Foundation


/**
 Enum for a block's type.
 
 Current types include;
 - **shape**: used for blocks that are part of the grid's active shape
 - **shapeOrigin**: used to identify the block, within the active shape, that is the origin of rotation
 - **block**: used for block standard coloured blocks in the grid
 - **medal**: used for a jewel block that contains special powers
 - **wall**: used to identify a wall block. Wall blocks are typically static and won't be affected by gravity effects.
 */
enum BlockType: String, Codable {
    /// Used for blocks that are part of the grid's active shape
    case shape = "S"
    /// Used to identify the block, within the active shape, that is the origin of rotation
    case shapeOrigin = "s"
    /// Used for block standard coloured blocks in the grid
    case block = "X"
    /// Used for a jewel block that contains special powers
    case jewel = "J"
    /// Used to identify a wall block. Wall blocks are typically static and won't be affected by gravity effects.
    case wall = "W"
    
//    /**
//     Returns a BlockType instance from a string representation.
//     
//     This is a shorthand way of identifying a block type when instantiating a grid using the initialiser, ``BlockGrid/init(_:)``.
//     
//     - X: block
//     - J: jewel
//     - W: wall
//     - S: shape
//     - s: shapeOrigin
//     */
//    static func from(_ string: String) -> BlockType? {
//        switch string {
//        case "X": return .block
//        case "J": return .jewel
//        case "W": return .wall
//        case "S": return .shape
//        case "s": return .shapeOrigin
//        default: return nil
//        }
//    }
    
    /**
     Debug description of the BlockType
     */
    var description: String {
        switch self {
        case .block: return "Block"
        case .jewel: return "Jewel"
        case .shape: return "Shape"
        case .shapeOrigin: return "ShapeOrigin"
        case .wall: return "Wall"
        }
    }
}
