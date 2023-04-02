//
//  BlockGrid.swift
//  dropper
//
//  Created by Andrew Tokeley on 19/02/23.
//

import Foundation
import UIKit

enum BlockGridError: Error {
    /// Thrown by BlockGrid initialisers if supplied inconsistent state.
    case InvalidInitialBlocks
    
    /// Thrown if attempt to add a new shape fails
    case CantAddShape
}

/**
 Describes the direction a block can move
 */
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
    
    /**
     Delegates methods are called to advise of changes to grid state.
     */
    var delegate: BlockGridDelegate?
    
    /// The number of columns in the game
    var columns: Int
    
    /// The number of rows in the game
    var rows: Int
    
    /**
     A reference to the matrix of blocks in the grid.
     
     A nil means there is no block at the given position. Blocks are referenced such that blocks[r][c] is the block at row, r, and column, c, using a zero based indexing.
     
     Includes blocks of all types, including the active Shape's blocks. To exclude the active Shape, use ``blocksExcludingShape``
     */
    var blocks: [[Block?]]!
    
    /**
     A reference to the matrix of blocks in the grid, but excluding blocks of type .shape.
     */
    var blocksExcludingShape: [[Block?]]! {
        return blocks.map { $0.map( { $0.map { $0?.type == .shape ? nil : $0 } }) }
    }
    
    /**
     A reference to the original shape added to the grid.
     */
    var shape: Shape?
    
    /**
     A ``BlockResult`` array  for each of the shape's blocks
     */
    var  shapeBlocks: [BlockResult] {
        guard let shape = self.shape else { return [BlockResult]() }
        return shape.blocks
    }
    
    // MARK: - Initialisers
    
    /**
     Initialises a blank grid
     */
    convenience init(rows: Int, columns: Int) throws {
        try self.init(Array(repeating: Array(repeating: nil, count: columns), count: rows) )
    }
    
    /**
     Initialises a grid with blocks represented by the string elements of the 2D array.
     
     - Parameter blocks: a 2D array of block strings, where blocks[0][0] represents the block in the bottom row and leftmost column.
  
     This initialiser is intended to be used as a convenience for testing.
     
     Valid strings to represent blocks include,
     - X1: standard block set to ``BlockColour/colour1``
     - X2: standard block set to ``BlockColour/colour2``
     - ...X4: : standard block set to ``BlockColour/colour4``
     - S1: shape block set to ``BlockColour/colour1``
     - ...S4: shape block set to ``BlockColour/colour4``
     - A small 's' represents the origin of the shape
     
     Note, some older tests may be using XB, XR, XO, XY and PB, PR, PO, PY but these should be avoided.
     
     For example;
     ````
     let grid = try! BlockGrid([
     ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
     ["  ", "S1", "s1", "S1", "S1", "  ", "  "],
     ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
     ["  ", "  ", "  ", "X2", "  ", "  ", "  "],
     ["  ", "  ", "X1", "  ", "  ", "  ", "  "],
     ["  ", "X1", "X1", "  ", "  ", "  ", "  "],
     ["  ", "X1", "  ", "  ", "  ", "  ", "  "],
     ])
     ````
     
     */
    convenience init(_ blocks: [[String]]) throws {
        let rows = blocks.count
        let columns = blocks[0].count
        
        var result = [[Block?]]()
        var shapeReferences = [GridReference]()
        var shapeColours = [BlockColour]()
        var shapeOrigin = GridReference.zero
        
        for r in 0..<rows {
            if columns != blocks[rows-r-1].count {
                throw BlockGridError.InvalidInitialBlocks
            }
            result.append(Array(repeating: nil, count: columns))
            for c in 0..<columns {
                
                let char = blocks[rows-r-1][c]
                if char.starts(with: "s") {
                    shapeOrigin = GridReference(r,c)
                }
                switch char {
                case "PO", "S1", "s1":
                    shapeReferences.append(GridReference(r,c))
                    shapeColours.append(BlockColour.colour1)
                case "PY", "S2", "s2":
                    shapeReferences.append(GridReference(r,c))
                    shapeColours.append(BlockColour.colour2)
                case "PR", "S3", "s3":
                    shapeReferences.append(GridReference(r,c))
                    shapeColours.append(BlockColour.colour3)
                case "PB","S4","s4":
                    shapeReferences.append(GridReference(r,c))
                    shapeColours.append(BlockColour.colour4)
                case "XO", "X1":
                    result[r][c] = Block(.colour1, .block)
                case "XY", "X2":
                    result[r][c] = Block(.colour2, .block)
                case "XR", "X3":
                    result[r][c] = Block(.colour3, .block)
                case "XB", "X4":
                    result[r][c] = Block(.colour4, .block)
                case "XX", "WW":
                    result[r][c] = Block(.colour6, .wall)
                default:
                    result[r][c] = nil
                }
            }
        }
        var shape: Shape?
        if shapeReferences.count > 0 {
            if shapeOrigin == GridReference.zero {
                throw BlockGridError.InvalidInitialBlocks
            } else {
                // normalise so that origin is at (0,0)
                let references = shapeReferences.map { $0 - shapeOrigin }
                shape = try? Shape(references: references, colours: shapeColours)
                
                // move into place
                shape?.move(shapeOrigin)
            }
        }
        try self.init(result, shape: shape)
    }
    
    /**
     Initialise new BlockGrid from a matrix of Block instances.
     
     - Parameters:
        - blocks: ``Block``matrix, where blocks[0,0] is the block at row 0, column 0, and a nil means there's no block.
        - shape: adds a shape to the grid
     - Throws:
     Throws a ``BlockGridError/InvalidInitialBlocks`` is the matrix elements don't all have the same number of elements.
     */
    init(_ blocks: [[Block?]], shape: Shape? = nil) throws {
        guard blocks.count > 0 && blocks[0].count > 0 else { throw BlockGridError.InvalidInitialBlocks }
        guard blocks.first(where: { $0.count != blocks[0].count }) == nil else { throw BlockGridError.InvalidInitialBlocks }
        
        self.rows = blocks.count
        self.columns = blocks[0].count
        self.blocks = blocks
        if let shape = shape {
            let result = self.addShape(shape)
            if !result {
                throw BlockGridError.CantAddShape
            }
        }
    }
    
    // MARK: - Position Functions
    
    /**
     Returns the location the active shape can drop to
     */
