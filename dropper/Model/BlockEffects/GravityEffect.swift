//
//  DropBlocksEffect.swift
//  dropper
//
//  Created by Andrew Tokeley on 26/02/23.
//

import Foundation
/**
 Applies gravity to the grid, moving all moveable blocks down as far as they'll go.
 */
class GravityEffect: GridEffect {
    
    override func apply(_ grid: BlockGrid) -> EffectResult {
        self.effectResults.clear()
        
        var blockToDrop = [BlockResult]()
        var dropBlocksTo = [GridReference]()
        
        for column in 0..<grid.columns {
            
            // get the non-empty blocks in the column
            let blocks = grid.getColumn(column).filter({ $0.block != nil })
            
            // get the gaps in the column (if any exists)
            let gaps = grid.getColumnGaps(column)
            
            if gaps.count > 0 {
                
                // work out how far each block can move
                for block in blocks {
                    
                    // walls can't move, and player's get moved before dropping blocks
                    // TODO - we don't model .shape blocks anymore
                    if block.block?.type == .wall || block.block?.type == .shape {
                        continue
                    }
                    
                    // Normally the nearest barrier to moving is the bottom of the grid, however, if there's a player or wall in the way, this becomes the closest barrier
//                    var distanceToNearestBarrier = block.gridReference.row
//                    if let barrierBelow = blocks.last(where:
//                                                    { $0.gridReference.row < block.gridReference.row && ($0.block?.type == .wall || $0.block?.type == .player) }) {
//                        distanceToNearestBarrier = block.gridReference.row - barrierBelow.gridReference.row - 1
//                    }
                    
                    // add up the gaps beneath this block
                    let gapsBelow = gaps.filter( { $0.end.row < block.gridReference.row } )
                    let dropDistance = gapsBelow.reduce(0) { $0 + $1.length }

                    if dropDistance > 0 {
                        blockToDrop.append(block)
                        dropBlocksTo.append(block.gridReference.offSet(-dropDistance, 0))
                    }
                }
            }
        }
        
        // tell the delegate about the moves - don't tell the delegate since the EffectsRunner will handle this
        let _ = grid.moveBlocks(from: blockToDrop.map { $0.gridReference }, to: dropBlocksTo, suppressDelegateCall: true)
        
        effectResults.blocksMoved = blockToDrop.map { $0.block! }
        effectResults.blocksMovedTo = dropBlocksTo
        
        return effectResults

    }
}
