//
//  RemoveRowsEffectTests.swift
//  dropperTests
//
//  Created by Andrew Tokeley on 13/03/23.
//

import XCTest
@testable import dropper

class RemoveRowsEffectTests: XCTestCase {
    
    
    func testRemoveRowWithJewel() throws {
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["X2", "X1", "J1", "X2", "X4", "X2", "X2"],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "]
            ])
        
        let effect = RemoveRowsEffect()
        let result = effect.apply(grid)
        XCTAssertEqual(result.blocksRemoved.count, 7)
        XCTAssertEqual(result.achievments.get(.jewel), 1)
        XCTAssertEqual(result.achievments.get(.oneRow), 1)
    }
    
    func testRemoveSingleRow() throws {
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["X1", "X1", "X3", "  ", "X2", "  ", "X3"],
                ["X1", "X1", "X3", "X2", "X2", "X1", "X3"],
                ["X1", "X1", "X3", "  ", "X2", "  ", "X3"],
            ])
        
        let effect = RemoveRowsEffect()
        let result = effect.apply(grid)
        
        XCTAssertTrue(result.isMaterial)
        XCTAssertEqual(result.achievments.get(.oneRow), 1)
        
        // there should be no blocks left
        XCTAssertEqual(grid.getAll().count, 10)
    }
    
    func testDoubleSingleRow() throws {
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["X1", "X1", "X3", "  ", "X2", "  ", "X3"],
                ["X1", "X1", "X3", "X2", "X2", "X1", "X3"],
                ["X1", "X1", "X3", "X2", "X2", "X1", "X3"],
                ["X1", "X1", "X3", "  ", "X2", "  ", "X3"],
            ])
        
        let effect = RemoveRowsEffect()
        let result = effect.apply(grid)
        
        XCTAssertTrue(result.isMaterial)
        XCTAssertEqual(result.achievments.get(.oneRow), 0)
        XCTAssertEqual(result.achievments.get(.twoRows), 1)
        
        // there should be no blocks left
        XCTAssertEqual(grid.getAll().count, 10)
    }

    func testTripleSingleRow() throws {
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["X1", "X1", "X3", "  ", "X2", "  ", "X3"],
                ["X1", "X1", "X3", "X2", "X2", "X1", "X3"],
                ["X1", "X1", "X3", "X2", "X2", "X1", "X3"],
                ["X1", "X1", "X3", "X2", "X2", "X1", "X3"],
                ["X1", "X1", "X3", "  ", "X2", "  ", "X3"],
            ])
        
        let effect = RemoveRowsEffect()
        let result = effect.apply(grid)
        
        XCTAssertTrue(result.isMaterial)
        XCTAssertEqual(result.achievments.get(.oneRow), 0)
        XCTAssertEqual(result.achievments.get(.twoRows), 0)
        XCTAssertEqual(result.achievments.get(.threeRows), 1)
        
        // there should be no blocks left
        XCTAssertEqual(grid.getAll().count, 10)
    }
}
