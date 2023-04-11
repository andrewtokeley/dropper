//
//  RemoveRowsEffect.swift
//  dropper
//
//  Created by Andrew Tokeley on 7/03/23.
//

import Foundation

/**
 Removes all blocks that are part of a full row (i.e. a row with only blocks)
 */
class RemoveRowsEffect: GridEffect {
    
    override func apply(_ grid: BlockGrid) -> EffectResult {
        self.effectResults.clear()
        
        let gridCopy = try! BlockGrid(grid.blocks)
        
        let fullRows = grid.getFullRowIndexes()
        
        // Note we removed from the highest to lowest row to ensure the indexes still refer to the right rows even after they're removed.
        for r in fullRows.reversed() {
            let blocksInRow = gridCopy.getRow(r)
            gridCopy.removeBlocks(blocksInRow.map { $0.gridReference }, suppressDelegateCall: true)
        }
        
        // Populate the move/removes
        effectResults = effectsFrom(grid, gridCopy)
        
        // Calculate achievements
        
        // how many jewels were removed?
        let jewels = effectResults.blocksRemoved.filter({$0.block?.type == .jewel}).count
        if jewels > 0 {
            effectResults.achievments.addTo(.jewel, jewels)
        }
            

        switch fullRows.count {
        case 1:
            effectResults.achievments.addTo(.oneRow, 1)
            effectResults.achievments.addTo(.explodedBlock,grid.columns)
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
            // do nothing
            break
        }
        
        // apply the changes to the original grid
        let _ = grid.removeBlocks(effectResults.blocksRemoved.map { $0.gridReference }, suppressDelegateCall:  true)
        
        return effectResults
        
    }
}
