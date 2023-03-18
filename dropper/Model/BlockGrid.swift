//
//  BlockGrid.swift
//  dropper
//
//  Created by Andrew Tokeley on 19/02/23.
//

import Foundation
import UIKit

enum BlockGridError: Error {
    case InvalidInitialBlocks
    case ReferenceOutOfBounds
    case PlayerAlreadyExists
    case InvalidPlayerSize
}

enum BlockMoveDirection: Int {
    case left = 0
    case right
    case down
    
    var gridDirection: GridDirection {
        switch self {
        case .down: return .bottom
        case .left: return .left
        case .right: return .right
        }
    }
}

/**
 Represents a grid of blocks
 */
class BlockGrid {
    
    // MARK: - Properties
    
    var delegate: BlockGridDelegate?
    
    /// The number of columns in the game
    var columns: Int = 15
    
    /// The number of rows in the game
    var rows: Int = 15
    
    /// A reference to the matrix of blocks in the game. A nil means there is no block at the given position. Blocks are referenced such that blocks[r][c] is the block at row, r, and column, c, using a zero based indexing.
    var blocks: [[Block?]]!
    
    /**
     Returns an array of BlockResults for each of the player blocks
     */
    var  playerBlocks: [BlockResult] {
        var result = [BlockResult]()
        for r in 0..<rows {
            for c in 0..<columns {
                let reference = GridReference(r,c)
                let block = blocks[reference.row][reference.column]
                if block?.type == .player {
                    result.append(BlockResult(block: block, isInsideGrid: true, gridReference: reference))
                }
            }
        }
        return result
    }
    
    /// Stores the grid reference of the player's orgin block
    var playerOrigin: GridReference?
    
    /**
     Returns whether the grid has any player blocks
     */
    var hasPlayer: Bool {
        playerBlocks.count > 0
    }
    
    // MARK: - Initialisers
    
    /// initializer to create a blank grid
    convenience init(rows: Int, columns: Int) throws {
        try self.init(rows: rows, columns: columns, blocks: Array(repeating: Array(repeating: nil, count: columns), count: rows) )
    }
    
    convenience init(_ blocks: [[String]]) throws {
        let rows = blocks.count
        let columns = blocks[0].count
        
        var result = [[Block?]]()
        
        for r in 0..<rows {
            if columns != blocks[rows-r-1].count {
                throw BlockGridError.InvalidInitialBlocks
            }
            result.append(Array(repeating: nil, count: columns))
            for c in 0..<columns {
                let char = blocks[rows-r-1][c]
                switch char {
                case "PB":
                    result[r][c] = Block(.colour4, .player)
                case "PY":
                    result[r][c] = Block(.colour2, .player)
                case "PR":
                    result[r][c] = Block(.colour3, .player)
                case "PO":
                    result[r][c] = Block(.colour1, .player)
                case "XB":
                    result[r][c] = Block(.colour4, .block)
                case "XY":
                    result[r][c] = Block(.colour2, .block)
                case "XR":
                    result[r][c] = Block(.colour3, .block)
                case "XO":
                    result[r][c] = Block(.colour1, .block)
                case "XX":
                    result[r][c] = Block(.colour6, .wall)
                default:
                    result[r][c] = nil
                }
            }
        }
        try self.init(rows: rows, columns: columns, blocks: result)
    }
    /**
     Initialise new TileSet
     
     - Parameters:
        - rows: number of rows in the grid
        - columns: number of columns in the grid
        - blockTypes: zero index based, 2D array of blocks. Importantly, the rows in the array are in reverse order to make it easier when setting this parameter from unit tests. That is, the row at index 0 is actually row 4 of a 4x4 grid.
     */
    init(rows: Int, columns: Int, blocks: [[Block?]]) throws {
        guard rows > 0 && columns > 0 else { throw BlockGridError.InvalidInitialBlocks }
        guard blocks.count == rows else { throw BlockGridError.InvalidInitialBlocks }
        guard blocks[0].count == columns else { throw BlockGridError.InvalidInitialBlocks }
        guard blocks.first(where: { $0.count != blocks[0].count }) == nil else { throw BlockGridError.InvalidInitialBlocks }
        
        self.rows = rows
        self.columns = columns
        self.blocks = blocks
        
    }
    
    
    // MARK: - Position Functions
    
