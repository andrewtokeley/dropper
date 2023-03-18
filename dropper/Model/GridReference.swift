//
//  GridReference.swift
//  dropper
//
//  Created by Andrew Tokeley on 19/02/23.
//

import Foundation

enum GridDirection: Int {
    case left = 0
    case right
    case top
    case bottom
    
    var gridDelta: GridDelta {
        switch self {
        case .top: return GridDelta(rowDelta: 1, columnDelta: 0)
        case .bottom: return GridDelta(rowDelta: -1, columnDelta: 0)
        case .left: return GridDelta(rowDelta: 0, columnDelta: -1)
        case .right: return GridDelta(rowDelta: 0, columnDelta: 1)
        }
    }
}

struct GridDelta {
    var rowDelta: Int
    var columnDelta: Int
}

/**
 Represents a location within the game's grid. Grid's are referenced using a zero based index, where row 0 is the bottom row and column 0 is the left most column.
 */
class GridReference {
    
    /// Row reference where 1 is the bottom most row
    var row: Int
    
    /// Column reference where 1 is the leftmost column
    var column: Int
    
    init(_ row: Int, _ column: Int) {
        self.row = row
        self.column = column
    }
    
    /**
     Returns the grid reference adjacent to the current instance
     */
    func adjacent(_ direction: GridDirection) -> GridReference {
        return GridReference(
            row + direction.gridDelta.rowDelta,
            column + direction.gridDelta.columnDelta
        )
    }
    
    /**
     Returns a new GridReference equal to the current instance offset by the given row, column offsets
     */
    func offSet(_ rowOffset: Int, _ columnOffset: Int) -> GridReference {
        return GridReference(row + rowOffset, column + columnOffset)
    }
    
    static func + (left: GridReference, right: GridReference) -> GridReference {
        return GridReference(left.row + right.row, left.column + right.column)
    }
    static func - (left: GridReference, right: GridReference) -> GridReference {
        return GridReference(left.row - right.row, left.column - right.column)
    }
}

extension GridReference: Equatable {
    static func == (left: GridReference, right: GridReference) -> Bool {
        return left.row == right.row && left.column == right.column
    }
}

extension GridReference: CustomStringConvertible {
    var description: String {
        return "\(row), \(column)"
    }
}