//    var shapeDropReferences: [GridReference]? {
//        guard let shape = self.shape else { return nil }
//
//        if let shapeCanDropTo = shapeCanDropTo {
//            let rowOffset = shapeCanDropTo.row - shape.origin.row
//            let columnOffset = shapeCanDropTo.column - shape.origin.column
//            return shapeBlocks.map { $0.gridReference.offSet(rowOffset, columnOffset)}
//        }
//        return nil
//    }
    
    /**
     Returns to where the active shape can drop
     */
    var shapeCanDropTo: GridReference? {
        guard let origin = self.shape?.origin else {
            return nil
        }
        var dropTo: GridReference?
        for row in 0..<origin.row {
            let tryDropTo = origin.offSet(-(row + 1), 0)
            if canMoveShape(tryDropTo) {
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
    
    /**
     Returns each block in a column
    - Parameter column: zero based column reference
    - Returns: array of ``BlockResult`` instances where the first row is the first element (index 0)
     */
    func getColumn(_ column: Int, includeShape: Bool = false) -> [BlockResult] {
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
     
     - Parameter excludeShape: whether to exclude the active shape's blocks from the search. The default is true.
     */
    func getAll(includeShape: Bool = false) -> [BlockResult] {
        var result = [BlockResult]()
        for r in 0..<rows {
            for c in 0..<columns {
                let blockResult = get(GridReference(r,c))
                if let _ = blockResult.block {
                    result.append(blockResult)
                }
                if includeShape {
                    if let shapeBlock = shape?.blocks.first(where: { $0.gridReference == GridReference(r,c) }) {
                        result.append(shapeBlock)
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
    
    /**
     Transforms the references in the given direction and returns the result.
     
     - Parameters:
     - references: references to transform
     - direction: a ``BlockMoveDirection`` to transform towards
     - Returns: new GridReference array
     */
    private func transform(_ references: [GridReference], transformedInDirection direction: BlockMoveDirection) -> [GridReference] {
        var result = [GridReference]()
        for reference in references {
            result.append(reference.adjacent(direction.gridDirection))
        }
        return result
    }
    
    /**
     Returns true if there are no blocks at the given references and all the references lie inside the grid.
     
     This is used to see whether the active shape can move/rotate into the references.
     */
    private func isClear(_ references: [GridReference]) -> Bool {
        
        // see if we an prove this wrong
        for reference in references {
            let blockResult = get(reference)
            
            if !blockResult.isInsideGrid || blockResult.block != nil {
                return false
            }
        }
        // if we get this far it's clear
        return true
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
        guard references.count > 0 else {
            return false
        }
        guard references.count == to.count else {
            return false
        }
        
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
     Removes blocks at the given reference locations
     
     - Parameter references: the references to
     - Parameter suppressDelegateCall: if set to `false` (the default) calling this method will result in a call to ``BlockGridDelegate/blockGrid(_:blocksRemoved:)``.
     */
    public func removeBlocks(_ references: [GridReference], suppressDelegateCall: Bool = false) {
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
    
    
    // MARK: - Shape Movement
    /**
     Adds a shape to the top centre of the grid, ignoring its current location.
     */
    public func addShapeTopCentre(_ shape: Shape) -> Bool {
        
        // normalise the shape to put it's origin at (0,0)
        if let maxRow = shape.references.map({ $0.row }).max() {
            let row = rows - (maxRow - shape.origin.row) - 1
            let column = Int(columns/2)
            shape.move(GridReference(row,column))
            return addShape(shape)
        }
        return false
    }
    
    /**
     Adds a new ``Shape`` to the grid at the given grid location
     
     - Parameters:
        - shape: a ``Shape`` instance representing the shape to add
     
     - Returns: A flag that returns whether the shape was successfully added or not
     */
    public func addShape(_ shape: Shape) -> Bool {
        guard self.shape == nil else { return false }
        
        if isClear(shape.references) {
            self.shape = shape
            delegate?.blockGrid(self, shapeAdded: shape, to: shape.origin)
            return true
        } else {
            return false
        }
    }
    
    /**
     Moves the active shape as far down as it will go. This method will only call ``BlockGridDelegate/blockGrid(_:shapeDropedTo:)`` when dropped, no other delegate methods will be called.
     */
    public func dropShape() {
        guard let shape = self.shape else { return }
        guard let shapeCanDropTo = shapeCanDropTo else { return }
        
        shape.move(shapeCanDropTo)
        delegate?.blockGrid(self, shapeDropedTo: shape.origin)
    }
    
    /**
     Returns whether the active shape can move in the given direction
     */
    public func canMoveShape(_ direction: BlockMoveDirection) -> Bool {
        guard let shape = self.shape else { return false }
        
        let destination = shape.origin.adjacent(direction.gridDirection)
        return canMoveShape(destination)
    }
    
    /**
     Returns whether the active shape can move to the specified reference location
     */
    public func canMoveShape(_ reference: GridReference) -> Bool {
        guard let shape = self.shape else { return false }

        // calculate the player references for the given location
        return isClear(shape.getReferences(afterMoveTo: reference))

    }
    
    /**
     Moves the active shape in the given direction.
     
     Will call ``BlockGridDelegate/blockGrid(_:shapeMovedInDirection:)`` once complete.
     */
    public func moveShape(_ direction: BlockMoveDirection) -> Bool {
        guard let shape = self.shape else { return false }
        guard canMoveShape(direction) else { return false }
        
        //let references = shapeBlocks.map { $0.gridReference }
        
        // Don't allow moveBlocks to call the moveBlocks delegate method because we want to call  shapeMovedInDirection instead, as it's likely to be handled differently by clients
        let result = moveBlocks(from: shape.references, direction: direction, suppressDelegateCall: true)
        
        if result {
            shape.move(direction)
            // redefine where the origin is
            delegate?.blockGrid(self, shapeMovedInDirection: direction)
        }
        return result
    }
    
    /**
     Returns the new grid references after rotating them around an origin 90 degrees clockwise.
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
     Returns the transformed grid references for the shape, or nil if the player can't be rotated
     */
//    private var rotatedShapeGridReference: ShapeRotationResult {
//        guard let shape = self.shape else { return ShapeRotationResult(canRotate: false) }
//        
//        var result = ShapeRotationResult(canRotate: false)
//        if let wallKicks = shape.wallKicks[shape.orientation] {
//            
//            // iterate the wallKicks offsets
//            for kick in wallKicks {
//                
//                let transformedReferences = shape.getRotationWithKick(kick)
//                if canMove(references: shape.references, to: transformedReferences) {
//                    // this kick worked!
//                    result.wallKick = kick
//                    result.canRotate = true
//                    result.transformedReferences = transformedReferences
//                }
//            }
//        }
//        
//        return result
//    }
  
    /**
     Rotates the active shape clockwise 90 degrees.
     
     Will call ``BlockGridDelegate/blockGrid(_:shapeRotatedBy:withKick:)`` delegate method.
     
     See ``Shape/wallKicks`` for an explanation of wall kicks.
     */
    public func rotateShape() -> Bool {
        guard let shape = self.shape else { return false }
        guard shape.canBeRotated else { return false }

        // iterate through the kicks to find the first one that allows a rotation
        if let kicks = shape.wallKicks[shape.orientation] {
            for kick in kicks {
                let destination = shape.getRotationWithKick(kick)
                if isClear(destination) {
                    shape.rotate(with: kick)
                    delegate?.blockGrid(self, shapeRotatedBy: 90.0, withKickMove: shape.origin)
                    return true
                }
            }
        }
        return false
    }
    
    /**
     Converts the active shape into standard blocks.
     
     Even though this method is simply going to change the type of each player block from .player to .type, it will call the delegate methods ``BlockGridDelegate/blockGrid(_:blockAdded:reference:)``  and ``BlockGridDelegate/shapeRemoved()`` to allow the delegate clients to simulate the change as required.
     */
    public func replaceShapeWithBlocksOfType(_ type: BlockType) {
        guard let shape = self.shape else { return }
        
        for result in shape.blocks {
            let block = result.block
            block?.type = .block
            addBlock(block: block!, reference: result.gridReference)
        }
        
        // remove the shape from the grid
        self.shape = nil
        delegate?.shapeRemoved()
    }
    
}
//MARK: - CustomStringConvertible
extension BlockGrid: CustomStringConvertible {
    
    var description: String {
        var result = (Array(0..<columns).map { String($0) }).joined(separator: "|")
        result = " " + result
        for r in 0..<rows {
            var row = [String]()
            for c in 0..<columns {
                let reference = GridReference(r,c)
                let block = get(reference)
                if block.block != nil {
                    row.append("X")
                } else if shape?.references.contains(reference) ?? false {
                    if shape?.origin == reference {
                        row.append("s")
                    } else {
                        row.append("S")
                    }
                } else {
                    row.append(" ")
                }
            }
            result = String(r) + row.joined(separator: "|") + "\n" + result
        }
        return result
    }
}
