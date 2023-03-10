//
//  BlockGridEffectsProtocol.swift
//  dropper
//
//  Created by Andrew Tokeley on 27/02/23.
//

import Foundation

class GridEffect {
    
    /// Reference to the BlockGrid being searched
    public var grid: BlockGrid!
    
    /// Initialise a new instance
    /// - Parameter grid:the grid to apply the effect to
    init(grid: BlockGrid) {
        self.grid = grid
    }
    
    /**
     Applies the effect on the grid, returning a flag indicating whether any blocks were moved/removed
     */
    func apply() -> Bool {
        return false
    }
    
}

