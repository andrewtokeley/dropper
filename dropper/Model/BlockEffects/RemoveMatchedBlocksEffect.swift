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
    private var minimumMatchCount: Int = 9

    init(grid: BlockGrid, minimumMatchCount: Int = 9) {
        super.init(grid: grid)
        self.minimumMatchCount = minimumMatchCount
    }
    
    /**
     Applies a remove effect to remove all sets of 3 or more blocks that are matched by colour.
     */
    override func apply() -> Bool {
        let groups = findConnectedGroups(grid: grid)
        if groups.count == 0 {
            return false
        } else {
            for group in groups {
                grid.removeBlocks(group.map { $0.gridReference })
            }
            return true
        }
    }
    
    /**
     Returns each group of colour matched blocks.
     */
    public func findConnectedGroups(grid: BlockGrid) -> [[BlockResult]] {
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