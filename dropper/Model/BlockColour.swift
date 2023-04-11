//
//  BlockColour.swift
//  dropper
//
//  Created by Andrew Tokeley on 9/04/23.
//

import Foundation

/**
 Enumeration that represents the colour of a block.
 
 Note this enum has no concept of the actual UIColor, only that the enumerated colours are different. To get the UIColor of a BlockColour use the UIColour extension method;
 
 ````
 // Get the UIColor for .colour1
 let colour = UIColor.from(BlockColour.colour1)
 
 ````
 */
enum BlockColour: Int, Codable {
    
    case colour1 = 1
    case colour2
    case colour3
    case colour4
    case colour5
    case colour6
    
    /**
     Returns a random colour
     */
    static var random: BlockColour {
        return BlockColour(rawValue: Int.random(in: 0..<5)) ?? .colour4
    }
    
    /**
     Returns an array of unique random colours
     */
    static func random(_ count: Int) -> [BlockColour] {
        var colours = [BlockColour]()
        while colours.count < count {
            let colour = BlockColour.random
            if !colours.contains(colour) {
                colours.append(colour)
            }
        }
        return colours
    }
    
//    /**
//     Returns the BlockColour result from a number, returning nil if the number is out of range.
//     
//     This is simply a convenience to calling BlockColour(rawValue: number) but does
//     */
//    static func from(_ numberAsString: String) -> BlockColour? {
//        if let number = Int(numberAsString) {
//            if number >= 1 && number <= 6 {
//                return BlockColour(rawValue: number)
//            }
//        }
//        return nil
//    }

    /// Debug info
    var description: String {
        switch self {
        case .colour1: return "Colour1"
        case .colour2: return "Colour2"
        case .colour3: return "Colour3"
        case .colour4: return "Colour4"
        case .colour5: return "Colour5"
        case .colour6: return "Colour6"
        }
    }
}
