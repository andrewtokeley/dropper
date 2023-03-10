//
//  DropBlocksEffect.swift
//  dropper
//
//  Created by Andrew Tokeley on 26/02/23.
//

import Foundation

class DropBlocksEffect: GridEffect {
    /**
     Applies gravity to the grid, moving all moveable blocks down as far as they'll go.
     
     Note this also check to see if player blocks can move too.
     */
    override func apply() -> Bool {
        var dropBlocksFrom = [GridReference]()
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
                    if block.block?.type == .wall || block.block?.type == .player {
                        continue
                    }
                    
                    // Normally the nearest barrier to moving is the bottom of the grid, however, if there's a player or wall in the way, this becomes the closest barrier
                    var distanceToNearestBarrier = block.gridReference.row
                    if let barrierBelow = blocks.last(where:
                                                    { $0.gridReference.row < block.gridReference.row && ($0.block?.type == .wall || $0.block?.type == .player) }) {
                        distanceToNearestBarrier = block.gridReference.row - barrierBelow.gridReference.row - 1
                    }
                    
                    // gaps below block
                    let gapsBelow = gaps.filter( { $0.end.row < block.gridReference.row } )
                    let dropDistance = min(gapsBelow.reduce(0) { $0 + $1.length }, distanceToNearestBarrier)

                    if dropDistance > 0 {
                        dropBlocksFrom.append(block.gridReference)
                        dropBlocksTo.append(block.gridReference.offSet(-dropDistance, 0))
                    }
                }
            }
        }
        
        // make the moves
        return grid.moveBlocks(from: dropBlocksFrom, to: dropBlocksTo)

    }
}