//
//  Shape.swift
//  dropper
//
//  Created by Andrew Tokeley on 6/03/23.
//

import Foundation

/**
 Orientation of a shape, where ``up`` is the initial state of all ``Shape`` instances.
 */
enum ShapeOrientation: Int {
    case up = 0
    case right
    case down
    case left
}

enum ShapeError: Error {
    case ShapeMustContainOrigin
}

/**
 The Shape class is used to describe a shape by the relative location of its blocks.
 */
class Shape {
    
    // MARK: - Member Variables
    
    /**
     The location of the shape on a grid
     */
    private(set) var references: [GridReference]
    
    /**
     The origin block of the shape. The centre of this block will be used as the centre of origin when rotating the shape.
     */
    var origin: GridReference {
        return references[originIndex]
    }
    
    /**
     Unique name for a shape, for example, 'L', 'Z'...
     */
    var name: String
    
    /**
     Returns whether a shape can be rotated or not.
     */
    var canBeRotated: Bool {
        return name != "O"
    }
    
    /**
     When a new instance is created this index is set to the index of the (0,0) reference
     */
    private var originIndex: Int
    
    /**
     The colours of each block, represented in the order the blocks are defined by ``references``
     */
    var colours: [BlockColour]
    
    /**
     BlocksResult array of the shape
     */
    var blocks: [BlockResult] {
        return references.enumerated().map { (index, reference) in
            BlockResult(
                block: Block(self.colours[index], .shape, self.isGhost),
                isInsideGrid: true,
                gridReference: reference) }
    }
    
    /**
     Flag to determine whether the block should be rendered as a ghost. Some games allow a shape to be mirrored at the bottom of the grid where the shape would land should it be dropped.
     */
    var isGhost: Bool = false
    
    /**
     The current orientation of the shape, where up is the initial state
     */
    var orientation = ShapeOrientation.up
    
    /**
     Wall kicks represent the movement offsets a shape is allowed to make to achieve a given rotation. Shapes can have different wall kick definitions.
     
     The key of the dictionary represents the *current* shape orientation and the offsets represent the kicks allowed to move clockwise to the next orientation.
     */
    var wallKicks = [ShapeOrientation: [GridOffset]]()
    
    
    // MARK: - Initialisers
    
    /**
     Initialises a shape by defining the relative references of its blocks and each block's colour.
     
     - Important: A shape must define a block at location (0,0) and this will be considered the centre of rotation.
     
     - Throws: a ``ShapeError/ShapeMustContainOrigin`` error if no (0,0) reference is supplied.
     */
    init(references: [GridReference], colours: [BlockColour], name: String = "") throws {
        guard let originIndex = references.firstIndex(where: {$0.row == 0 && $0.column == 0}) else { throw ShapeError.ShapeMustContainOrigin }
        
        self.references = references
        self.originIndex = originIndex
        self.colours = colours
        
        // The shapes J, L, T, S, Z all use the same kicks. These kicks are overridden for I and O.
        self.wallKicks[.up] = [GridOffset(0,0), GridOffset(0,-1), GridOffset(1,-1), GridOffset(-2,0), GridOffset(-2,-1)]
        self.wallKicks[.right] = [GridOffset(0,0), GridOffset(0,1), GridOffset(-1,1), GridOffset(2,0), GridOffset(2,1)]
        self.wallKicks[.down] = [GridOffset(0,0), GridOffset(0,1), GridOffset(1,1), GridOffset(-2,0), GridOffset(-2,1)]
        self.wallKicks[.left] = [GridOffset(0,0), GridOffset(0,-1), GridOffset(-1,-1), GridOffset(2,0), GridOffset(2,-1)]
        
        self.name = name
    }
    
    //MARK: - Public Methods
    
    /**
     Rotates the shape with an optional wallkick move.
     */
    func rotate(with kick: GridOffset = GridOffset.zero) {
        
        if orientation == .left {
            self.orientation = .up
        } else {
            if let newOrientation = ShapeOrientation(rawValue: orientation.rawValue + 1) {
                self.orientation = newOrientation
            }
        }
        
        // rotate the references
        self.references = getRotationWithKick(kick)
    }
    
    /**
     Moves the shape to the given local
     */
    func move(_ reference: GridReference) {
        let difference = reference - origin
        move(GridOffset(difference.row, difference.column))
    }

    /**
     Moves the shape by the given kick offset
     */
    func move(_ offset: GridOffset) {
        self.references = self.references.map { $0.offSet(offset) }
    }
    
    /**
     Moves the shape in the given direction
     */
    func move(_ direction: BlockMoveDirection) {
        move(direction.gridDirection.offset)
    }
    
    // MARK: - Public Methods
    