    /**
     Returns the reference locations where the player would drop to
     */
    var playerDropReferences: [GridReference]? {
        
        if let playerOrigin = playerOrigin, let playerCanDropTo = playerCanDropTo {
            let rowOffset = playerCanDropTo.row - playerOrigin.row
            let columnOffset = playerCanDropTo.column - playerOrigin.column
            return playerBlocks.map { $0.gridReference.offSet(rowOffset, columnOffset)}
        }
        return nil
    }
    
    var playerCanDropTo: GridReference? {
        guard let playerOrigin = playerOrigin else {
            return nil
        }
        var dropTo: GridReference?
        for row in 0..<playerOrigin.row {
            let tryDropTo = playerOrigin.offSet(-(row + 1), 0)
            if canMovePlayer(tryDropTo) {
                dropTo = tryDropTo
            } else {
                // the first time we can't move down means the previous move was the furthest we can go
                break
            }
        }
        return dropTo
    }
    /**
     Returns whether a reference is within the bounds of the grid
     */
    func isInGrid(_ reference: GridReference) -> Bool {
        return  reference.row >= 0 &&
        reference.row < rows &&
        reference.column >= 0 &&
        reference.column < columns
    }
    
    /**
     Returns a BlockResult at the adjacent grid location
     */
    func adjacent(_ reference: GridReference, _ direction: GridDirection) -> BlockResult {
        return get(reference.adjacent(direction))
    }
    
    /**
     Returns all blocks adjacent to a BlockResult in all directions
     */
    func adjacent(_ reference: GridReference) -> [BlockResult] {
        var result = [BlockResult]()
        result.append(adjacent(reference, .top))
        result.append(adjacent(reference, .left))
        result.append(adjacent(reference, .bottom))
        result.append(adjacent(reference, .right))
        return result
    }
    
    /**
     Returns a BlockResult at the given grid reference
     */
    func get(_ reference: GridReference) -> BlockResult {
        let isInGrid = isInGrid(reference)
        return BlockResult(
            block: isInGrid ? blocks[reference.row][reference.column] : nil,
            isInsideGrid: isInGrid,
            gridReference: reference)
    }
    
    /**
     Returns an array of BlockResult instances at the selected grid references
     */
    func get(_ references: [GridReference]) -> [BlockResult] {
        var result = [BlockResult]()
        for reference in references {
            result.append(get(reference))
        }
        return result
    }
    
    /// Returns each block in a column
    /// - Parameter column: zero based column reference
    /// - Returns: array of ``BlockResult`` instances where the first row is the first element (index 0)
    func getColumn(_ column: Int) -> [BlockResult] {
        var result = [BlockResult]()
        for row in 0..<rows {
            result.append(get(GridReference(row, column)))
        }
        return result
    }
    
    /// Returns each block in a row
    /// - Parameter row: zero based reference reference
    /// - Returns: array of ``BlockResult`` instances where the first column is the first element (index 0)
    func getRow(_ row: Int) -> [BlockResult] {
        var result = [BlockResult]()
        for column in 0..<columns {
            result.append(get(GridReference(row, column)))
        }
        return result
    }
    
    /**
     Returns all non empty block results, optionally excluding the player blocks
     
     - Parameter excludePlayer: whether to exclude player blocks from the search. The default is true.
     */
    func getAll(excludePlayer: Bool = true) -> [BlockResult] {
        var result = [BlockResult]()
        for r in 0..<rows {
            for c in 0..<columns {
                let blockResult = get(GridReference(r,c))
                if let block = blockResult.block {
                    if block.type != .player || !excludePlayer {
                        result.append(blockResult)
                    }
                }
            }
        }
        return result
    }
    
