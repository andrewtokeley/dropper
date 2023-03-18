//
//  BlockGridEffectsProtocol.swift
//  dropper
//
//  Created by Andrew Tokeley on 27/02/23.
//

import Foundation

class GridEffect {
    
    /// A record of what result the effect caused
    public var effectResults = EffectResult()
    
    /**
     Applies the effect on the grid, returning the result of the transformation.
     
     Note that this method will suppress any grid.delegate call backs that may advise of removed or moved blocks, so that the caller can handle effects more directly.
     
     - Returns: EffectResult
     */
    func apply(_ grid: BlockGrid) -> EffectResult {
        return EffectResult()
    }
    
}

