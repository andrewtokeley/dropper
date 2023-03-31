//
//  Shape.swift
//  dropper
//
//  Created by Andrew Tokeley on 6/03/23.
//

import Foundation

enum ShapeOrientation: Int {
    case up = 0
    case right
    case down
    case left
}

class Shape {
    
    /**
     GridReferences for each block of the shape, where the block at (0,0) is the centre of rotation.
     */
    var references: [GridReference]
    var colours: [BlockColour]
    var isGhost: Bool = false
    
    /**
     The current orientation of the shape, where up is the initial state
     */
    var orientation = ShapeOrientation.up
    
    /**
     Wall kicks represent the movement offsets a shape is allowed to make to achieve a given rotation.
     
     The key of the dictionary represents the *current* shape orientation and the offsets represent the kicks allowed to move clockwise to the next orientation
     */
    var wallKicks = [ShapeOrientation: [GridOffset]]()
    
    /**
     Rotates the shape (just the orientation property for now)
     */
    func rotate() {
        if orientation == .left {
            self.orientation = .up
        } else {
            if let newOrientation = ShapeOrientation(rawValue: orientation.rawValue + 1) {
                self.orientation = newOrientation
            }
        }
    }
    
    init(references: [GridReference], colours: [BlockColour]) {
        self.references = references
        self.colours = colours
        
        // The shapes J, L, T, S, Z all use the same kicks. These kicks are overridden I and O.
        self.wallKicks[.up] = [GridOffset(0,0), GridOffset(0,-1), GridOffset(1,-1), GridOffset(-2,0), GridOffset(-2,-1)]
        self.wallKicks[.right] = [GridOffset(0,0), GridOffset(0,1), GridOffset(-1,1), GridOffset(2,0), GridOffset(2,1)]
        self.wallKicks[.down] = [GridOffset(0,0), GridOffset(0,1), GridOffset(1,1), GridOffset(-2,0), GridOffset(-2,1)]
        self.wallKicks[.left] = [GridOffset(0,0), GridOffset(0,-1), GridOffset(-1,-1), GridOffset(2,0), GridOffset(2,-1)]
    }
    
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
        return Shape(
            references: [
            GridReference(0,1),
            GridReference(0,0),
            GridReference(0,-1),
            GridReference(1,1)
            ],
            colours: Array(repeating: colour, count: 4))
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
        return Shape(references: [
            GridReference(0,1),
            GridReference(0,0),
            GridReference(0,-1),
            GridReference(1,-1)
        ], colours: Array(repeating: colour, count: 4))
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
        let s = Shape(references: [
            GridReference(0,-1),
            GridReference(0,0),
            GridReference(0,1),
            GridReference(0,2)
        ], colours: Array(repeating: colour, count: 4))
        
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
        let s = Shape(references: [
            GridReference(1,0),
            GridReference(1,1),
            GridReference(0,0),
            GridReference(0,1)
        ], colours: Array(repeating: colour, count: 4))
        
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
        return Shape(references: [
            GridReference(0,-1),
            GridReference(0,0),
            GridReference(1,0),
            GridReference(1,1)
        ], colours: Array(repeating: colour, count: 4))
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
        return Shape(references: [
            GridReference(1,-1),
            GridReference(1,0),
            GridReference(0,0),
            GridReference(0,1)
        ], colours: Array(repeating: colour, count: 4))
    }
}

