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
    
    static func random(_ colour: BlockColour) -> Shape {
        let type = Int.random(in: 0..<6)
        switch type {
        case 0:
            return elbow(colour)
        case 1:
            return longBar(colour)
        case 2:
            return bucket(colour)
        case 3:
            return smallBar(colour)
        case 4:
            return block(colour)
        case 5:
            return lightning(colour)
        default:
            return longBar(colour)
        }
    }
    
    static func smallBar(_ colour: BlockColour) -> Shape {
        return Shape(references: [
            GridReference(0,0),
            GridReference(-1,0),
        ], colours: Array(repeating: colour, count: 2))
    }
    
    static func elbow(_ colour: BlockColour) -> Shape {
        return Shape(references: [
            GridReference(1,0),
            GridReference(0,0),
            GridReference(-1,0),
            GridReference(-1,1)
        ], colours: Array(repeating: colour, count: 4))
    }
    
    static func bucket(_ colour: BlockColour) -> Shape {
        return Shape(references: [
            GridReference(0,-1),
            GridReference(0,0),
            GridReference(0,1),
            GridReference(1,-1),
            GridReference(1,1),
        ], colours: Array(repeating: colour, count: 5))
    }
    
    static func longBar(_ colour: BlockColour) -> Shape {
        return Shape(references: [
            GridReference(1,0),
            GridReference(0,0),
            GridReference(-1,0)
        ], colours: Array(repeating: colour, count: 3))
    }
    
    static func block(_ colour: BlockColour) -> Shape {
        return Shape(references: [
            GridReference(1,0),
            GridReference(1,1),
            GridReference(0,0),
            GridReference(0,1)
        ], colours: Array(repeating: colour, count: 4))
    }
    
    static func lightning(_ colour: BlockColour) -> Shape {
        return Shape(references: [
            GridReference(-1,-1),
            GridReference(0,-1),
            GridReference(0,0),
            GridReference(1,0)
        ], colours: Array(repeating: colour, count: 4))
    }
}

