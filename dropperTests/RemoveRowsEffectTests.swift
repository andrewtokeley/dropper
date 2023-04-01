//
//  RemoveRowsEffectTests.swift
//  dropperTests
//
//  Created by Andrew Tokeley on 13/03/23.
//

import XCTest
@testable import dropper

class RemoveRowsEffectTests: XCTestCase {
    
    func testRemoveSingleRow() throws {
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["XB", "XB", "XY", "  ", "XR", "  ", "XY"],
                ["XB", "XB", "XY", "XR", "XR", "XB", "XY"],
                ["XB", "XB", "XY", "  ", "XR", "  ", "XY"],
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
                ["XB", "XB", "XY", "  ", "XR", "  ", "XY"],
                ["XB", "XB", "XY", "XR", "XR", "XB", "XY"],
                ["XB", "XB", "XY", "XR", "XR", "XB", "XY"],
                ["XB", "XB", "XY", "  ", "XR", "  ", "XY"],
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
                ["XB", "XB", "XY", "  ", "XR", "  ", "XY"],
                ["XB", "XB", "XY", "XR", "XR", "XB", "XY"],
                ["XB", "XB", "XY", "XR", "XR", "XB", "XY"],
                ["XB", "XB", "XY", "XR", "XR", "XB", "XY"],
                ["XB", "XB", "XY", "  ", "XR", "  ", "XY"],
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
