//
//  GridOffset.swift
//  dropper
//
//  Created by Andrew Tokeley on 26/03/23.
//

import Foundation

/**
 A GridOffset represents horizontal and vertical offset amounts
 */
struct GridOffset {
    var rowOffset: Int
    var columnOffset: Int
    
    init(_ rowOffset: Int, _ columnOffset: Int) {
        self.rowOffset = rowOffset
        self.columnOffset = columnOffset
    }
    
    static var zero: GridOffset {
        return GridOffset(0,0)
    }
}