    /**
     Returns the references where the shape would move to given the destination.
     */
    func getReferences(afterMoveTo destination: GridReference) -> [GridReference] {
        
        var references = [GridReference]()
        
        // work out the offset to the new location
        let difference = destination - origin
        let offSet = GridOffset(difference.row, difference.column)
        
        for reference in self.references {
            references.append(reference.offSet(offSet))
        }
        
        return references
    }
    
    /**
     Returns the references the shape would occupy if rotated using the given kick offset.
     */
    func getRotationWithKick(_ kickOffset: GridOffset) -> [GridReference] {
        let rotatedReferences = getRotatedGridReferences(
            references: references.map { $0.offSet(kickOffset) },
            origin: self.origin.offSet(kickOffset))
        
        return rotatedReferences
    }

    // MARK: - Private Helpers
    
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
    
    // MARK: - Static Shape Methods
    
    /**
     Returns a random ``Shape`` instance.
     */
    static func random(_ colour: BlockColour) -> Shape {
        let type = Int.random(in: 0..<6)
        switch type {
        case 0:
            return L(colour)
        case 1:
            return I(colour)
        case 2:
            return J(colour)
        case 3:
            return S(colour)
        case 4:
            return Z(colour)
        case 5:
            return O(colour)
        default:
            return I(colour)
        }
    }
    
    /**
     L shape
     
     ````
     | | |x|
     |x|x|x|
     | | | |
     ````
     */
    static func L(_ colour: BlockColour) -> Shape {
        return try! Shape(
            references: [
            GridReference(0,1),
            GridReference(0,0),
            GridReference(0,-1),
            GridReference(1,1)
            ],
            colours: Array(repeating: colour, count: 4),
            name: "L")
    }
    
    /**
     J shape
     
     ````
     |x| | |
     |x|x|x|
     | | | |
     ````
     */
    static func J(_ colour: BlockColour) -> Shape {
        return try! Shape(
            references: [
            GridReference(0,1),
            GridReference(0,0),
            GridReference(0,-1),
            GridReference(1,-1)],
            colours: Array(repeating: colour, count: 4),
            name: "J")
    }
    
    /**
     I shape.
     
     ````
     | | | | |
     |x|x|x|x|
     | | | | |
     | | | | |
     ````
     */
    static func I(_ colour: BlockColour) -> Shape {
        let s = try! Shape(
            references: [
            GridReference(0,-1),
            GridReference(0,0),
            GridReference(0,1),
            GridReference(0,2)],
            colours: Array(repeating: colour, count: 4),
            name: "I")
        
        s.wallKicks[.up] = [GridOffset(0,0), GridOffset(0,-2), GridOffset(0,1), GridOffset(-1,-2), GridOffset(2,1)]
        s.wallKicks[.right] = [GridOffset(0,0), GridOffset(0,-1), GridOffset(0,2), GridOffset(1,2), GridOffset(-1,2)]
        s.wallKicks[.down] = [GridOffset(0,0), GridOffset(0,2), GridOffset(0,-1), GridOffset(1,2), GridOffset(-2,-1)]
        s.wallKicks[.left] = [GridOffset(0,0), GridOffset(0,1), GridOffset(0,-2), GridOffset(-2,1), GridOffset(1,-2)]
        return s
    }
    
    /**
     O shape
     
     ````
     | | | | |
     | |x|x| |
     | |x|x| |
     | | | | |
     ````
     */
    static func O(_ colour: BlockColour) -> Shape {
        let s = try! Shape(
            references: [
            GridReference(1,0),
            GridReference(1,1),
            GridReference(0,0),
            GridReference(0,1)],
            colours: Array(repeating: colour, count: 4),
            name: "O")
        
        s.wallKicks[.up] = [GridOffset(0,0)]
        s.wallKicks[.right] = [GridOffset(0,0)]
        s.wallKicks[.down] = [GridOffset(0,0)]
        s.wallKicks[.left] = [GridOffset(0,0)]
        return s
    }
    
    /**
     S shape
     
     ````
     | |x|x|
     |x|x| |
     | | | |
     ````
     */
    static func S(_ colour: BlockColour) -> Shape {
        return try! Shape(
            references: [
            GridReference(0,-1),
            GridReference(0,0),
            GridReference(1,0),
            GridReference(1,1)],
            colours: Array(repeating: colour, count: 4),
            name: "S")
    }
    
    /**
     Z shape
     
     ````
     |x|x| |
     | |x|x|
     | | | |
     ````
     */
    static func Z(_ colour: BlockColour) -> Shape {
        return try! Shape(
            references: [
            GridReference(1,-1),
            GridReference(1,0),
            GridReference(0,0),
            GridReference(0,1)],
            colours: Array(repeating: colour, count: 4),
            name: "Z")
    }
}

