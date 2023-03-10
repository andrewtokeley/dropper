//
//  DropIntoEmptyRowsEffect.swift
//  dropper
//
//  Created by Andrew Tokeley on 7/03/23.
//

import Foundation

class DropIntoEmptyRowsEffect: GridEffect {
    
    override func apply() -> Bool {
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
            return grid.moveBlocks(from: blocksToMove.map { $0.gridReference }, direction:.down)
        }
        return false
    }
}
