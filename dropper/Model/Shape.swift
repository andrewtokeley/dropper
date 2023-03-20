//
//  Shape.swift
//  dropper
//
//  Created by Andrew Tokeley on 6/03/23.
//

import Foundation

struct Shape {
    var references: [GridReference]
    var colours: [BlockColour]
    var isGhost: Bool = false
    
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
        return Shape(references: [
            GridReference(0,1),
            GridReference(0,0),
            GridReference(0,-1),
            GridReference(1,1)
        ], colours: Array(repeating: colour, count: 4))
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
     ````
     */
    static func I(_ colour: BlockColour) -> Shape {
        return Shape(references: [
            GridReference(0,-1),
            GridReference(0,0),
            GridReference(0,1),
            GridReference(0,2)
        ], colours: Array(repeating: colour, count: 4))
    }
    
    /**
     O shape
     
     ````
     | |x|x|
     | |x|x|
     | | | |
     ````
     */
    static func O(_ colour: BlockColour) -> Shape {
        return Shape(references: [
            GridReference(1,0),
            GridReference(1,1),
            GridReference(0,0),
            GridReference(0,1)
        ], colours: Array(repeating: colour, count: 4))
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

