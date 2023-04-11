//
//  DropBlocksEffect.swift
//  dropper
//
//  Created by Andrew Tokeley on 26/02/23.
//

import Foundation
/**
 Applies gravity to the grid, moving all blocks of type equal to .block, down as far as they'll go.
 
 Blocks of type wall, shape or jewel, are unaffected by applying the gravity effect. Additionally, blocks will not be able to drop through other blocks of any type.
 */
class GravityEffect: GridEffect {
    
    override func apply(_ grid: BlockGrid) -> EffectResult {
        self.effectResults.clear()
        
        // take a copy of the grid, so we can actually implement the gravity movements before committing
        let gridCopy = try! BlockGrid(grid.blocks)
        
        var blocksMoved = true
        while blocksMoved {

            // assume nothing can move
            blocksMoved = false

            // then iterate through each block to see how far it can move down
            for block in gridCopy.getAll().filter({ $0.block?.type == .block}) {
                var fromReference = block.gridReference
                
                // see how far we can move down
                while gridCopy.moveBlock(from: fromReference, direction: .down) {
                    fromReference = fromReference.offSet(-1, 0)
                    
                    // flag that something's moved
                    blocksMoved = true
                }
            }
        }
        
        // get the move/remove effects - no achievements
        effectResults = effectsFrom(grid, gridCopy)
        
        // apply the changes to the original grid
        let _ = grid.moveBlocks(from: effectResults.blocksMoved.map { $0.gridReference }, to: effectResults.blocksMovedTo, suppressDelegateCall: true)
        
        return effectResults
    }
}