    /**
     Returns the gaps between blocks in a column.
     
     A gap is defined by a grid range bounded by two non-empty blocks, or the bottom of the grid and a block. For example;
     ````
        | | |x|x|x|x|
        | | | |x|x|x|
        | |x| |x|x|x|
        |x| |x|x|x|x|
        |x|x| |x|x|x|
     ````
    - Column 0 has no gaps, because no upper bound exists above the last block
    - Column 1 has 1 single block gap at row 1
    - Column 2 has 2 gaps, a single one at row 0 and another one between rows 2 and 3 inclusive
     
     */
    func getColumnGaps(_ column: Int) -> [GridRange] {
        var result = [GridRange]()
        
        let columnBlocks = getColumn(column)
        
        var lowerBound: BlockResult?
        var upperBound: BlockResult?
        for block in columnBlocks {
            let below = self.adjacent(block.gridReference, .bottom)
            let above = self.adjacent(block.gridReference, .top)
            // check empty blocks only
            if block.block == nil {
                // is this a lower bound
                if (!below.isInsideGrid || below.block != nil) {
                    lowerBound = block
                }
                // is this a upper bound
                if (above.block != nil) {
                    upperBound = block
                    if let lowerBound = lowerBound, let upperBound = upperBound {
                        if let range = try? GridRange(start: lowerBound.gridReference, end: upperBound.gridReference) {
                            result.append(range)
                        }
                    }

                }
            }
        }
        return result
    }
    
    func transform(_ references: [GridReference], transformedInDirection direction: BlockMoveDirection) -> [GridReference] {
        var result = [GridReference]()
        for reference in references {
            result.append(reference.adjacent(direction.gridDirection))
        }
        return result
    }
    
    func transform(_ references: [GridReference], rotated90AboutOrigin origin: GridReference) -> [GridReference] {
        
        // remove origin from each block, to get the origin at 0,0
        var transformedReferences = references.map {
            GridReference($0.row - origin.row, $0.column - origin.column)
        }
        
        // transform around 0,0
        transformedReferences = transformedReferences.map {
            GridReference(-$0.column, $0.row)
        }
        
        // add the origin back
        transformedReferences = transformedReferences.map {
            GridReference($0.row + origin.row, $0.column + origin.column)
        }
        
        return transformedReferences
    }
    
    // MARK: - Block Movement
    
    
    /// Adds all the blocks to the grid, the delegate is only called once, when all the blocks have been successfully added
    /// - Parameters:
    ///   - blocks: block definitions to add
    ///   - references: where each block should be placed
    func addBlocks(blocks: [Block], references: [GridReference]) -> Bool {
        guard canAddBlocks(references: references) else { return false }
        
        for i in 0..<blocks.count {
            addBlock(block: blocks[i], reference: references[i], supressDelegateCallback: true)
        }
        //delegate?.blockGrid(self, blocksMoved: blocks, to: references)
        return true
    }
    
    /**
     Adds a new block to the game at the given reference location.
     */
    func addBlock(block: Block, reference: GridReference, supressDelegateCallback: Bool = false) {
        guard isInGrid(reference) else { return }
        
        blocks[reference.row][reference.column] = block
        
        // Let the delegate know (unless we're handling this elsewhere)
        if !supressDelegateCallback {
            delegate?.blockGrid(self, blockAdded: block, reference: reference)
        }
    }
    
    /// Returns whether it's valid to add new blocks to the grid at the references provided.
    ///
    /// - Parameter references: destination grid references
    /// - Returns: true if the referenced grid locations are empty and inside the grid bounds.
    func canAddBlocks(references: [GridReference]) -> Bool {
        for reference in references {
            let blockResult = get(reference)
            if !blockResult.isInsideGrid || blockResult.block != nil {
                return false
            }
        }
        return true
    }
    
    /**
     Returns whether a block at a location can move one grid in a given direction
     */
    func canMove(reference: GridReference, direction: BlockMoveDirection ) -> Bool {
        guard let block = get(reference).block else { return false }
        guard isInGrid(reference.adjacent(direction.gridDirection)) else { return false }

        // Can't move a block of type .fixed
        if block.type == .wall {
            return false
        }
        
        // get a reference to the BlockResult that's located where you want to move to
        let moveToBlockResult = get(reference.adjacent(direction.gridDirection))
        
        // destination location must be inside the grid and empty
        return moveToBlockResult.isInsideGrid && moveToBlockResult.block == nil
    }
    
    /**
     Returns whether we can move blocks from the location specified to the destination location.
     
     Note this method does not check whether the destination references maintain the shape of the source references
     */
    func canMove(references: [GridReference], to: [GridReference] ) -> Bool {
        guard references.count > 0 else { return false }
        guard references.count == to.count else { return false }
        
        let targetBlocks = get(to)
        for block in targetBlocks {
            // can move if (for all blocks) the destination location is empty or has a block that belongs to the moving set of blocks and in all cases must be inside the grid
            if ((block.block == nil ||
                references.contains(block.gridReference))) &&
                block.isInsideGrid {
                    // this is fine
            } else {
                return false
            }
        }
        // good to go!
        return true
    }
    
