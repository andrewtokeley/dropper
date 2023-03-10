//
//  RemoveRowsEffect.swift
//  dropper
//
//  Created by Andrew Tokeley on 7/03/23.
//

import Foundation

class RemoveRowsEffect: RemoveMatchedBlocksEffect {
    
    override func apply() -> Bool {
        var blocksToRemove = [BlockResult]()
        
        // Find the rows with no empty blocks
        for row in 0..<grid.rows {
            let blocks = grid.getRow(row)
            if blocks.filter({ $0.block != nil }).count == blocks.count {
                blocksToRemove.append(contentsOf: blocks)
            }
        }

        // See if there are any colour matches too
        let groups = findConnectedGroups(grid: grid)
        for group in groups {
            blocksToRemove.append(contentsOf: group)
        }
    
        if blocksToRemove.count > 0 {
            grid.removeBlocks(blocksToRemove.map { $0.gridReference })
            return true
        }
        // nothing to remove
        return false
    }
}
