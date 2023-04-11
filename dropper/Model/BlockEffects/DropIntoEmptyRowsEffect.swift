//
//  DropIntoEmptyRowsEffect.swift
//  dropper
//
//  Created by Andrew Tokeley on 7/03/23.
//

import Foundation
import UIKit

/**
 This effect will identify any rows containing no blocks and move all blocks located above it down into the empty row.
 
 Jewels, shape or wall blocks are unaffected by this effect and additionally blocks that can drop can't drop through them.
 */
class DropIntoEmptyRowsEffect: GridEffect {
    
    override func apply(_ grid: BlockGrid) -> EffectResult {
        self.effectResults.clear()
        
        // take a copy of the grid, so we can actually implement the gravity movements before committing
        let gridCopy = try! BlockGrid(grid.blocks)
        
        // for each empty row, move all the blocks above it down one space
        // note we reverse the order so we start with the top most empty row to avoid the indexes
        // being changed
        for r in gridCopy.getEmptyRowIndexes().reversed() {
            
            // drop all blocks above this that can move down one row
            let blocksAbove = gridCopy.getRows(Array(r...gridCopy.rows)).filter({$0.block?.type == .block})
            let blocksAboveReferences = blocksAbove.map { $0.gridReference }
            
            let _ = gridCopy.moveBlocks(from: blocksAboveReferences, direction: .down, suppressDelegateCall: true)
        }
        
        effectResults = effectsFrom(grid, gridCopy)
        
        // apply the changes to the original grid
        let _ = grid.moveBlocks(from: effectResults.blocksMoved.map { $0.gridReference }, to: effectResults.blocksMovedTo, suppressDelegateCall: true)
        
        return effectResults
    }
}