    /**
     Returns whether a group of blocks can move in the given direction.
     
     A group can move if each block's adjacent tile is blank or part of the moving group.
     */
    func canMove(references: [GridReference], direction: BlockMoveDirection ) -> Bool {
        let to = references.map { $0.adjacent(direction.gridDirection) }
        return canMove(references: references, to: to)
    }
    
    /**
     Moves a set of blocks from one location to another.
     - Parameters:
     - from: location of moving blocks
     - to: location where the blocks will move to
     - suppressDelegateCall: whether to suppress thre call to delegate after the move completes.
     - Returns: Returns a boolean indicating whether the move was successful The move will fail if the desitnation contains other blocks or is out of bounds.
     */
    func moveBlocks(from: [GridReference], to: [GridReference], suppressDelegateCall: Bool = false) -> Bool {
        guard from.count != 0 else { return false }
        guard from.count == to.count else { return false }
        
        // get references to the block instances to move
        let fromBlocks = get(from)
        
        // clear the from blocks
        for reference in from {
            blocks[reference.row][reference.column] = nil
        }
        
        // add blocks to new locations
        for i in 0..<to.count {
            let block = fromBlocks[i].block
            let reference = to[i]
            blocks[reference.row][reference.column] = block
        }
        
        // only tell the delegate of blocks that actually moved (i.e. ignore if you're moving from a blank block to a blank location)
        var movedBlocks = [Block]()
        var movedToReferences = [GridReference]()
        for i in 0..<fromBlocks.count {
            if let block = fromBlocks[i].block {
                movedBlocks.append(block)
                movedToReferences.append(to[i])
            }
        }
        
        if (!suppressDelegateCall) {
            delegate?.blockGrid(self, blocksMoved: movedBlocks, to: movedToReferences)
        }
        
        return true
    }
    
    /**
     Moves a group of blocks in a given direction. Returns true if the move was successful otherwise false.
     */
    func moveBlocks(from: [GridReference], direction: BlockMoveDirection, suppressDelegateCall: Bool = false) -> Bool {
        let to = transform(from, transformedInDirection: direction)
        return moveBlocks(from: from, to: to, suppressDelegateCall: suppressDelegateCall)
    }
    
    /**
     Moves the block from one location to another. If no block exists in the from location, or another block is present in the to location, the function will return false, otherwise true.
     
     Note the function will also return false if either from or to locations fall outside the grid dimensions.
     */
    func moveBlock(from: GridReference, to: GridReference) -> Bool {
        guard isInGrid(from) && isInGrid(to) else { return false }
        guard let block = get(from).block else { return false }

        blocks[from.row][from.column] = nil
        blocks[to.row][to.column] = block
        
        print("delegate blockMoved \(block.colour.description) to \(to)")
        delegate?.blockGrid(self, blockMoved: block, to: to)
        return true
    }
    
    /**
     Moves the block at a location in a given direction. If the move is not possible the function returns false.
     */
    func moveBlock(from: GridReference, direction: BlockMoveDirection) -> Bool {
        return moveBlock(from: from, to: get(from).gridReference.adjacent(direction.gridDirection))
    }
    
    /**
     Remove a block from the grid
     */
    func removeBlock(_ from: GridReference) {
        
    }
    
    /// Removes any blocks at the given reference locations
    /// - Parameter references: array of GridReference instances
    func removeBlocks(_ references: [GridReference], suppressDelegateCall: Bool = false) {
        var removedBlocks = [Block]()
        for reference in references {
            if let block = blocks[reference.row][reference.column] {
                removedBlocks.append(block)
                blocks[reference.row][reference.column] = nil
            }
        }
        if !suppressDelegateCall {
            delegate?.blockGrid(self, blocksRemoved: removedBlocks)
        }
    }
    
    
    // MARK: - Player Movement
    
    /// Add a player or the given shape definition to the top middle of the grid
    /// - Parameter shape: shape definition
    /// - Returns: boolean indicating whether the player could be added or not
    func addPlayer(_ shape: Shape) throws -> Bool {
        return try addPlayer(references: shape.references, colours: shape.colours)
    }
    
