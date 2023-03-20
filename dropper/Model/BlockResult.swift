//
//  BlockResult.swift
//  dropper
//
//  Created by Andrew Tokeley on 20/02/23.
//

import Foundation

/**
 Represents the result of a `Block` search
 
 The result can indicate one of three things.
 
 - There is a valid block at the grid reference (`BlockResult.block` will be non-nil and `BlockResult.isInsideGrid` will be `true`)
 - There is a space at the grid reference (`BlockResult.block` will be nil and `BlockResult.isInsideGrid` will be `true`)
 - The grid reference is outside the dimensions of the grid (`BlockResult.block` will be nil and `BlockResult.isInsideGrid` will be `false`)
 
 */
struct BlockResult {
    
    /// Block instance returned from a search function i.e. get(r, c), or adjacent()). Nil can indicate that a block at the requested reference doesn't exist (i.e. there's a space there) or that the requested location is outside the bounds of the grid. If the latter, the isInsideGrid flag will be set to false.
    var block: Block?
    
    /// Returns whether the grid location is inside the bounds of the grid
    var isInsideGrid: Bool
    
    /// The grid reference where the search was conducted
    var gridReference: GridReference
    
    /// Debug message
    var description: String {
        return "Colour: \(block?.colour.description ?? "nil"), Type: \(block?.type.description ?? "nil"), isInsideGrid: \(isInsideGrid), GridRef: \(gridReference.row), \(gridReference.column)."
    }
}
