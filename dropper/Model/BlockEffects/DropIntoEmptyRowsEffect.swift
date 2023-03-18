//
//  DropIntoEmptyRowsEffect.swift
//  dropper
//
//  Created by Andrew Tokeley on 7/03/23.
//

import Foundation
import UIKit

class DropIntoEmptyRowsEffect: GridEffect {
    
    override func apply(_ grid: BlockGrid) -> EffectResult {
        self.effectResults.clear()
        var blocksToMove = [BlockResult]()
        
        // for each blank row, move all the blocks above it down one space
        for row in 0..<grid.rows {
            let blocks = grid.getRow(row)
            
            let isEmpty = blocks.filter({ $0.block != nil } ).count == 0
            if isEmpty {
                for above in row+1..<grid.rows {
                    let blocksAbove = grid.getRow(above).filter { $0.block != nil }
                    blocksToMove.append(contentsOf: blocksAbove)
                }
            }
        }
        
        if blocksToMove.count > 0 {
            let _ = grid.moveBlocks(from: blocksToMove.map { $0.gridReference }, direction:.down, suppressDelegateCall: true)
        }
        // move to
        let to = blocksToMove.map { $0.gridReference.adjacent(BlockMoveDirection.down.gridDirection) }
        
        effectResults.blocksMoved = blocksToMove.map { $0.block! }
        effectResults.blocksMovedTo = to
        
        return effectResults
    }
}