    /// Adds a player shape to the grid. The shape is defermined by an array of grid references.
    /// - Parameters:
    ///   - references: grid references describing the shape. The references are all relative to the shape's origin at reference (0,0).
    ///   - colours: array of colours for each of the shape's blocks
    func addPlayer(references: [GridReference], colours: [BlockColour]) throws -> Bool {
        guard !hasPlayer else { return false }
        guard references.count > 0 else { return false }
        guard references.count == colours.count else { return false }
        
        // position as high up the grid as possible, in the middle
        let originRow = rows - references.filter { $0.row > 0 }.count - 1
        let originColumn = Int(columns/2)
        playerOrigin = GridReference(originRow,originColumn)
        
        var playerBlocks = [BlockResult]()
        
        for i in 0..<references.count {
            let reference = playerOrigin!.offSet(references[i].row, references[i].column)
            let block = Block(colours[i], .player)
            playerBlocks.append(BlockResult(block: block, isInsideGrid: true, gridReference: reference))
        }
        
        let result = addBlocks(blocks: playerBlocks.map { $0.block! }, references: playerBlocks.map { $0.gridReference })
        
        if result {
            delegate?.blockGrid(self, playerAdded: playerBlocks)
            return true
        }
        
        // something went wrong
        return false
    }
    
    /**
     Adds a new set of player blocks to the game. Players can not be added if there is already a player in the game and the size must be between 2 and 5 inclusive.
     
     Currently only straiht, horizontal, players are supported.
     
     Players are always added at that top of the game, in the centre.
     */
//    func addPlayer(colours: [BlockColour], origin: GridReference) throws -> [BlockResult] {
//        guard !hasPlayer else { throw BlockGridError.PlayerAlreadyExists }
//        guard colours.count>=2 && colours.count<=5 else { throw BlockGridError.InvalidPlayerSize }
//        guard get(origin).isInsideGrid else { throw BlockGridError.ReferenceOutOfBounds }
//        
//        let size = colours.count
//        
//        // centre the player horizontally with it's origin at the specified reference
//        let leftMostReference = origin.offSet(0, -Int(size/2))
//        
//        // only doing horizontal straight players atm
//        var playerBlocks = [BlockResult]()
//        for i in 0..<size {
//            let reference = leftMostReference.offSet(0, i)
//            if !get(reference).isInsideGrid {
//                throw BlockGridError.ReferenceOutOfBounds
//            }
//            let block = Block(colours[i], .player)
//            if (reference == origin) {
//                block.isOrigin = true
//            }
//            
//            addBlock(block: block, reference: reference)
//            playerBlocks.append(BlockResult(block: block, isInsideGrid: true, gridReference: reference))
//        }
//        delegate?.blockGrid(self, playerAdded: playerBlocks)
//        return playerBlocks
//    }
//    
    
    /**
     Moves a play as far down as it will go
     */
    func dropPlayer() {
        guard hasPlayer else { return }
        guard let playerDropReferences = playerDropReferences else { return }
        
        let playerReferences = playerBlocks.map { $0.gridReference }
        let _ = moveBlocks(from: playerReferences , to: playerDropReferences, suppressDelegateCall: true)
        
        // update the player origin
        if let playerOrigin = playerOrigin {
            let delta = playerDropReferences[0] - playerReferences[0]
            self.playerOrigin = playerOrigin + delta
            delegate?.blockGrid(self, playerDropedTo: self.playerOrigin!)
        }
    }
    
    /**
     Returns whether the play can move
     */
    public func canMovePlayer(_ direction: BlockMoveDirection) -> Bool {
        return canMove(references: playerBlocks.map { $0.gridReference }, direction: direction)
    }
    
