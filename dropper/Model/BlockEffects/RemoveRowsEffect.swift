//
//  RemoveRowsEffect.swift
//  dropper
//
//  Created by Andrew Tokeley on 7/03/23.
//

import Foundation

/**
 Removes blocks that are in completed rows that each have no empty spaces.
 */
class RemoveRowsEffect: GridEffect {
    
    override func apply(_ grid: BlockGrid) -> EffectResult {
        self.effectResults.clear()
        
        var blocksToRemove = [BlockResult]()
        
        // Find the rows with no empty blocks
        for row in 0..<grid.rows {
            let blocks = grid.getRow(row)
            if blocks.filter({ $0.block != nil }).count == blocks.count {
                blocksToRemove.append(contentsOf: blocks)
            }
        }

        if blocksToRemove.count > 0 {
            grid.removeBlocks(blocksToRemove.map { $0.gridReference }, suppressDelegateCall: true)
            
            effectResults.blocksRemoved = blocksToRemove.map { $0.block! }
            
            // calculate how many rows were removed
            let rowsRemoved = blocksToRemove.count / grid.columns
            switch rowsRemoved {
            case 2:
                effectResults.achievments.addTo(.twoRows,1)
                effectResults.achievments.addTo(.explodedBlock,grid.columns*2)
                break
            case 3:
                effectResults.achievments.addTo(.threeRows,1)
                effectResults.achievments.addTo(.explodedBlock,grid.columns*3)
                break
            case 4:
                effectResults.achievments.addTo(.fourRows,1)
                effectResults.achievments.addTo(.explodedBlock,grid.columns*4)
                break
            default:
                effectResults.achievments.addTo(.oneRow, 1)
                effectResults.achievments.addTo(.explodedBlock,grid.columns)
            }
        }
        
        return effectResults
        
    }
}
