//
//  BlockResult.swift
//  dropper
//
//  Created by Andrew Tokeley on 20/02/23.
//

import Foundation

/**
 Represents the result of a `Block` search.
 
 This struct is used as a return type to search functions like ``BlockGrid/get(_:)-z5vy`` or ``BlockGrid/adjacent(_:)`` where the result is more complex than simply returning a ``Block`` or not. The result will also indicate whether the location being search is within the grid bounds.
 */
struct BlockResult {
    
    /**
     The block that exists at the gridReference, or nil if no block exists.
     */
    var block: Block?
    
    /**
     Returns whether the grid location is inside the bounds of the grid
     */
    var isInsideGrid: Bool
    
    /**
     The grid reference where the search was conducted
     */
    var gridReference: GridReference
    
    /**
     Returns a debug message to describe the BlockResults state.
     */
    var description: String {
        return "Colour: \(block?.colour.description ?? "nil"), Type: \(block?.type.description ?? "nil"), isInsideGrid: \(isInsideGrid), GridRef: \(gridReference.row), \(gridReference.column)."
    }
}
