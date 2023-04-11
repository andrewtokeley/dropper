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
    
    /**
     Returns the movement and removal effects based on a before and after snapshot of the grid.
     
     Note, this method does not calculate acheivements, these should be calculated by individual Effects sub-classes
     */
    func effectsFrom(_ before: BlockGrid, _ after: BlockGrid) -> EffectResult {
        
        let result = EffectResult()
        
        let allBefore = before.getAll()
        let allAfter = after.getAll()
        
        
        var blocksRemoved = [BlockResult]()
        var blocksMoved = [BlockResult]()
        var blocksMovedTo = [GridReference]()
        
        for beforeBlock in allBefore {
            
            // has the block been removed
            let isRemoved = !allAfter.contains(where: { $0.block == beforeBlock.block } )
            if isRemoved {
                blocksRemoved.append(beforeBlock)
            } else {
                if let afterReference = (allAfter.first { $0.block == beforeBlock.block })?.gridReference {
                    if beforeBlock.gridReference != afterReference {
                        // it's moved!
                        blocksMoved.append(beforeBlock)
                        blocksMovedTo.append(afterReference)
                    }
                }
            }
        }
        result.blocksRemoved = blocksRemoved
        result.blocksMoved = blocksMoved
        result.blocksMovedTo = blocksMovedTo
        
        
        return result
    }
}

