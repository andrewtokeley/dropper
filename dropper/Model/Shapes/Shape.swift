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
    case ShapeColoursMustMatchReferenceCount
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
    var canBeRotated: Bool = true
    
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
                block: Block(self.colours[index], originIndex == index ? .shapeOrigin : .shape, self.isGhost),
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
     Initialises a Shape with the specified number of colours. Colours are chosen at random.
     
     - Parameters:
        - references: block references
        - numberOfColours:  the number of different colours to randomly apply to the shape
        - name: optional name to identify the shape. Default is ""
     
     If the number of randomColours is more than the number of blocks in the shape (n), only the first n will be used.
     
     - Important: One of the references must contain (0,0) which will be treated as the rotation origin of the shape. If no (0,0) reference is found a ``ShapeError/ShapeMustContainOrigin`` error is thrown.
     */
    convenience init(references: [GridReference], numberOfColours: Int, name: String = "") throws {
        
        let availableColours = BlockColour.random(numberOfColours)
        var useColours = [BlockColour]()
        for _ in 0..<references.count {
            useColours.append(availableColours.randomElement()!)
        }
        
        try self.init(references: references, colours: useColours, name: name)
    }
    
    /**
     Initialises a shape by defining the relative references of its blocks and the colour all blocks should have
     
     - Parameters:
        - references: block references
        - colour: the colour that all blocks will be
        - name: optional name to identify the shape
     
     - Important: One of the references must contain (0,0) which will be treated as the rotation origin of the shape. If no (0,0) reference is found a ``ShapeError/ShapeMustContainOrigin`` error is thrown.
     */
    convenience init(references: [GridReference], colour: BlockColour, name: String = "") throws {
        try self.init(references: references, colours: Array(repeating: colour, count: 4),
                 name: name)
    }
    
    /**
     Initialises a shape by defining the relative references of its blocks and the relative colours of each block
     
     - Parameters:
        - references: block references
        - colours: colour of each block, represented in the same order as the references. The number of colours must equal the number of references.
        - name: optional name to identify the shape
     
     - Important: One of the references must contain (0,0) which will be treated as the rotation origin of the shape. If no (0,0) reference is found a ``ShapeError/ShapeMustContainOrigin`` error is thrown.
     */
    init(references: [GridReference], colours: [BlockColour], name: String = "") throws {
        guard let originIndex = references.firstIndex(where: {$0.row == 0 && $0.column == 0}) else { throw ShapeError.ShapeMustContainOrigin }
        guard references.count == colours.count else { throw ShapeError.ShapeColoursMustMatchReferenceCount }
        
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
    
    static func random(_ numberOfColours: Int) -> Shape {
        let s = ShapeReference.random
        return try! Shape(references: s.references, numberOfColours:  numberOfColours, name: s.name)
    }
    
    /**
     Returns a random ``Shape`` instance, with a single colour
     */
    static func random(_ colour: BlockColour) -> Shape {
        let s = ShapeReference.random
        return try! Shape(references: s.references, colour: colour, name: s.name)
    }
    
    /**
     Returns a random shape but in the standard Tetris colours.
     */
    static func random() -> Shape {
        let s = ShapeReference.random
        return try! Shape(references: s.references, colour: defaultColourForShape(s), name: s.name)
    }
    
    static func defaultColourForShape(_ shape: ShapeReference) -> BlockColour {
        switch shape.name {
        case "L": return .colour1
        case "J": return .colour2
        case "I": return .colour3
        case "O": return .colour4
        case "S": return .colour5
        case "Z": return .colour6
        default: return .colour1
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
        let s = ShapeReference.L
        return try! Shape(
            references: s.references,
            colour: colour,
            name: s.name)
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
        let s = ShapeReference.J
        return try! Shape(
            references: s.references,
            colour: colour,
            name: s.name)
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
        let s = ShapeReference.I
        let shape = try! Shape(
            references: s.references,
            colour: colour,
            name: s.name)
        
        shape.wallKicks[.up] = [GridOffset(0,0), GridOffset(0,-2), GridOffset(0,1), GridOffset(-1,-2), GridOffset(2,1)]
        shape.wallKicks[.right] = [GridOffset(0,0), GridOffset(0,-1), GridOffset(0,2), GridOffset(1,2), GridOffset(-1,2)]
        shape.wallKicks[.down] = [GridOffset(0,0), GridOffset(0,2), GridOffset(0,-1), GridOffset(1,2), GridOffset(-2,-1)]
        shape.wallKicks[.left] = [GridOffset(0,0), GridOffset(0,1), GridOffset(0,-2), GridOffset(-2,1), GridOffset(1,-2)]
        return shape
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
        let s = ShapeReference.O
        let shape = try! Shape(
            references: s.references,
            colour: colour,
            name: s.name)
        
        // by default O's can't rotate
        shape.canBeRotated = false
        shape.wallKicks[.up] = [GridOffset(0,0)]
        shape.wallKicks[.right] = [GridOffset(0,0)]
        shape.wallKicks[.down] = [GridOffset(0,0)]
        shape.wallKicks[.left] = [GridOffset(0,0)]
        return shape
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
        let s = ShapeReference.S
        return try! Shape(
            references: s.references,
            colour: colour,
            name: s.name)
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
        let s = ShapeReference.Z
        return try! Shape(
            references: s.references,
            colour: colour,
            name: s.name)
    }
}

