//
//  MatchBlocksEffect.swift
//  dropper
//
//  Created by Andrew Tokeley on 25/02/23.
//

import Foundation

/**
 This class is responsible for removing colour matched connected blocks from a grid.
 */
class RemoveMatchedBlocksEffect: GridEffect {
    
    /// Flag that stores whether a block in the grid has been checked for matches
    private var visited: [[Bool]]!
    
    /// The number of blocks that a group must include to be considered a match
    private var minimumMatchCount: Int

    
    /// Initailises a new ``RemoveMatchedBlocksEffect`` instance
    /// - Parameters:
    ///   - grid: grid to apply the effect on
    ///   - minimumMatchCount: minimum number of matching blocks to trigger a matched block group. The default is 9.
    init(minimumMatchCount: Int = 9) {
        self.minimumMatchCount = minimumMatchCount
    }
    
    /**
     Applies a remove effect to remove all sets of 3 or more blocks that are matched by colour.
     */
    override func apply(_ grid: BlockGrid) -> EffectResult {
        self.effectResults.clear()
        var removeBlocks = [Block]()
        let groups = findConnectedGroups(grid: grid, minimumMatchCount: self.minimumMatchCount)
        if groups.count > 0 {
            for group in groups {
                removeBlocks.append(contentsOf: group.map { $0.block! })
                grid.removeBlocks(group.map { $0.gridReference }, suppressDelegateCall: true)
            }
        }
        
        effectResults.blocksRemoved = removeBlocks
        effectResults.achievments.addTo(.explodedBlock, removeBlocks.count)
        
        if minimumMatchCount >= 10 && minimumMatchCount < 20 {
            effectResults.achievments.addTo(.match10, groups.count)
        }
        if minimumMatchCount >= 20 {
            effectResults.achievments.addTo(.match20, groups.count)
        }
        
        return effectResults
    }
    
    /**
     Returns each group of colour matched blocks.
     */
    public func findConnectedGroups(grid: BlockGrid, minimumMatchCount: Int) -> [[BlockResult]] {
        var groups = [[BlockResult]]()
        self.visited = Array(repeating: Array(repeating: false, count: grid.columns), count: grid.rows)
        
        // Search the world grid for pairs of connected blocks.
        for row in 0..<grid.rows {
            for column in 0..<grid.columns {
                let block = grid.get(GridReference(row, column))
                
                if block.block?.type == .wall {
                    continue
                }
                
                // Skip blocks we've already grouped.
                // If you don't want to add a visited field to every block,
                // you can accomplish this with a parallel array instead.
                if (!visited[row][column]) {
                    
                    // Every group of 2+ blocks has a block to the right or below another,
                    // so by checking just these two directions we don't exclude any.
                    let right = grid.get(block.gridReference.adjacent(.right))
                    if(right.isInsideGrid && right.block != nil) {
                        if(right.block?.colour == block.block?.colour) {
                            var group = [BlockResult]()
                            populateGroup(grid: grid, group: &group, block: block)
                            groups.append(group)
                            continue
                        }
                    }
                
                    let below = grid.get(block.gridReference.adjacent(.bottom))
                    if(below.isInsideGrid && below.block != nil) {
                        if(below.block?.colour == block.block?.colour) {
                            var group = [BlockResult]()
                            populateGroup(grid: grid, group: &group, block: block)
                            groups.append(group)
                        }
                    }
                }
            }
        }

        // Only return the groups which meet the minimumMatchCount criteria
        return groups.filter({$0.count >= minimumMatchCount })
    }

    /// Recursively find connected blocks (depth-first search)
    func populateGroup(grid: BlockGrid, group: inout [BlockResult], block: BlockResult) {
        group.append(block);
        visited[block.gridReference.row][block.gridReference.column] = true

        for neighbour in grid.adjacent(block.gridReference) {
            if neighbour.isInsideGrid {
                let neighbourVisited = visited[neighbour.gridReference.row][neighbour.gridReference.column]
                if(neighbour.block?.colour == block.block?.colour && !neighbourVisited) {
                    populateGroup(grid: grid, group: &group, block: neighbour)
                }
            }
        }
    }
}
