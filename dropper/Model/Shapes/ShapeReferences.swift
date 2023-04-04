//
//  ShapeReferences.swift
//  dropper
//
//  Created by Andrew Tokeley on 4/04/23.
//

import Foundation

struct ShapeReference {
    
    var references = [GridReference]()
    var name: String = ""
    
    static var L: ShapeReference {
        return ShapeReference(
            references: [
                GridReference(0,1),
                GridReference(0,0),
                GridReference(0,-1),
                GridReference(1,1)],
            name: "L")
    }
    
    static var J: ShapeReference {
        return ShapeReference(
            references: [
                GridReference(0,1),
                GridReference(0,0),
                GridReference(0,-1),
                GridReference(1,-1)],
            name: "J")
    }
    
    static var I: ShapeReference {
        return ShapeReference(
            references: [
                GridReference(0,-1),
                GridReference(0,0),
                GridReference(0,1),
                GridReference(0,2)],
            name: "I")
    }
    
    static var O: ShapeReference {
        return ShapeReference(
            references: [
                GridReference(1,0),
                GridReference(1,1),
                GridReference(0,0),
                GridReference(0,1)],
            name: "O")
    }
    
    static var S: ShapeReference {
        return ShapeReference(
            references: [
                GridReference(0,-1),
                GridReference(0,0),
                GridReference(1,0),
                GridReference(1,1)],
            name: "S")
    }
    
    static var Z: ShapeReference {
        return ShapeReference(
            references: [
                GridReference(1,-1),
                GridReference(1,0),
                GridReference(0,0),
                GridReference(0,1)],
            name: "Z")
    }
    
    static var random: ShapeReference {
        let type = Int.random(in: 0..<6)
        switch type {
        case 0:
            return L
        case 1:
            return I
        case 2:
            return J
        case 3:
            return S
        case 4:
            return Z
        case 5:
            return O
        default:
            return I
        }
    }
}