    /**
     Retursn whether the player can move to the specified reference location
     */
    public func canMovePlayer(_ reference: GridReference) -> Bool {
        guard let playerOrigin = playerOrigin else {
            return false
        }

        // calculate the player references for the given location
        
        let rowOffset = reference.row - playerOrigin.row
        let columnOffset = reference.column - playerOrigin.column
        let references  = playerBlocks.map { $0.gridReference.offSet(rowOffset, columnOffset)}
        
        return canMove(references: playerBlocks.map { $0.gridReference }, to: references)
    }
    
//    func movePlayer(to: reference) -> Bool {
//        guard hasPlayer else { return false }
//        guard canMovePlayer(reference) else { return false }
//        
//        let references = playerBlocks.map { $0.gridReference }
//        
//        // Don't allow moveBlocks to call the moveBlocks delegate method because we want to call  playerDropped instead, as it's likely to be handled differently by clients
//        let result = moveBlocks(from: references, direction: dir, suppressDelegateCall: true)
//        
//        if result {
//            // redefine where the origin is
//            playerOrigin = playerOrigin?.adjacent(direction.gridDirection)
//            
//            delegate?.blockGrid(self, playerMovedInDirection: direction)
//        }
//        return result
//    }
    
    func movePlayer(_ direction: BlockMoveDirection) -> Bool {
        guard hasPlayer else { return false }
        guard canMovePlayer(direction) else { return false }
        
        let references = playerBlocks.map { $0.gridReference }
        
        // Don't allow moveBlocks to call the moveBlocks delegate method because we want to call  playerDropped instead, as it's likely to be handled differently by clients
        let result = moveBlocks(from: references, direction: direction, suppressDelegateCall: true)
        
        if result {
            // redefine where the origin is
            playerOrigin = playerOrigin?.adjacent(direction.gridDirection)
            delegate?.blockGrid(self, playerMovedInDirection: direction)
        }
        return result
        
        
    }
    
    /**
     Returns the new grid references after rotating them around an origin 90 degrees clockwise
     */
    private func getRotatedGridReferences(references: [GridReference], origin: GridReference ) -> [GridReference] {
        
        // remove origin from each block, to get the origin at 0,0
        var transformedReferences = references.map {
            GridReference($0.row - origin.row, $0.column - origin.column)
        }
        
        // transform around 0,0
        transformedReferences = transformedReferences.map {
            GridReference(-$0.column, $0.row)
        }
        
        // add the origin back
        transformedReferences = transformedReferences.map {
            GridReference($0.row + origin.row, $0.column + origin.column)
        }
        
        return transformedReferences
    }


    /**
     Returns the transformed grid references for the player, or nil if the player can't be rotated
     */
    var rotatedPlayerGridReference: [GridReference]? {
        guard let playerOrigin = playerOrigin else { return nil }
        
        let playerReferences = playerBlocks.map { $0.gridReference }
        let transformedReferences = getRotatedGridReferences(references: playerReferences, origin: playerOrigin)
        
        // make sure none of the transformed references are outside of the grid or land on another block
        if canMove(references: playerReferences, to: transformedReferences) {
            return transformedReferences
        }
        return nil
    }
    
    /**
     Returns whether the player can be rotated
     */
    var canRotatePlayer: Bool {
        return rotatedPlayerGridReference != nil
    }
    
    /**
     Rotates the player
     */
    func rotatePlayer() -> Bool {
        guard let transformGridReferences = rotatedPlayerGridReference else { return false }
        
        // move the player blocks by the transform
        let player = playerBlocks.map { $0.gridReference }
        let result = moveBlocks(from: player, to: transformGridReferences, suppressDelegateCall: true)
        delegate?.blockGrid(self, playerRotatedBy: 90.0)
        return result
    }
    
    /**
     Converts the player into standard blocks.
     
     Even though this method is simply going to change the type of each player block from .player to .type, it will call the delegate methods blockAdded and playerRemoved as the view clients treats players and blocks differently.
     */
    func replacePlayerWithBlocksOfType(_ type: BlockType) {
        
        // tell the delegate to remove the player
        let blocks = playerBlocks
        for playerBlock in blocks {
            let reference = playerBlock.gridReference
            playerBlock.block?.type = type
            delegate?.blockGrid(self, blockAdded: playerBlock.block!, reference: reference)
        }
        delegate?.playerRemoved()
    }
    
}
//MARK: - CustomStringConvertible
extension BlockGrid: CustomStringConvertible {
    var description: String {
        var result = (Array(0..<columns).map { String($0) }).joined(separator: "|")
        result = " " + result
        for r in 0..<rows {
            let row = blocks[r].map{ (block) -> String in
                if let block = block {
                    return block.type == .player ? "P" : "X"
                } else {
                    return " "
                }
            }
            result = String(r) + row.joined(separator: "|") + "\n" + result
        }
        return result
    }
}
