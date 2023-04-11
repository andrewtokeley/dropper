//
//  DropBlocksEffectTests.swift
//  dropperTests
//
//  Created by Andrew Tokeley on 26/02/23.
//

import XCTest
@testable import dropper

class DropInEmptyRowsEffectTests: XCTestCase {
    
    func testDropTwoRows() throws {
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["X1", "X1", "X1", "X1", "X1", "X3", "X2"],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "]
            ])
        
        let effect = DropIntoEmptyRowsEffect()
        let result = effect.apply(grid)
        XCTAssertEqual(result.blocksMoved.count, 7)
    }
    
    func testDropTwoSeparateRows() throws {
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["X1", "X1", "X1", "X1", "X1", "X3", "X2"],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["X1", "X1", "X1", "X1", "X1", "X3", "X2"],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "]
            ])
        
        let effect = DropIntoEmptyRowsEffect()
        let result = effect.apply(grid)
        XCTAssertEqual(result.blocksMoved.count, 14)
    }
    
    func testRemoveNoRows() throws {
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "J1", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "]
            ])
        
        let effect = DropIntoEmptyRowsEffect()
        let result = effect.apply(grid)
        XCTAssertEqual(result.blocksMoved.count, 0)
    }
}
