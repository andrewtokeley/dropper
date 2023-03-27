//
//  GridOffset.swift
//  dropper
//
//  Created by Andrew Tokeley on 26/03/23.
//

import Foundation

/**
 A GridOffset represents hirizontal and vertical offset amounts
 */
struct GridOffset {
    var rowOffset: Int
    var columnOffset: Int
    
    init(_ rowOffset: Int, _ columnOffset: Int) {
        self.rowOffset = rowOffset
        self.columnOffset = columnOffset
    }
}
