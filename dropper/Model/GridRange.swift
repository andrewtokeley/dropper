//
//  GridRange.swift
//  dropper
//
//  Created by Andrew Tokeley on 4/03/23.
//

import Foundation
import SwiftUI

enum GridRangeError: Error {
    case InvalidGridReferences
}

enum GridRangeOrientation: Int {
    case horizontal = 0
    case vertical
    case unknown
}

/**
 A GridRange represents the start and end locations of a continues span of blocks in a horizontal or vertical direction
 */
class GridRange {
        
    var start: GridReference
    var end: GridReference
    
    var orientation: GridRangeOrientation {
        if start.row == end.row { return .horizontal }
        if start.column == end.column { return .vertical }
        return .unknown // probably single cell range
    }
    
    var length: Int {
        if orientation == .vertical {
            return abs(start.row - end.row) + 1
        } else if orientation == .horizontal {
            return abs(start.column - end.column) + 1
        } else {
            return 0
        }
    }
    
    init(start: GridReference, end: GridReference) throws {
        guard start.row == end.row || start.column == end.column else { throw GridRangeError.InvalidGridReferences }
        
        self.start = start
        self.end = end
    }
    
}
